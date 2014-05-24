
ipmo C:\Users\trohinde\Documents\Scripts\Powershell\ModuleDev\AzureDeploymentEngineJson\AzureDeploymentEngineJson.psm1 -Force

$deployment = New-AzdeDeployment -DeploymentName "CrayonF"
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
$DomainAdminCredential.Password = "Gulrik20161"

$project = New-AzdeProject -ProjectName "CrayonF"

$subscription | Add-AzdeProject -Project $project

$projectsettings = New-Object AzureDeploymentEngine.ProjectSetting
$projectsettings.Location = "West Europe"
$projectsettings.AffinityGroupName = "AG-projectname"
$projectsettings.DeployDomainControllersPerProject = $true
$projectsettings.DomainAdminCredential = $DomainAdminCredential
$projectsettings.AdDomainName =  "Crayonf.local"

#Storageaccount is 1-24 lowercase or numbers
$projectsettings.ProjectStorageAccountName = "projectnamestorage"
$project.ProjectSettings = $projectsettings

$cloudservicesettings = New-Object AzureDeploymentEngine.CloudServiceSetting
$cloudservicesettings.CloudServiceName = "projectname-cs"

$deployment.CloudServiceSettings = $cloudservicesettings

$network = New-Object AzureDeploymentEngine.network
$network.NetworkName = "smanet"
$network.AddressPrefix = "10.10.0.0/16"
$network.Subnets = New-Object AzureDeploymentEngine.Subnet
$network.Subnets[0].subnetName = "sn-10.10.50.0"
$network.Subnets[0].SubnetCidr = "10.10.50.0/24"
$project.Network = $network

$project.Vms = New-Object AzureDeploymentEngine.Vm
$project.Vms[0].VmName = "projectnameVM01"
$project.vms[0].vmsettings = New-Object AzureDeploymentEngine.VmSetting
$project.vms[0].VmSettings.AlwaysRerunScripts = $true

$project.vms.Add((new-object AzureDeploymentEngine.Vm))
$project.vms[1].VmName = "projectnameVM02"

#Save the config
$deployment | Save-AzdeDeploymentConfiguration -force -Verbose
$VerbosePreference = "Continue"
$verboselevel = 3

$deployment = Import-AzdeDeploymentConfiguration -Path "C:\Users\trohinde\Documents\AzureDeploymentEngine\CrayonF\CrayonF.json"

Invoke-AzdeDeployment -Deployment $deployment
