param location string = 'uksouth'
param eventHubNamespaceName string = 'ou-dih-eh-we'
param eventHubName string = 'ou-dih-eh-we-eventhub'

resource namespaces_name_resource 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespaceName
  location: location
  
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: false
  }
}
