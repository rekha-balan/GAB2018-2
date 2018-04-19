param(
 [string]$ServicePrincipalId = "<put your service principal id here>",

 [string]$ServicePrincipalKey = "<put your service principal key here>",

 [string]$TenatID = "<put your tenant id here>",

 [string]$resourceGroupName = "GAB-ARM",

 [string]$resourceGroupLocation = "EastUS",

 [string]$deploymentName = "GAB-ARM",

 [string]$templateFilePath = "C:\GAB2018\ARM\LinuxVM.json",

 [string]$parametersFilePath = "C:\GAB2018\ARM\params.json"
)

$ErrorActionPreference = "Stop"

Import-Module AzureRM
# sign in
Write-Host "Logging in...";
$creds = New-Object System.Management.Automation.PSCredential($ServicePrincipalId, (ConvertTo-SecureString $ServicePrincipalKey -AsPlainText -Force))
Connect-AzureRmAccount -ServicePrincipal -Credential $creds -TenantId $TenatID

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -Verbose;
}