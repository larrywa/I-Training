@description('Primary location for resources')
param location string = resourceGroup().location
param databaseForMySqlDBServerName string
param databaseName string = 'auctionservicedb'
param databaseForMySqlAdminName string
@secure()
param databaseForMySqlAdminPassword string

@description('The tier of the particular SKU. High Availability is available only for GeneralPurpose and MemoryOptimized sku.')
@allowed([
  'Burstable'
  'Generalpurpose'
  'MemoryOptimized'
])
param serverEdition string = 'Burstable'

@description('Server version')
@allowed([
  '5.7'
  '8.0.21'
])
param version string = '5.7'

@description('Availability Zone information of the server. (Leave blank for No Preference).')
param availabilityZone string = '1'

@description('High availability mode for a server : Disabled, SameZone, or ZoneRedundant')
@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
param haEnabled string = 'Disabled'

param storageSizeGB int = 20
param storageIops int = 360
@allowed([
  'Enabled'
  'Disabled'
])
param storageAutogrow string = 'Disabled'

@description('The name of the sku, e.g. Standard_D32ds_v4.')
param skuName string = 'Standard_B1ms'

@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

resource mySqlDBServer 'Microsoft.DBforMySQL/flexibleServers@2021-12-01-preview' = {
  name: databaseForMySqlDBServerName
  location: location
  sku: {
    name: skuName
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: databaseForMySqlAdminName
    administratorLoginPassword: databaseForMySqlAdminPassword
    availabilityZone: availabilityZone
    highAvailability: {
      mode: haEnabled
    }
    storage: {
      storageSizeGB: storageSizeGB
      iops: storageIops
      autoGrow: storageAutogrow
    }
    backup: {
      geoRedundantBackup: geoRedundantBackup
    }
    
  }
}

resource mySqlDatabase 'Microsoft.DBforMySQL/flexibleServers/databases@2021-12-01-preview' = {
  parent: mySqlDBServer
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

resource firewallRules 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-12-01-preview' = {
  parent: mySqlDBServer
  name: 'firewallRules-mysql'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}
