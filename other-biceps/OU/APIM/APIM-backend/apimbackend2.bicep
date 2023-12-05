param apimName string

param functionAppName string

param subscriptionId string

param resourceGroupName string

resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

var URL = 'http://ou-dih-fn-uks.azurewebsites.net/api/'

resource serviceBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  parent: apim
  name: 'ou-dih-test-fn-we'
  properties: {
    url: URL
    protocol: 'http'
    resourceId: 'https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${functionAppName}'
    credentials: {
      header: {
        'x-functions-key': [
          'ou-dih-test-fn-we'
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}
