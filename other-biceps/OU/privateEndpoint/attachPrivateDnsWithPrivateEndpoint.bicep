
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2022-11-01' existing = {
  name: 'ou-dih-test-pe-we'
}
resource privatelink_database_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' existing = {
  name: 'privatelink.database.windows.net'
}


resource privateEndpoints_ou_dih_test_pe_we_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-11-01' = {
  name: 'ou-dih-test-pe-we/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_database_windows_net'
        properties: {
          privateDnsZoneId: privatelink_database_windows_net.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints
  ]
}
