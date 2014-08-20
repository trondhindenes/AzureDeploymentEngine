Function Assert-AzdeDomainController
{
    Param (
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName
    )


    $ProjectName = $Project.ProjectName
    $network = $Project.Network
    $networkname = $network.NetworkName
    $subnet = $network.Subnets[0]

    #Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Storage Account Name is: $ActualStorageAccountName"
    Enable-AzdeAzureSubscription -SubscriptionId ($Project.Subscription.SubscriptionId)

    #Get the domain controller settings
    
    $DeployDomainControllersPerProject = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DeployDomainControllersPerProject" -SettingsType "ProjectSettings" -TargetObject "Project"
    $vmimagename = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "VmImage" -SettingsType "VmSettings" -TargetObject "Project"
    if ($DeployDomainControllersPerProject)
    {
        Write-Verbose "Will deploy domain controller(s) for project"
    }
    Else
    {
        Return $null

    }

    
    #Get the domain settings
    if (!($Project.ProjectSettings.AdDomainName))
    {
        $Project.ProjectSettings.AdDomainName = $projectname.Replace(" ","")
        $Project.ProjectSettings.AdDomainName = $Project.ProjectSettings.AdDomainName + ".ad"
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "setting AD domain name to $($Project.ProjectSettings.AdDomainName)"
    }

    $azdeAdDomainName = $project.ProjectSettings.AdDomainName

    $DomainController = New-Object AzureDeploymentEngine.Vm
    $DomainControllerName = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerName" -SettingsType "ProjectSettings" -TargetObject "Project"
    #$DomainControllerSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainControllerSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    if (!$DomainControllerName)
    {
        $DomainControllerName = $ProjectName + "DC"
    }
    
    #Case-insensitive string replace
    $DomainController.VmName = [AzureDeploymentEngine.StringExtensions]::Replace($DomainControllerName,"projectname",$projectname,"OrdinalIgnoreCase")
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
    $CloudServiceName = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceName" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    
    if (!$CloudServiceName)
    {
        $CloudServiceName = $projectname
    }
    $CloudServiceName = $CloudServiceName.replace("projectname",$ProjectName)
    
    #$CloudServicePrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServicePrefix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    #$CloudServiceSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceSuffix" -SettingsType "CloudServiceSettings" -TargetObject "Project"
    [AzureDeploymentEngine.Credential]$DcCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
 
    
    $cloudservicename = $cloudservicename.replace(" ","")
    
    $domaincontroller.VmSettings.CloudServiceName = $CloudServiceName

    $domaincontroller.VmSettings.LocalAdminCredential = $dccredential

    $DomainController.VmSettings.StartIfStopped = $true


    $DCvm = Invoke-AzDeVirtualMachine -vm $DomainController -affinityGroupName $affinityGroupName
    
    $InstallDC = $false

    if ($dcvm.AlreadyExistingVm)
    {
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "DC already existed, Running verification script"
        #VM already existed. Run verification script
        $DCPostInstallScript = New-Object AzureDeploymentEngine.PostDeploymentScript
        $DCPostInstallScript.Path = "$modulefolderpath\PostDeploymentScripts-content\DCVerification.ps1"
        $DCPostInstallScript.Vms = $DomainController
        $DCPostInstallScript.CloudServiceName = $DomainController.VmSettings.CloudServiceName
        #We send in the deployment as well. This thing contains stuff like credentials and such
        #$DCPostInstallScript.Deployment = $Deployment
        $dcpostinstallscript.PathType = "FileFromLocal"
        $dcpostinstallscript.RebootOnCompletion = $false

        invoke-PostDeploymentScript -PostDeploymentScript $DCPostInstallScript -ErrorVariable verificationfailed -ErrorAction SilentlyContinue
        if ($verificationfailed)
        {
            #Verificatino threw an error, attempt installing the DC
            Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Verification failed, calling DC install script"
            $InstallDC = $true
        }
    }
    Else
    {
        $InstallDC = $true

    }

    if ($InstallDC)
    {
        $DCPostInstallScript = New-Object AzureDeploymentEngine.PostDeploymentScript
        $DCPostInstallScript.Path = "$modulefolderpath\PostDeploymentScripts-content\FirstDCinstall.ps1"
        $DCPostInstallScript.Vms = $DomainController
        $DCPostInstallScript.CloudServiceName = $DomainController.VmSettings.CloudServiceName
        #We send in the deployment as well. This thing contains stuff like credentials and such
        #$DCPostInstallScript.Deployment = $Deployment
        $dcpostinstallscript.PathType = "FileFromLocal"
        $dcpostinstallscript.RebootOnCompletion = $true
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "running DC install script"
        invoke-PostDeploymentScript -PostDeploymentScript $DCPostInstallScript

        #Set the network's DNS server to the ip address of the DC
        $dcvm = Get-AzureVM -Name $DomainController.VmName -ServiceName $DomainController.VmSettings.CloudServiceName
        Add-AzureANDnsServerConfiguration -Name $azdeAdDomainName -IpAddress $dcvm.IpAddress -VNetName $networkname
    }
    
    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "DC should be up and running at this point"
}