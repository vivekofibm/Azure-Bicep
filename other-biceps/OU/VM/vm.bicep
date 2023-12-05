param vm_name string = 'ou-dih-sit-development-vm'
param location string = resourceGroup().location
// param nsgid string = '/subscriptions/94ef17bd-8a0a-4325-89bb-329147622f1a/resourceGroups/rg-ou/providers/Microsoft.Network/networkSecurityGroups/ou-dig-nsg'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' existing = {
  name: 'myNetworkInterface'
  
}

resource vitualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vm_name
  location: location
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-21h2-pro-g2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_name}_disk1_c532b4f38f6f472e806bd90496571154'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          //id: disks_ou_dih_sit_development_vm_disk1_c532b4f38f6f472e806bd90496571154_externalid
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'ou-dih-sit-deve'
      adminUsername: 'dihProject'
      adminPassword: 'Qwerty@123'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: 'Windows_Client'
  }
}
