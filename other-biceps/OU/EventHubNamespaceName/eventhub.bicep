param namespaces_ou_dih_sit_eh_we_name string = 'ou-dih-sit-eh-we'

resource namespaces_ou_dih_sit_eh_we_name_resource 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: namespaces_ou_dih_sit_eh_we_name
  location: 'West Europe'
  tags: {
    ResourceType: 'Events'
    Owner: 'Bartlomiej.Cichopek, Divya.Singhal, Vinay.Shettar'
  }
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

resource namespaces_ou_dih_sit_eh_we_name_Listen 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'Listen'
  location: 'westeurope'
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource namespaces_ou_dih_sit_eh_we_name_RootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'RootManageSharedAccessKey'
  location: 'westeurope'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_ou_dih_sit_eh_we_name_Send 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'Send'
  location: 'westeurope'
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource namespaces_ou_dih_sit_eh_we_name_customerprofile 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'customerprofile'
  location: 'westeurope'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 24
    }
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

resource namespaces_ou_dih_sit_eh_we_name_studyrecord 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'studyrecord'
  location: 'westeurope'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

resource namespaces_ou_dih_sit_eh_we_name_default 'Microsoft.EventHub/namespaces/networkRuleSets@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_resource
  name: 'default'
  location: 'West Europe'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
  }
}

resource namespaces_ou_dih_sit_eh_we_name_customerprofile_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_customerprofile
  name: '$Default'
  location: 'westeurope'
  properties: {}
  dependsOn: [

    namespaces_ou_dih_sit_eh_we_name_resource
  ]
}

resource namespaces_ou_dih_sit_eh_we_name_studyrecord_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-10-01-preview' = {
  parent: namespaces_ou_dih_sit_eh_we_name_studyrecord
  name: '$Default'
  location: 'westeurope'
  properties: {}
  dependsOn: [

    namespaces_ou_dih_sit_eh_we_name_resource
  ]
}