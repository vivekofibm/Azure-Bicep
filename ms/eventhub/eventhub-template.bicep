@description('Specifies a project name that is used to generate the Event Hub name and the Namespace name.')
param projectName string

@description('Specifies the Azure location for all resources.')
param location string = resourceGroup().location

@description('Specifies the messaging tier for Event Hub Namespace.')
@allowed([
  'Basic'
  'Standard'
])
param eventHubSku string = 'Standard'

param eventhubAuthorizationRuleName1 string = 'Splunk-Rule'

var eventHubNamespaceName = '${projectName}ns'
var eventHubName = projectName

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource eventHubAuthorisationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = {
  parent: eventHubNamespace
  name: eventhubAuthorizationRuleName1
  properties: {
    rights: ['Send']
  }

}

output eventHubName string = eventHubName
output eventHubAuthorizationRuleId string = eventHubAuthorisationRule.id
