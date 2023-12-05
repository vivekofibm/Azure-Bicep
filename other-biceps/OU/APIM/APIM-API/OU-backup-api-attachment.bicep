@description('The Name of the Function App we wish to attach.')
param apimName string

@description('The Name of the Function App we wish to attach.')
param functionAppName string

@description('The Name of the Stub Function App we wish to attach.')
param functionAppNameStub string

@description('The Subscription Id where function app is present.')
param subscriptionId string

@description('The Resource Group where function app is present.')
param resourceGroupName string

@description('The URl of function app.')
param url string

@description('The URl of Stub Function App.')
param urlStub string

resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource serviceBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  parent: apim
  name: 'ou-dih-test-af-we'
  properties: {
    url: url
    protocol: 'http'
    resourceId: 'https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${functionAppName}'
    credentials: {
      header: {
        'x-functions-key': [
          'ou-dih-test-af-we'
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource serviceBackendStub 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  parent: apim
  name: 'ou-dih-test-af-stub-we'
  properties: {
    url: urlStub
    protocol: 'http'
    resourceId: 'https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${functionAppNameStub}'
    credentials: {
      header: {
        'x-functions-key': [
          'ou-dih-test-af-stub-we'
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource apimapi 'Microsoft.ApiManagement/service/apis@2022-09-01-preview' = {
  parent: apim
  name: 'ou-dih-test-af-we'
  properties: {
    displayName: 'ou-dih-test-af-we'
    apiRevision: '1'
    description: 'Import from "ou-dih-test-af-we" Function App'
    subscriptionRequired: false
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





/////////////////////////////////////////////////////////////////////////


resource ou_dih_test_af_we_get_swaggerjson 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-swaggerjson'
  properties: {
    displayName: 'SwaggerJson'
    method: 'GET'
    urlTemplate: '/swagger/json'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_swaggeryaml 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-swaggeryaml'
  properties: {
    displayName: 'SwaggerYaml'
    method: 'GET'
    urlTemplate: '/swagger/yaml'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_customerprofile 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-customerprofile'
  properties: {
    displayName: 'v1-CustomerProfile'
    method: 'GET'
    urlTemplate: '/v1/customer'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_healthcontroller 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-healthcontroller'
  properties: {
    displayName: 'v1-HealthController'
    method: 'GET'
    urlTemplate: '/v1/health'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_productassessment 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productassessment'
  properties: {
    displayName: 'v1-ProductAssessment'
    method: 'GET'
    urlTemplate: '/v1/products/modulePresentations/{modulePresentationCode}/assessments/{assessmentCode}'
    templateParameters: [
      {
        name: 'modulePresentationCode'
        required: true
        values: []
        type: ''
      }
      {
        name: 'assessmentCode'
        required: true
        values: []
        type: ''
      }
    ]
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_productmodule 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productmodule'
  properties: {
    displayName: 'v1-ProductModule'
    method: 'GET'
    urlTemplate: '/v1/products/modules/{moduleCode}'
    templateParameters: [
      {
        name: 'moduleCode'
        required: true
        values: []
        type: ''
      }
    ]
    responses: []
  }
  dependsOn: [

    apim
  ]
}

resource ou_dih_test_af_we_get_v1_productmodulepresentation 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productmodulepresentation'
  properties: {
    displayName: 'v1-ProductModulePresentation'
    method: 'GET'
    urlTemplate: '/v1/products/modulePresentations/{modulePresentationsCode}'
    templateParameters: [
      {
        name: 'modulePresentationsCode'
        required: true
        values: []
        type: ''
      }
    ]
    responses: []
  }

}
resource ou_dih_test_af_we_get_v1_productmodulepresentations 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productmodulepresentations'
  properties: {
    displayName: 'v1-ProductModulePresentations'
    method: 'GET'
    urlTemplate: '/v1/products/modulePresentations'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_productmodules 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productmodules'
  properties: {
    displayName: 'v1-ProductModules'
    method: 'GET'
    urlTemplate: '/v1/products/modules'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_productqualification 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productqualification'
  properties: {
    displayName: 'v1-ProductQualification'
    method: 'GET'
    urlTemplate: '/v1/products/qualifications/{id}'
    templateParameters: [
      {
        name: 'id'
        required: true
        values: []
        type: ''
      }
    ]
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_productqualifications 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-productqualifications'
  properties: {
    displayName: 'v1-ProductQualifications'
    method: 'GET'
    urlTemplate: '/v1/products/qualifications'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_producttutorial 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-producttutorial'
  properties: {
    displayName: 'v1-ProductTutorial'
    method: 'GET'
    urlTemplate: '/v1/products/modulePresentations/{modulePresentationCode}/tutorials/{tutorialCode}'
    templateParameters: [
      {
        name: 'modulePresentationCode'
        required: true
        values: []
        type: ''
      }
      {
        name: 'tutorialCode'
        required: true
        values: []
        type: ''
      }
    ]
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_studyrecord 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'get-v1-studyrecord'
  properties: {
    displayName: 'v1-StudyRecord'
    method: 'GET'
    urlTemplate: '/v1/student/studyrecord'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_post_v1_feedbackpost 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'post-v1-feedbackpost'
  properties: {
    displayName: 'v1-FeedbackPost'
    method: 'POST'
    urlTemplate: '/v1/feedback'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_put_eventhubhelper_customerprofile 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'put-eventhubhelper-customerprofile'
  properties: {
    displayName: 'EventHUBHelper-CustomerProfile'
    method: 'PUT'
    urlTemplate: '/v1/helper/eventhub/customerprofile'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_put_eventhubhelper_studyrecord 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'put-eventhubhelper-studyrecord'
  properties: {
    displayName: 'EventHUBHelper-StudyRecord'
    method: 'PUT'
    urlTemplate: '/v1/helper/eventhub/studyrecord'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_put_v1_customerprofileupdate 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'put-v1-customerprofileupdate'
  properties: {
    displayName: 'v1-CustomerProfileUpdate'
    method: 'PUT'
    urlTemplate: '/v1/customer'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_put_v1_studyrecordupdate 'Microsoft.ApiManagement/service/apis/operations@2022-09-01-preview' = {
  parent: apimapi
  name: 'put-v1-studyrecordupdate'
  properties: {
    displayName: 'v1-StudyRecordUpdate'
    method: 'PUT'
    urlTemplate: '/v1/student/studyrecord'
    templateParameters: []
    responses: []
  }

}

resource ou_dih_test_af_we_get_v1_healthcontroller_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-09-01-preview' = {
  parent: ou_dih_test_af_we_get_v1_healthcontroller
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service id="apim-generated-policy" backend-id="ou-dih-test-af-we" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }

}

resource ou_dih_test_af_we_get_v1_studyrecord_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-09-01-preview' = {
  parent: ou_dih_test_af_we_get_v1_studyrecord
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service id="apim-generated-policy" backend-id="ou-dih-test-af-we" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }

}
