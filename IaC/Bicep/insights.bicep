@description('Primary location for resources')
param location string = resourceGroup().location

param appInsightsName string

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
  kind: 'web'
}

output instrumentationKey string = insights.properties.InstrumentationKey
