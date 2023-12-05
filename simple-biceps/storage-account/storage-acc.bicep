@decription('Provide a name of storage account')
param storageAccountName string = 'my-test-stg-acc'  //it we are not passing the value, it will take this default name

@description('pass the location where you want to create the resource')
param location string = resourceGroup().location  //By default it will take the resource group location

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])param storageAccountType string = 'Standard_LRS' //Define which type of storage account you need to provision


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}
