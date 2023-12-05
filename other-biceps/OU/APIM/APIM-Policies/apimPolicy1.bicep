param apimName string = 'ou-dih-apim'

resource apim 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource service_name_divert_mock_request 'Microsoft.ApiManagement/service/policyfragments@2022-08-01' = {
  parent: apim
  name: 'divert-mock-request'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy fragment are included as-is whenever they are referenced.\r\n    - If using variables. Ensure they are setup before use.\r\n    - Copy and paste your code here or simply start coding\r\n-->\r\n<fragment>\r\n\t<choose>\r\n\t\t<when condition="@(context.Request.Headers.GetValueOrDefault(&quot;OU-UseStub&quot;) == &quot;true&quot;)">\r\n\t\t\t<set-backend-service id="apim-generated-policy" backend-id="ou-dih-fn-uks" />\r\n\t\t</when>\r\n\t\t<otherwise>\r\n\t\t\t<set-backend-service id="apim-generated-policy" backend-id="ou-dih-sit-af-we" />\r\n\t\t</otherwise>\r\n\t</choose>\r\n</fragment>'
  }
}
