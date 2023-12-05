param apimName string = 'ou-dih-apim'

param functionAppName string = 'ou-dih-acct-fn-we'

param subscriptionId string = '94ef17bd-8a0a-4325-89bb-329147622f1a'

param resourceGroupName string = 'rg-ou'



resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

var URL = 'http://ou-dih-fn-uks.azurewebsites.net/api/'

resource serviceBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  parent: apim
  name: 'ou-dih-fn-we'
  properties: {
    url: URL
    protocol: 'http'
    resourceId: 'https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${functionAppName}'
    credentials: {
      header: {
        'x-functions-key': [
          'ou-dih-acct-fn-we'
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}
