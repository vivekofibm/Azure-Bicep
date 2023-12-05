param apimName string = ''

resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource ou_dih_test_af_we 'Microsoft.ApiManagement/service/apis@2022-09-01-preview' = {
  parent: apim
  name: 'ou-dih-test-af-we'
  properties: {
    displayName: 'ou-dih-test-af-we'
    apiRevision: '1'
    description: 'Import from "ou-dih-test-af-we" Function App'
    subscriptionRequired: true
    path: 'ou-dih-test-af-we/api'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

param apiNames array = [
  
]

resource v1_productqualification 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: ou_dih_test_af_we
  name: 'get-v1-productqualification'
  properties: {
    displayName: 'v1-${apiNames}'
    method: 'GET'
    urlTemplate: '/v1/products/qualifications/{id}'
    templateParameters: [
      {
        name: 'id'
        required: true
        values: []
        type: operations_get_v1_productqualification_type
      }
    ]
    responses: []
  }
  dependsOn: [

    service_ou_dih_test_ds_new_test_apim_we_name_resource
  ]
}
