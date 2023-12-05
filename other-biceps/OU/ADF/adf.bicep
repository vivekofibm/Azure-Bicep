param name string //= 'ou-dih-adf-test-we'
param version string //= 'V2'
param location string = resourceGroup().location

resource ADF 'Microsoft.DataFactory/factories@2018-06-01' = if (version == 'V2') {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  } 
}
