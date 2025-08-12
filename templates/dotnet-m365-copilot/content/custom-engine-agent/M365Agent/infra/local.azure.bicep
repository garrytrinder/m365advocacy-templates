@maxLength(20)
@minLength(4)
@description('Used to generate names for all resources in this file')
param resourceBaseName string

@maxLength(42)
param botDisplayName string

param botServiceName string = resourceBaseName
param botServiceSku string = 'F0'
param botEntraAppClientId string
param botEntraAppTenantId string
param botAppDomain string
param graphEntraAppClientId string
param graphEntraAppTenantId string
@secure()
param graphEntraAppClientSecret string

resource botService 'Microsoft.BotService/botServices@2022-09-15' = {
  kind: 'azurebot'
  location: 'global'
  name: botServiceName
  properties: {
    displayName: botDisplayName
    endpoint: 'https://${botAppDomain}/api/messages'
    msaAppId: botEntraAppClientId
    msaAppTenantId: botEntraAppTenantId
    msaAppType: 'SingleTenant'
    tenantId: botEntraAppTenantId
    disableLocalAuth: false
  }
  sku: {
    name: botServiceSku
  }
}

resource botServiceMsTeamsChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
  parent: botService
  location: 'global'
  name: 'MsTeamsChannel'
  properties: {
    channelName: 'MsTeamsChannel'
  }
}

resource botServiceMicrosoftGraphConnection 'Microsoft.BotService/botServices/connections@2022-09-15' = {
  parent: botService
  name: 'Microsoft Graph'
  location: 'global'
  properties: {
    serviceProviderDisplayName: 'Azure Active Directory v2'
    serviceProviderId: '30dd229c-58e3-4a48-bdfd-91ec48eb906c'
    clientId: graphEntraAppClientId
    clientSecret: graphEntraAppClientSecret
    scopes: 'email offline_access openid profile User.Read'
    parameters: [
      {
        key: 'tenantID'
        value: graphEntraAppTenantId
      }
      {
        key: 'tokenExchangeUrl'
        value: 'api://${botAppDomain}/botid-${botEntraAppClientId}'
      }
    ]
  }
}