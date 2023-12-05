@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string


@description('Location for all resources.')
param location string = resourceGroup().location

param virtualNetworkName string
param subnetName string
param sqlServerName string = 'sqlserver${uniqueString(resourceGroup().id)}'
param databaseName string = 'sample-db'

@description('eventHubAuthorizationRuleId1')
@minLength(4)
param eventHubAuthorizationRuleId1 string

@description('eventHubAuthorizationRuleId2')
@minLength(4)
param eventHubAuthorizationRuleId2 string

@description('eventHubName')
@minLength(4)
param eventHubName string

@description('Log Analytics WorkspaceId')
@minLength(4)
param workspaceId string

param privateEndpointName string = 'rn-sqldb-pen'
var dbName = '${sqlServerName}/${databaseName}'
// var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
// var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
// var vmName = take('myVm${uniqueString(resourceGroup().id)}', 15)
// var publicIpAddressName = '${vmName}PublicIP'
// var networkInterfaceName = '${vmName}NetInt'
// var osDiskType = 'StandardSSD_LRS'
var diagnosticSettingsName = 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    displayName: sqlServerName
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}


resource database 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: dbName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  tags: {
    displayName: dbName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'

  }
  dependsOn: [
    sqlServer
  ]
}

resource databaseEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-05-01-preview' = {
  name: 'current'
  parent: database
  properties: {
    state: 'Enabled'
  }
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource masterdatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: 'master'
  parent: sqlServer
  location: location
  properties: {
  }
}

resource sqlServerDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: masterdatabase
  properties: {
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId2
    eventHubName: eventHubName
    //workspaceId: workspaceId
    logs: [
      {

        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
  }
  dependsOn: [
    sqlServer
  ]
    
}


resource sqlServerAuditSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    auditActionsAndGroups:[
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
    ]
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource databaseServiceDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'database-service-diagsettings'
  scope: database
  properties: {
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId1
    eventHubName: eventHubName
    workspaceId: workspaceId
    logs: [
      {

        categoryGroup: 'audit'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
output privateEndpointName string = privateEndpoint.name
