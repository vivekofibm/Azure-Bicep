resource ouxEnvironment 'Microsoft.ApiManagement/service/policyFragments@2022-09-01-preview' = {
  name: 'oux-environment'
  parent: apim
  properties: {
    value: '<fragment>\r\n <check-header name="oux-environment" failed-check-httpcode="400" failed-check-error-message="Lack of oux-environment header" ignore-case="true">\r\n  <value>DEV</value>\r\n  <value>TEST</value>\r\n  <value>SIT</value>\r\n   <value>ACCT</value>\r\n   <value>LIVE</value>\r\n </check-header>\r\n </fragment>'
    format: 'xml'
  }

}

resource ouxFrom 'Microsoft.ApiManagement/service/policyFragments@2022-09-01-preview' = {
  name: 'oux-from'
  parent: apim
  properties: {
    value: '<fragment>\r\n  <check-header name="oux-from" failed-check-httpcode="400" failed-check-error-message="Lack of oux-from header" ignore-case="true">\r\n  <value>@(!String.IsNullOrWhiteSpace(context.Request.Headers.GetValueOrDefault("oux-from",""))?context.Request.Headers.GetValueOrDefault("oux-from",""):(context.Request.Headers.GetValueOrDefault("oux-from","")+"wrong_header"))</value>\r\n     </check-header>\r\n   </fragment>'
    format: 'xml'
  }

}

resource ouxUuid 'Microsoft.ApiManagement/service/policyFragments@2022-09-01-preview' = {
  name: 'oux-uuid'
  parent: apim
  properties: {
    value: '<fragment>\r\n   <check-header name="oux-uuid" failed-check-httpcode="400" failed-check-error-message="Lack of oux-uuid header" ignore-case="true">\r\n  <value>@(!String.IsNullOrWhiteSpace(context.Request.Headers.GetValueOrDefault("oux-uuid",""))?context.Request.Headers.GetValueOrDefault("oux-uuid",""):(context.Request.Headers.GetValueOrDefault("oux-uuid","")+"wrong_header"))</value>\r\n  </check-header>\r\n  </fragment>'
    format: 'xml'
  }

}

resource divertMockRequest 'Microsoft.ApiManagement/service/policyFragments@2022-09-01-preview' = {
  name: 'divert-mock-request'
  parent: apim
  properties: {
    value: '<fragment>\r\n  <choose>\r\n    <when condition="@(context.Request.Headers.GetValueOrDefault(OU-UseStub) == true)">\r\n     <set-backend-service id="apim-generated-policy" backend-id="ou-dih-test-af-stub-we" />\r\n    </when>\r\n   <otherwise>\r\n     <set-backend-service id="apim-generated-policy" backend-id="ou-dih-test-af-we" />\r\n   </otherwise>\r\n  </choose>\r\n </fragment>'
    format: 'xml'
  }
  dependsOn: [
    ouxFrom
    ouxEnvironment
    ouxUuid
    serviceBackendStub
    serviceBackend
  ]
}
