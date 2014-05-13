Function Assert-AzdeDomainController
{
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$Subscription,
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName
    )


    $ProjectName = $Project.ProjectName
    $network = $Project.Network
    $networkname = $network.NetworkName
    $subnet = $network.Subnets[0]

    #Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Storage Account Name is: $ActualStorageAccountName"
    Enable-AzdeAzureSubscription -SubscriptionId ($Subscription.SubscriptionId)

    #Get the domain controller settings
    
    $DeployDomainControllersPerProject = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DeployDomainControllersPerProject" -SettingsType "ProjectSettings" -TargetObject "Project"
    if ($DeployDomainControllersPerProject)
    {
        Write-Verbose "Will deploy domain controller(s) for project"
    }
    Else
    {
        Return $null

    }

    $DomainController = New-Object AzureDeploymentEngine.Vm
    $DomainControllerPrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerPrefix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $DomainControllerSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $DomainController.VmName = $DomainControllerPrefix + $ProjectName + $DomainControllerSuffix

    Write-Verbose "Domain controller name: $($DomainController.VmName)"

    $domaincontroller.VmSettings = New-Object AzureDeploymentEngine.VmSetting
    $domaincontroller.VmSettings.Subnet = $subnet.subnet
    $domaincontroller.VmSettings.VmImage = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "VmImage" -SettingsType "VmSettings" -TargetObject "Project"
    $domaincontroller.VmSettings.WaitforVmDeployment = $true
    $domaincontroller.VmSettings.VmCount = 1
    $domaincontroller.VmSettings.AlwaysRedeploy = $false
    

    #Figure out the cloud service for the vm
    $CloudServiceName = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceName" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    $CloudServicePrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServicePrefix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    $CloudServiceSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceSuffix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    [AzureDeploymentEngine.Credential]$DcCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "CloudServiceSettings" -TargetObject "Project"

    if (!($cloudservicename))
    {    
        $cloudservicename = $cloudserviceprefix + $projectname + $cloudservicesuffix
        $cloudservicename = $cloudservicename.replace(" ","")
    }

    $domaincontroller.VmSettings.CloudServiceName = $CloudServiceName

    $domaincontroller.VmSettings.LocalAdminCredential = $dccredential


    Invoke-AzDeVirtualMachine -vm $DomainController -cloudservicename $cloudservicename -affinityGroupName $affinityGroupName
    
}