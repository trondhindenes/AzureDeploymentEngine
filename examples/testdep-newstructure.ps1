$project = New-AzdeProject -ProjectName "TrondCloud"
$project.ProjectSettings = New-Object AzureDeploymentEngine.ProjectSetting
$pjsettings = $project.projectSettings
$pjsettings.AdDomainName = "trondcloud.hindenes.com"
$pjsettings.ProjectStorageAccountName = "projectnamestorage"
$pjsettings.AffinityGroupName = "AG-projectname"
$pjsettings.Location = "West Europe"
$pjsettings.DeployDomainControllersPerProject = $true
$pjsettings.DomainAdminCredential = new-object AzureDeploymentEngine.Credential
$pjsettings.DomainAdminCredential.CredentialType = [AzureDeploymentEngine.CredentialType]::ClearText
$pjsettings.DomainAdminCredential.UserName = "thadministrator"
$pjsettings.DomainAdminCredential.Password = "Password123456"


$project.VmSettings = new-object AzureDeploymentEngine.VmSetting
$pjvms = $project.VmSettings
$pjvms.VmImage = "Windows Server 2012 R2 Datacenter"
$pjvms.VmSize = "Small"
$pjvms.JoinDomain = $true
$pjvms.WaitforVmDeployment = $true
$pjvms.startifstopped = $true

$project.CloudServiceSettings = new-object AzureDeploymentEngine.CloudServiceSetting
$pjcs = $project.CloudServiceSettings
$pjcs.CloudServiceName = "projectname-cs"

$project.Vms = New-Object AzureDeploymentEngine.Vm
$vm1 = $project.Vms[0]
$vm1.VmName = "projectnameVM01"

$project.Subscription = new-object AzureDeploymentEngine.Subscription
$project.Subscription.SubscriptionDisplayName = "Visual Studio Premium with MSDN"
$project.Subscription.SubscriptionId = "2ee69600-66dc-43b9-8ffe-c813f9f9c281"

$project.Network = new-object AzureDeploymentEngine.network
$project.Network.NetworkName = "TrondCloudNet"
$project.Network.AddressPrefix = "10.10.0.0/16"
$project.Network.Subnets = New-Object AzureDeploymentEngine.Subnet
$project.Network.Subnets[0].SubnetCidr = "10.10.50.0/24"
$project.Network.Subnets[0].subnetName = "sn-10.10.50.0"

