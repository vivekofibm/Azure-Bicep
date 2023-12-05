@description('Location for all resources.')
param location string = resourceGroup().location

param sqlserverName string = 'ou-dih-test-we'
//param databaseName string = 'sample-db1'

param dbName string  = 'ou-dih-test-database-we'

resource sqlserver 'Microsoft.Sql/servers@2022-08-01-preview' existing = {
  name: sqlserverName
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
    sqlserver
  ]
}
