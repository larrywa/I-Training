@description('Primary location for resources')
param location string = resourceGroup().location
param eventHubNamespaceName string
param eventHubSku string
param eventHubBidTopicName string
param eventHubNotificationTopicName string
param eventHubPaymentTopicName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

resource bidTopic 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubBidTopicName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource notificationTopic 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubNotificationTopicName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource paymentTopic 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubPaymentTopicName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

#disable-next-line outputs-should-not-contain-secrets // Need to export for another script
output eventHubPrimaryKey string = listKeys(
  resourceId(
    'Microsoft.EventHub/namespaces/authorizationRules', 
    eventHubNamespaceName, 
    'RootManageSharedAccessKey'
  ), 
  '2018-01-01-preview'
).primaryKey



