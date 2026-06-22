// AgentOps "Ship a Foundry prompt agent" tutorial — prerequisite infrastructure.
// Creates ONE Azure AI Foundry (AIServices) account hosting TWO projects
// (travel-agent-sandbox + travel-agent-dev) that SHARE one gpt-4o-mini deployment,
// plus workspace-based Application Insights attached to the dev project.
// Region: Sweden Central. Data-plane role assignments are applied separately via CLI.

targetScope = 'resourceGroup'

@description('Azure region for all resources.')
param location string = 'swedencentral'

@description('Globally-unique name (and custom subdomain) for the Foundry AIServices account.')
param accountName string = 'aifoundry-travelagent-${uniqueString(resourceGroup().id)}'

@description('Authoring/sandbox project name.')
param sandboxProjectName string = 'travel-agent-sandbox'

@description('Shared dev project name (CI bootstraps this).')
param devProjectName string = 'travel-agent-dev'

@description('Chat model deployment name — must be identical in both projects.')
param modelDeploymentName string = 'gpt-4o-mini'

@description('Model version for gpt-4o-mini in Sweden Central.')
param modelVersion string = '2024-07-18'

@description('Deployment SKU (throughput type).')
param modelSkuName string = 'GlobalStandard'

@description('Deployment capacity in units of 1000 TPM.')
param modelCapacity int = 100

@description('Log Analytics workspace name (backs Application Insights).')
param logAnalyticsName string = 'log-travelagent-${uniqueString(resourceGroup().id)}'

@description('Application Insights name (attached to the dev project).')
param appInsightsName string = 'appi-travelagent-${uniqueString(resourceGroup().id)}'

@description('Tags applied to all resources.')
param tags object = {
  project: 'agentops-travel-agent'
  purpose: 'agentops-prompt-agent-tutorial'
}

// ---------------------------------------------------------------------------
// Observability: Log Analytics + workspace-based Application Insights
// ---------------------------------------------------------------------------
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

// ---------------------------------------------------------------------------
// Foundry account (AIServices) with project management enabled
// ---------------------------------------------------------------------------
resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: accountName
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // Required for project management + token-based (AAD) data-plane auth.
    allowProjectManagement: true
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    // Keep account keys available — the ASSERT/LiteLLM step uses AZURE_API_KEY.
    disableLocalAuth: false
  }
}

// Shared chat model deployment (lives on the account, visible to both projects).
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
  parent: account
  name: modelDeploymentName
  sku: {
    name: modelSkuName
    capacity: modelCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: modelVersion
    }
  }
}

// ---------------------------------------------------------------------------
// Projects: sandbox (authoring) + dev (CI target)
// ---------------------------------------------------------------------------
resource sandboxProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: account
  name: sandboxProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: sandboxProjectName
    description: 'Authoring sandbox for the AgentOps travel-agent prompt agent.'
  }
}

resource devProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: account
  name: devProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: devProjectName
    description: 'Shared dev environment; bootstrapped by CI after merge.'
  }
}

// Attach Application Insights to the dev project (powers Traces + step 18).
resource devAppInsightsConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01' = {
  parent: devProject
  name: 'appinsights'
  properties: {
    category: 'AppInsights'
    target: appInsights.properties.ConnectionString
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: appInsights.properties.ConnectionString
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: appInsights.id
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs (used to paste endpoints in tutorial steps 7-8 and grant roles)
// ---------------------------------------------------------------------------
@description('Foundry AIServices account name.')
output accountName string = account.name

@description('Resource group of the account.')
output resourceGroupName string = resourceGroup().name

@description('Sandbox project endpoint (tutorial step 7).')
output sandboxProjectEndpoint string = 'https://${accountName}.services.ai.azure.com/api/projects/${sandboxProjectName}'

@description('Dev project endpoint (tutorial step 8).')
output devProjectEndpoint string = 'https://${accountName}.services.ai.azure.com/api/projects/${devProjectName}'

@description('Application Insights resource name.')
output appInsightsName string = appInsights.name

@description('Log Analytics workspace resource id (for the dev MI Reader grant).')
output logAnalyticsId string = logAnalytics.id

@description('Application Insights resource id (for the dev MI Reader grant).')
output appInsightsId string = appInsights.id

@description('System-assigned principal id of the sandbox project (grant OpenAI User).')
output sandboxProjectPrincipalId string = sandboxProject.identity.principalId

@description('System-assigned principal id of the dev project (grant OpenAI User + Reader).')
output devProjectPrincipalId string = devProject.identity.principalId

@description('System-assigned principal id of the account.')
output accountPrincipalId string = account.identity.principalId
