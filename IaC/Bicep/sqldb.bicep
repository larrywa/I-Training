// PARAMETERS
@description('Name of SQL Server instance - default is %appName%-%environmentName%-sql')
param sqlServerName string
@description('Name of database - default is %appName%database')
param dbName string
@description('Database user name')
param dbUserName string
@description('Database password - passed in via GitHub secret')
@secure()
param dbPassword string
@description('Primary location for resources')
param location string = resourceGroup().location

// RESOURCES
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: dbUserName
    administratorLoginPassword: dbPassword
    version: '12.0'
  }

  resource database 'databases@2021-11-01' = {
    name: dbName
    location: location
    sku: {
      name: 'GP_S_Gen5'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: 1
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      zoneRedundant: false
      readScale: 'Disabled'
      autoPauseDelay: 60
      minCapacity: 1
    }
  }

  resource firewallAllowAllWindowsAzureIps 'firewallRules@2021-11-01' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }
}

// Use outputs for connection string in web app module
output sqlServerFQDN string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = sqlServer::database.name
output userName string = sqlServer.properties.administratorLogin
