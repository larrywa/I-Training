@description('Primary location for resources')
param location string = resourceGroup().location

param storageAccountName string
param storageAccountType string
param storageAccountKind string

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: storageAccountKind
  properties: { }
  sku: {
    name: storageAccountType
  }
}
