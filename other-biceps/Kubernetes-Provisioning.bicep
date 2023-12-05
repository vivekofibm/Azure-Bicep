@description('The name of the Managed Cluster resource.')
param clusterName string = 'testoucluster'

@description('The location of the Managed Cluster resource.')
param location string = 'uk south'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'aksdnsou'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 2

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'testuser'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDa5JoKcBkeLnFWZaTtnKnGNZuJDMh/1zbh5zt6Zfgv4JSQ5UIHArMl8L2UUVLioeeCvcBuE37LwdFdi/+Q9O2/1AmB8p+X6ecKlJyrRjLkoNCKHG0yPr+9BYkNA/bxnljjW1gJ62i0sna9s7DuTPXKpabqq+h9JpWP2GOPRFiN88jrE6bMZ98TsS3tD0XJUs/XgBZNlFffBSMBYSSd+xYYOjc+X5y9V9F9cWxvPmtInZUM3U5yza2YX2e+KppMAIgLY9QTVBQLIS4aBTdqUPf8VGIMiwr59/mC8Q5DbRC35/EXXSm2H5SXg11I1HckI1EbvHBg/cyo003ZqJrmhE6UsPLPtj9z0qJ22nqMyBRPyoIsdpWQmCpdL+RT/8Iy8IXq8bClRGZnRNhS0ovQOk6HTSP3mUDWjtGq6q/+YsGU0LWAb0c9LSDqzzx28lSjvtzNBpcXTLcNnEBUGEjaZTitUy9Lbbt9w4VjfvEae4KAoesyo3rkksNsDz4QBdI3Du/4QIYD7kvtznruXrYvoK4RJPjZhvAycSKtVlMhLOuXx5ydA30XXSlF4J3czvjbctPRjarACk5f7HuPjufzqflLM6KBr+uO1Jhe8optkXWBr9Ve4xdRkNPWXNhTWaz1PQykUfien/WFsXU/YDVJt0q3o5Agme8UOgOUctIsc3FH7w== vivek@cc-cebbcbd4-566f8f4bfc-22zb5'

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    nodeResourceGroup: 'rg-res-aks'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}
