param location string = resourceGroup().location

// Create a Data Lake Storage account within the resource group
resource mydatastore 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'mydatalakestore'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    environment: 'prod'
  }
}
