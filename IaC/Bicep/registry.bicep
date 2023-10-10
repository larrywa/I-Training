@description('Shared registry name')
param registry string
@description('Shared registry SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param registrySku string = 'Standard'
@description('Primary location for resources')
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: registry
  location: location
  sku: {
    name: registrySku
  }
  properties: {
    adminUserEnabled: true
    encryption: {
      status: 'disabled'
    }
  }
}

output acrName string = acr.name
