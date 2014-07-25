Function Assert-azdeVirtualMachine
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
    Enable-AzdeAzureSubscription -SubscriptionId ($project.Subscription.SubscriptionId)

    $deployvms = @()

    Foreach ($originalvm in $project.Vms)
    {
        #Create a copy of the vm to not disturb the original objects
        $vmjsonstring = $originalvm | convertto-json -Depth 10
        $vm = Import-AzdeVMConfiguration -string $vmjsonstring

        $vm.VmName = $vm.VmName.replace("projectname",$ProjectName)
        $vmname = $vm.VmName
       
       #If VM doesnt come with vmsettings, add a settings object
       if (!($vm.vmsettings))
       {
        $vm.vmsettings = New-Object AzureDeploymentEngine.VmSetting
       }

        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Deploying vm $vmname"
        if (!($vm.VmSettings.VmImage))
        {
            $vm.VmSettings.VmImage = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "VmImage" -SettingsType "VmSettings" -TargetObject "Project"
            Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Deploying vm from image $($vm.VmSettings.vmimage)"

        }
        
        if (!($vm.VmSettings.CloudServiceName))
        {
            $vm.VmSettings.CloudServiceName = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "CloudServiceName" -SettingsType "CloudServiceSettings" -TargetObject "Project"
        }
        $vm.VmSettings.CloudServiceName = $vm.VmSettings.CloudServiceName.replace("projectname",$ProjectName)
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Deploying vm into cloud service $($vm.VmSettings.CloudServiceName)"

        if (!($vm.VmSettings.Subnet))
        {
            $vm.VmSettings.Subnet = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "Subnet" -SettingsType "VmSettings" -TargetObject "Project"
        }
        if (!($vm.VmSettings.Subnet))
        {
            $vm.VmSettings.Subnet = $subnet.subnetName
        }
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Deploying vm into subnet $($vm.VmSettings.Subnet)"

        if (!($vm.VmSettings.JoinDomain))
        {
            $vm.VmSettings.JoinDomain = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "JoinDomain" -SettingsType "VmSettings" -TargetObject "Project"
        
        }
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Setting domainjoin attribute to $($vm.VmSettings.JoinDomain)"
        
        if (!($vm.VmSettings.StartIfStopped))
        {
            $vm.VmSettings.StartIfStopped = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "StartIfStopped" -SettingsType "VmSettings" -TargetObject "Project"
        
        }
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Setting domainjoin attribute to $($vm.VmSettings.JoinDomain)"
        

        if (!($vm.VmSettings.VMSize))
        {
            $vm.VmSettings.VMSize = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "VMSize" -SettingsType "VmSettings" -TargetObject "Project"
        }



        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Setting vmsize $($vm.VmSettings.VMSize)"

        $vm.VmSettings.VnetName = $networkname
        
        if (!($vm.VmSettings.WaitforVmDeployment))
        {
            $vm.VmSettings.WaitforVmDeployment = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "WaitforVmDeployment" -SettingsType "VmSettings" -TargetObject "Project"
        }
        #If nothing is specified, we will wait for VM deployment
        if (!($vm.VmSettings.WaitforVmDeployment))
        {
            $vm.VmSettings.WaitforVmDeployment = $true
        }

        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Setting WaitforVmDeployment attribute to $($vm.VmSettings.WaitforVmDeployment)"


        if (!($vm.VmSettings.AlwaysRedeploy))
        {
            $vm.VmSettings.AlwaysRedeploy = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "AlwaysRedeploy" -SettingsType "VmSettings" -TargetObject "Project"
        }
        #If nothing is specified, wwe will never redeploy
        if (!($vm.VmSettings.AlwaysRedeploy))
        {
            $vm.VmSettings.AlwaysRedeploy = $false
        }

        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Setting AlwaysRedeploy attribute to $($vm.VmSettings.AlwaysRedeploy)"

        if (!($vm.VmSettings.DomainJoinCredential))
        {
            $vm.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainJoinCredential" -SettingsType "VmSettings" -TargetObject "Project"
        }

        if (!($vm.VmSettings.LocalAdminCredential))
        {
            $vm.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "LocalAdminCredential" -SettingsType "VmSettings" -TargetObject "Project"
        }

        #If credentials are still empty, use the project's domain admin credentials
        if (!($vm.VmSettings.DomainJoinCredential))
        {
            $vm.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
        }

        if (!($vm.VmSettings.LocalAdminCredential))
        {
            $vm.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
        }

        $vmDeploy = Invoke-AzDeVirtualMachine -vm $vm -affinityGroupName $affinityGroupName
        $deployvms += $vmDeploy



    }
    #returnz the stufz
    $deployvms
}