$items = (get-item "D:\trond.hindenes\Documents\Visual Studio 2013\Projects\AzureDeploymentEngine\AzureDeploymentEngine\bin\Debug\AzureDeploymentEngine.dll"),
(get-item "D:\trond.hindenes\Documents\Visual Studio 2013\Projects\AzureDeploymentEngine\AzureDeploymentEngine\bin\Debug\Newtonsoft.Json.dll")

$items | Copy-Item -Destination D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\dlls -Force

if (Get-Module AzureDeploymentEngineJson){Remove-Module AzureDeploymentEngineJson}

ipmo "D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psd1"


#Update-Module azuredeploymentenginejson

$deployment = New-AzdeDeployment -DeploymentName "TestDepl"
$subscription = new-AzdeSubscription -AzureSubscription (Get-AzureSubscription -Current)
$deployment | Add-AzdeSubscription -Subscription $subscription

$depvmsettings = new-object AzureDeploymentEngine.VmSetting
$depvmsettings.VmImage = "WIndows Server 2012R2"

$deployment.VmSettings = $depvmsettings

$DomainAdminCredential = New-Object AzureDeploymentEngine.Credential
$DomainAdminCredential.CredentialType = "ClearText"
$DomainAdminCredential.UserName = "thadministrator"
$DomainAdminCredential.Password = "Password12345"



$project = New-AzdeProject -ProjectName "My Test Project"

$subscription | Add-AzdeProject -Project $project

$projectsettings = New-Object AzureDeploymentEngine.ProjectSetting
$projectsettings.Location = "West Europe"
$projectsettings.AffinityGroupPrefix = "AG-"
$projectsettings.AffinityGroupSuffix = ""
$projectsettings.DeployDomainControllersPerProject = $true
$projectsettings.DomainAdminCredential = $DomainAdminCredential

$project.ProjectSettings = $projectsettings



$vmsettings1 = New-AzdeVmSettings -AlwaysRedeploy $false -vmimage "Windows Server 2012R2"
$vmsettings2 = New-AzdeVmSettings -AlwaysRedeploy $true




$deployment.VmSettings = $vmsettings1
$project.VmSettings = $vmsettings2

$cloudservicesettings = New-Object AzureDeploymentEngine.CloudServiceSetting
$cloudservicesettings.CloudServicePrefix = "cs-"
$cloudservicesettings.CloudServiceSuffix = "-svc"

$deployment.CloudServiceSettings = $cloudservicesettings

$network = New-Object AzureDeploymentEngine.network
$network.NetworkName = "VNET1"
$network.AddressPrefix = "10.10.0.0/16"
$network.Subnets = New-Object AzureDeploymentEngine.Subnet
$network.Subnets[0].subnet = "10.10.0.10/24"

$project.Network = $network

$deployment | Save-AzdeDeploymentConfiguration -force
$VerbosePreference = "Continue"
$verboselevel = 3
Invoke-AzdeDeployment -Deployment $deployment

$deployment2 = Import-AzdeDeploymentConfiguration -Path "D:\trond.hindenes\Documents\AzureDeploymentEngine\TestDepl\TestDepl.json"