$items = (get-item "D:\trond.hindenes\Documents\Visual Studio 2013\Projects\AzureDeploymentEngine\AzureDeploymentEngine\bin\Debug\AzureDeploymentEngine.dll"),
(get-item "D:\trond.hindenes\Documents\Visual Studio 2013\Projects\AzureDeploymentEngine\AzureDeploymentEngine\bin\Debug\Newtonsoft.Json.dll")

$items | Copy-Item -Destination D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\dlls -Force

if (Get-Module AzureDeploymentEngineJson){Remove-Module AzureDeploymentEngineJson}

ipmo "D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psd1" -force
#ipmo C:\Users\trohinde\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psm1 -Force

#Update-Module azuredeploymentenginejson

$deployment = New-AzdeDeployment -DeploymentName "TestDepl"
$subscription = new-AzdeSubscription -AzureSubscription (Get-AzureSubscription -SubscriptionName JHEMSDN -ErrorAction stop)
$deployment | Add-AzdeSubscription -Subscription $subscription

$depvmsettings = new-object AzureDeploymentEngine.VmSetting
$depvmsettings.VmImage = "Windows Server 2012 R2 Datacenter"
$depvmsettings.VmSize = "Small"
$depvmsettings.JoinDomain = $true
$depvmsettings.AlwaysRerunScripts = $true

$deployment.VmSettings = $depvmsettings


$DomainAdminCredential = New-Object AzureDeploymentEngine.Credential
$DomainAdminCredential.CredentialType = "ClearText"
$DomainAdminCredential.UserName = "thadministrator"
$DomainAdminCredential.Password = "Password12345"



$project = New-AzdeProject -ProjectName "thtest1"

$subscription | Add-AzdeProject -Project $project

$projectsettings = New-Object AzureDeploymentEngine.ProjectSetting
$projectsettings.Location = "West Europe"
$projectsettings.AffinityGroupName = "AG-projectname"
$projectsettings.DeployDomainControllersPerProject = $true
$projectsettings.DomainAdminCredential = $DomainAdminCredential
$projectsettings.AdDomainName =  "ad.thlab.local"

#Storageaccount is 1-24 lowercase or numbers
$projectsettings.ProjectStorageAccountName = "projectnamestorage"

$project.ProjectSettings = $projectsettings


$cloudservicesettings = New-Object AzureDeploymentEngine.CloudServiceSetting
$cloudservicesettings.CloudServiceName = "projectname-cs"

$deployment.CloudServiceSettings = $cloudservicesettings


$network = New-Object AzureDeploymentEngine.network
$network.NetworkName = "VNET1"
$network.AddressPrefix = "10.10.0.0/16"
$network.Subnets = New-Object AzureDeploymentEngine.Subnet
$network.Subnets[0].subnetName = "sn-10.10.50.0"
$network.Subnets[0].SubnetCidr = "10.10.50.0/24"
$project.Network = $network

$project.Vms = New-Object AzureDeploymentEngine.Vm
$project.Vms[0].VmName = "projectnameVM01"
$project.vms.Add((new-object AzureDeploymentEngine.Vm))
$project.vms[1].VmName = "projectnameVM02"

$pdscript = New-Object AzureDeploymentEngine.PostDeploymentScript
$pdscript.Order = 1
$pdscript.Path = "D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\PostDeploymentScripts-examples\iis.ps1"
$pdscript.PathType = "ScriptFromLocal"
$pdscript.VmNames= "projectnameVM01","projectnameVM02"
$pdscript.PostDeploymentScriptName = "Install IIS n stuff"

$project.PostDeploymentScripts = $pdscript





$deployment | Save-AzdeDeploymentConfiguration -force -Verbose
$VerbosePreference = "Continue"
$verboselevel = 3

ipmo "D:\trond.hindenes\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psd1" -force
#ipmo C:\Users\trohinde\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psm1 -Force
Invoke-AzdeDeployment -Deployment $deployment -SkipDomainController

$deployment2 = Import-AzdeDeploymentConfiguration -Path "D:\trond.hindenes\Documents\AzureDeploymentEngine\TestDepl\TestDepl.json"