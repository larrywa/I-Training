@description('Primary location for resources')
param location string = resourceGroup().location

param aKSclusterName string
param aKSAgentCount int
param aKSAgentVMSize string
param aKSOSType string = 'Linux'

resource aks 'Microsoft.ContainerService/managedClusters@2022-11-01' = {
  name: aKSclusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aKSclusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: aKSAgentCount
        vmSize: aKSAgentVMSize
        osType: aKSOSType
        mode: 'System'
      }
    ]
  }
}
