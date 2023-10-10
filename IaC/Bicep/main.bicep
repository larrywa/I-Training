// Creates all infrastructure for OAS Application
targetScope = 'subscription' // switch to sub scope to create resource group

// PARAMETERS
@description('Region and location where to deploy the resources')
param location string

param suffix string
//VARIABLES

var appName = 'oas'

//Azure Container Registry
var acrName = '${appName}acr${suffix}'

//Azure Kubernetes Service
var aksAgentCount = 1
var aKSclusterName = '${appName}-aks-cluster'
var aKSAgentVMSize = 'Standard_DS2_v2'
var aKSOSType = 'Linux'

// Storage Account
var storageAccountName = 'storage${suffix}'
var storageAccountType = 'Standard_LRS'
var storageAccountKind = 'StorageV2'

//Application Insights
var appInsightsName = 'appInsights${suffix}'

//SQL Server and Database variables
var sqlServerName = '${appName}-${suffix}-sql'
var dbName ='auctionpaymentdb'
var dbUserName = '${suffix}sqllogin'
var dbPassword = 'P@ssw0rd!@#'

//CosmosDB
var cosmosDbName = 'bidacc${suffix}'

//Mysql
var databaseForMySqlDBServerName = 'auctiondbsrv-${suffix}'
var databaseForMySqlAdminName = 'mydbuser${suffix}'
var databaseForMySqlAdminPassword = 'P@ssw0rd!@#'

//event hub
var eventHubNamespaceName  = 'eventhub${suffix}'
var eventHubSku  = 'Standard'
var eventHubBidTopicName  = 'BidTopic'
var eventHubNotificationTopicName  = 'NotificationTopic'
var eventHubPaymentTopicName  = 'PaymentTopic'

// RESOURCES
// Create resource group for webapp and db
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${appName}-msvcs-rg'
  location: location
}

// Create shared registry
module registry 'registry.bicep' = {
  name: 'acr-deployment'
  scope: rg
  params: {
    registry: acrName
    registrySku: 'Standard'
    location: location
  }
}

//Create AKS cluster
module aks 'aks.bicep' = {
  name: 'aks-deployment'
  scope: rg
  params: {
    location: location
    aKSclusterName: aKSclusterName
    aKSAgentCount: aksAgentCount
    aKSAgentVMSize: aKSAgentVMSize
    aKSOSType: aKSOSType
  }
}

//Create Storage Account
module storage 'storage.bicep' = {
  name: 'storage-deployment'
  scope: rg
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
    storageAccountKind: storageAccountKind
  }
}
  
  //Create Application Insights 
module insights 'insights.bicep' = {
  name: 'app-insights-deployment'
  scope: rg
  params: {
    location: location
    appInsightsName: appInsightsName
  }
}

//SQL Server 
module sqldb 'sqldb.bicep' = {
  name: 'sql-server-deployment'
  scope: rg
  params: {
    sqlServerName: sqlServerName
    dbName: dbName
    dbUserName: dbUserName
    dbPassword: dbPassword
    location: location
  }
}

//CosmosDB and MongoDB
module cosmosDbModule 'cosmosdb.bicep' = {
  name: 'cosmos-db-deployment'
  scope: rg
  params: {
    cosmosAcctName: cosmosDbName
    location: location
  }
}


//module eventhub
module eventHubsModule 'eventhub.bicep' = {
  name: 'event-hub-deployment'
  scope: rg
  params: {
    eventHubNamespaceName: eventHubNamespaceName
    eventHubSku: eventHubSku
    eventHubBidTopicName: eventHubBidTopicName
    eventHubNotificationTopicName: eventHubNotificationTopicName
    eventHubPaymentTopicName: eventHubPaymentTopicName
    location: location
  }
}

//MySql 
module auctionDb 'mysql.bicep' = {
  name: 'mysql-db-deployment'
  scope: rg
  params: {
    location: location
    databaseForMySqlDBServerName: databaseForMySqlDBServerName
    databaseForMySqlAdminName: databaseForMySqlAdminName
    databaseForMySqlAdminPassword: databaseForMySqlAdminPassword
  }
}

output appInsightsInstrumentationKey string = insights.outputs.instrumentationKey
output eventHubPrimaryKey string = eventHubsModule.outputs.eventHubPrimaryKey
