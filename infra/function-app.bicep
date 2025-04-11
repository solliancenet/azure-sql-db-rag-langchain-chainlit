// Creates an Azure Function App with a Storage Account, Log Analytics workspace, and Application Insights.

@description('The Azure region to deploy the resources.')
param location string = resourceGroup().location

@description('The name of the Function App Service Plan.')
param functionAppServicePlanName string

@description('The name of the Azure Function App.')
param functionAppName string

@description('The name of the Azure Log Analytics workspace.')
param logAnalyticsName string

@description('The name of the Azure Application Insights resource.')
param appInsightsName string

@description('The name of the Azure Storage account.')
param storageAccountName string

@description('Tags to assign to the Azure OpenAI resource.')
param tags object = {}

@description('Creates an Azure Storage account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  tags: tags
}

@description('Creates an Azure Log Analytics workspace.')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
  tags: tags
}

@description('Creates an Azure Application Insights resource.')
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: tags
}

@description('Creates an Azure Function App Service Plan.')
resource functionAppServicePlan 'Microsoft.Web/serverFarms@2022-09-01' = {
  name: functionAppServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
  tags: tags
}

@description('Creates an Azure Function App.')
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: functionAppServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
    }
    httpsOnly: true
    virtualNetworkSubnetId: null
    publicNetworkAccess: 'Enabled'
    clientAffinityEnabled: false
  }
  tags: tags
}
