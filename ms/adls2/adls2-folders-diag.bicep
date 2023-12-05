
param location string = resourceGroup().location



param storageName string = 'dl${uniqueString(resourceGroup().id)}'



param folders  array = [
  {
    name: 'raw'
  }
  {
    name: 'curated'
  }
]

@description('eventHubAuthorizationRuleId')
@minLength(4)
param eventHubAuthorizationRuleId string

@description('eventHubName')
@minLength(4)
param eventHubName string

@description('Log Analytics WorkspaceId')
@minLength(4)
param workspaceId string

var validStorageName = replace(storageName, '-', '')

@description('https://docs.microsoft.com/en-us/azure/templates/microsoft.datalakestore/accounts?tabs=bicep')
resource datalakegen2 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: validStorageName
  location: location 
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS' 
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    isHnsEnabled: true //Data Lake Gen2 upgrade
  } 
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
  name:'default'
  parent:datalakegen2
}

resource folder 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for folder in folders: {
  name: '${datalakegen2.name}/default/${folder.name}'
}]

resource sa_microsoft_insights_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
    name: '${datalakegen2.name}-diag-settings'
    scope: datalakegen2
    properties: {
      workspaceId: workspaceId
      eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
      eventHubName: eventHubName
      metrics: [
        {
          category: 'Transaction'
          enabled: true
        }
      ]
    }
  }
  
  resource blob_microsoft_insights_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
    name: 'blob-diag-settings'
    scope: blob
    properties: {
      workspaceId: workspaceId
      eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
      eventHubName: eventHubName
      logs: [
        {
          category: 'StorageRead'
          enabled: true
        }
        {
          category: 'StorageWrite'
          enabled: true
        }
        {
          category: 'StorageDelete'
          enabled: true
        }
      ]
      metrics: [
        {
          category: 'Transaction'
          enabled: true
        }
      ]
    }
  }
