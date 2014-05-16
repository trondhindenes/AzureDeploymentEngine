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
    $vmimagename = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "VmImage" -SettingsType "VmSettings" -TargetObject "Project"
    if ($DeployDomainControllersPerProject)
    {
        Write-Verbose "Will deploy domain controller(s) for project"
    }
    Else
    {
        Return $null

    }

    $DomainController = New-Object AzureDeploymentEngine.Vm
    $DomainControllerName = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerName" -SettingsType "ProjectSettings" -TargetObject "Project"
    #$DomainControllerSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    if (!$DomainControllerName)
    {
        $DomainControllerName = $ProjectName + "DC"
    }
    
    $DomainController.VmName = $DomainControllerName.replace("projectname",$projectname)
    $DomainController.VmName = $DomainController.VmName.Replace(" ","")

    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Domain controller name: $($DomainController.VmName)"

    $domaincontroller.VmSettings = New-Object AzureDeploymentEngine.VmSetting
    $domaincontroller.VmSettings.Subnet = $subnet.subnetName
    $domaincontroller.VmSettings.VmImage = $VmImageName
    $domaincontroller.VmSettings.WaitforVmDeployment = $true
    $domaincontroller.VmSettings.VmCount = 1
    $domaincontroller.VmSettings.AlwaysRedeploy = $false
    $domaincontroller.VmSettings.VnetName = $Project.Network.NetworkName
    $domaincontroller.VmSettings.DataDiskSize = 5GB
    
    

    #Figure out the cloud service for the vm
    $CloudServiceName = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceName" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    
    if (!$CloudServiceName)
    {
        $CloudServiceName = $projectname
    }
    $CloudServiceName = $CloudServiceName.replace("projectname",$ProjectName)
    
    #$CloudServicePrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServicePrefix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    #$CloudServiceSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceSuffix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    [AzureDeploymentEngine.Credential]$DcCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
 
    
    $cloudservicename = $cloudservicename.replace(" ","")
    
    $domaincontroller.VmSettings.CloudServiceName = $CloudServiceName

    $domaincontroller.VmSettings.LocalAdminCredential = $dccredential


    $DCvm = Invoke-AzDeVirtualMachine -vm $DomainController -affinityGroupName $affinityGroupName
    
    if ($dcvm.AlreadyExistingVm)
    {
        #VM already existed. We should run some kind of verification script here.
    }
    
    $DCPostInstallScript = New-Object AzureDeploymentEngine.PostDeploymentScript
    $DCPostInstallScript.Path = "$psscriptroot\PostInstallScripts-content\FirstDCinstall.ps1"
    $DCPostInstallScript.VmNames = $domaincontroller.VmName
    $DCPostInstallScript.CloudServiceName = $DomainController.VmSettings.CloudServiceName
    #We send in the deployment as well. This thing contains stuff like credentials and such
    #$DCPostInstallScript.Deployment = $Deployment
    $dcpostinstallscript.PathType = "FileFromLocal"
    $dcpostinstallscript.RebootOnCompletion = $true


    invoke-PostDeploymentScript -PostDeploymentScript $DCPostInstallScript
}