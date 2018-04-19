param
(
    [Parameter(HelpMessage="Enter Azure Subscription name. You need to be Subscription Admin to execute the script")]
    [string] $subscriptionName='<your subscription name>',

    [Parameter(HelpMessage="Provide a password for SPN application that you would create")]
    [string] $password='<put some pass here. will used as service principal key>',

    [Parameter(HelpMessage="Provide a SPN role assignment")]
    [string] $spnRole = "owner",
    
    [Parameter(HelpMessage="Provide Azure environment name for your subscription")]
    [string] $environmentName = "AzureCloud",

    [Parameter(HelpMessage="Provide name of registered application")]
    [string] $AppDisplayName = "Test_connection"
)

#Initialize
$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"
$userName = $env:USERNAME
$displayName = $AppDisplayName
$homePage = "http://" + $displayName
$identifierUri = $homePage


#Initialize subscription
$isAzureModulePresent = Get-Module -Name AzureRM* -ListAvailable
if ([String]::IsNullOrEmpty($isAzureModulePresent) -eq $true)
{
    Write-Output "Script requires AzureRM modules to be present. Obtain AzureRM from https://github.com/Azure/azure-powershell/releases. Please refer https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/DeployAzureResourceGroup/README.md for recommended AzureRM versions." -Verbose
    return
}

Import-Module -Name AzureRM.Profile
Write-Output "Provide your credentials to access Azure subscription $subscriptionName" -Verbose
Login-AzureRmAccount -SubscriptionName $subscriptionName -EnvironmentName $environmentName
$azureSubscription = Get-AzureRmSubscription -SubscriptionName $subscriptionName
$connectionName = $azureSubscription.Name
$tenantId = $azureSubscription.TenantId
$id = $azureSubscription.Id


#Create a new AD Application
Write-Output "Creating a new Application in AAD (App URI - $identifierUri)" -Verbose
$secPass = ConvertTo-SecureString $password -AsPlainText -Force
$azureAdApplication = New-AzureRmADApplication -DisplayName $displayName -HomePage $homePage -IdentifierUris $identifierUri -Password $secPass -Verbose
$appId = $azureAdApplication.ApplicationId
Write-Output "Azure AAD Application creation completed successfully (Application Id: $appId)" -Verbose


#Create new SPN
Write-Output "Creating a new SPN" -Verbose
$spn = New-AzureRmADServicePrincipal -ApplicationId $appId
$spnName = $spn.ServicePrincipalName
Write-Output "SPN creation completed successfully (SPN Name: $spnName)" -Verbose


#Assign role to SPN
Write-Output "Waiting for SPN creation to reflect in Directory before Role assignment"
Start-Sleep 20
Write-Output "Assigning role ($spnRole) to SPN App ($appId)" -Verbose
New-AzureRmRoleAssignment -RoleDefinitionName $spnRole -ServicePrincipalName $appId
Write-Output "SPN role assignment completed successfully" -Verbose


#Print the values
Write-Output "`nCopy and Paste below values for Service Connection" -Verbose
Write-Output "***************************************************************************"
Write-Output "Connection Name: $connectionName(SPN)"
Write-Output "Subscription Id: $id"
Write-Output "Subscription Name: $connectionName"
Write-Output "Service Principal Id: $appId"
Write-Output "Service Principal key: $password"
Write-Output "Tenant Id: $tenantId"
Write-Output "***************************************************************************"