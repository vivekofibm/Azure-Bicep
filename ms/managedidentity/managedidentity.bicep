param location string = resourceGroup().location

param existingKeyVaultName string

param tenantId string = subscription().tenantId

param identityName string = 'id-${uniqueString(resourceGroup().id)}'
var keyVaultSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

resource keyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${existingKeyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: userIdentity.properties.principalId
        permissions: {
          certificates: [
            'list'
            'get'
          ]
          keys: [
            'list'
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
        tenantId: tenantId
      }

    ]
  }
}
output identityName string = identityName
output identityId string = userIdentity.id
output identityPrincipalId string = userIdentity.properties.principalId
