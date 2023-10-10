param cosmosAcctName string
@description('Primary location for resources')
param location string = resourceGroup().location

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: cosmosAcctName
  location: location
  kind: 'MongoDB'
  tags: {
    defaultExperience: 'MongoDB'
  }
  properties: {
    locations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
  }
}

resource cosmosDbBidDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-08-15' = {
  parent: cosmosDb
  name: 'biddb'
  properties: {
    resource: {
      id: 'biddb'
    }
  }
}

resource cosmosDbBidCollection 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2022-08-15' = {
  parent: cosmosDbBidDatabase
  name: 'bids'
  properties: {
    resource: {
      id: 'bids'
      shardKey: {
        bidid: 'Hash'
      }
      indexes: [
        {
          key: {
            keys: [
              '_id'
            ]
          }
        }, {
          key: {
            keys: [
              'bidid'
            ]
          }
          options: {
            unique: true
          }
        }
      ]
    }
  }
}
