param name string
param type string
param regionId string
param tagsArray object
param requestSource string

resource name_resource 'microsoft.insights/components@2014-08-01' = {
  name: name
  location: regionId
  tags: tagsArray
  properties: {
    ApplicationId: name
    Application_Type: type
    Flow_Type: 'Redfield'
    Request_Source: requestSource
  }
  dependsOn: []
}