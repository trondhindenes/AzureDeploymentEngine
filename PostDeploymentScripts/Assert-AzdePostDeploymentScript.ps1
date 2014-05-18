Function Assert-azdePostDeploymentScript
{
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$Subscription,
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName,
        $vms,
        $storageaccount
    )

    #Get the post deployment scripts
    $PDscripts = $Project.PostDeploymentScripts
    $pdscripts = $PDscripts | Sort-Object Order

    #Foreach Script, get the VMs
    foreach ($pdscript in $PDscripts)
    {
        $pdscriptname = $pdscript.PostDeploymentScriptName
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Executing Post-Deployment script $pdscriptname"
        
        #get the vmlist
        $pdscriptvms = $pdscript.VmNames
        foreach ($pdscriptvm in $pdscriptvms)
        {
            #If the VMs were already existing, check if the script is set to always rerun    
            $vmrealname = $pdscriptvm.replace("projectname",$project.ProjectName)
            
            $vm = $Project.Vms | where {($_.VmName.replace("projectname",$project.ProjectName)) -eq $vmrealname}
            $jsonvm = $vm | ConvertTo-Json -Depth 10
            $vmobject = Import-AzdeVMConfiguration -string $jsonvm
            $vmobject.VmName = $vmrealname
            $deployedvm = $vms | where {$_.Name -eq $vmrealname}
            $scriptReRunsetting = $vmobject.VmSettings.AlwaysRerunScripts

            if (!($vmobject.VmSettings))
            {
                $vmobject.VmSettings = New-Object AzureDeploymentEngine.VmSetting
            }

            #If credentials arent set on the vm, get them from cascading project settings
            if (!($vmobject.VmSettings.DomainJoinCredential))
            {
                $vmobject.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainJoinCredential" -SettingsType "VmSettings" -TargetObject "Project"
            }

            if (!($vmobject.VmSettings.LocalAdminCredential))
            {
                $vmobject.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "LocalAdminCredential" -SettingsType "VmSettings" -TargetObject "Project"
            }

            #If credentials are still empty, use the project's domain admin credentials
            if (!($vmobject.VmSettings.DomainJoinCredential))
            {
                $vmobject.VmSettings.DomainJoinCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
            }

            if (!($vmobject.VmSettings.LocalAdminCredential))
            {
                $vmobject.VmSettings.LocalAdminCredential = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "DomainAdminCredential" -SettingsType "ProjectSettings" -TargetObject "Project"
            }



            #If this setting isnt set (not true, not false), look in cascading settings
            if ($scriptReRunsetting -eq $null)
            {
                $scriptReRunsetting = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "AlwaysRerunScripts" -SettingsType "VmSettings" -TargetObject "Project"
                if ($scriptReRunsetting -eq $null)
                {
                    $scriptReRunsetting = $false
                }
            }

            $DoRunScript = $false


            if ($deployedvm.AlreadyExistingVm)
            {
                if ($scriptReRunsetting -eq $false)
                {
                    #VM was existing, and vm not set to always rerun scripts. Skipping
                    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "VM $vmrealname was already existing, and not set to always rerun scripts. Skipping script execution"
                }
                Else
                {
                    $DoRunScript = $true
                }
            }
            Else
            {
                $DoRunScript = $true  
            }

            #fireup all the things
            if ($DoRunScript)
            {
                #Invoke script execution
                $thispds = New-Object AzureDeploymentEngine.PostDeploymentScript
                $thispds.PostDeploymentScriptName = $pdscriptname
                $thispds.VMs = $vmobject
                $thispds.Path = $pdscript.Path
                $thispds.PathType = $pdscript.PathType
                $thispds.RebootOnCompletion = $pdscript.RebootOnCompletion
                $thispds.CloudServiceName = $Deployedvm.ServiceName
                
                Invoke-PostDeploymentScript -PostDeploymentScript $thispds -storageaccount $storageaccount
            }

            
        }
    
    }



    

    



}