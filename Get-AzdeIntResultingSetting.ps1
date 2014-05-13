Function Get-AzdeIntResultingSetting
{
    Param (
        $settingsAttribute,
        $SettingsType,
        $TargetObject,
        $ProjectName,
        $vmname,
        $SubscriptionId,
        $deployment
    )

    $ThisVerboseLevel = 3

    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "Command: Get-AzdeIntResultingSetting"

    #DeploymentSetting
    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      Getting settings for attribute: $settingsattribute"
    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      Settingstype: $SettingsType"
    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      TargetObject: $TargetObject"
    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      ProjectName: $ProjectName"
    
    $Setting = $deployment.$SettingsType.$settingsAttribute
    
    Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      Deployment Level: $Setting"


    if (($TargetObject -ne "Deployment"))
    {
        $subscription = $deployment.Subscriptions | where {$_.SubscriptionId -eq $SubscriptionId}
        $TestSetting = $subscription.$SettingsType.$settingsAttribute
        if ($TestSetting) {
            $Setting =$TestSetting
            Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      Subscription Level: $Setting"
            }
        
    }

    if (($TargetObject -ne "Subscription"))
    {
        $project = $subscription.Projects | where {$_.ProjectName -eq $ProjectName}
        $TestSetting = $project.$SettingsType.$settingsAttribute
        if ($TestSetting) {
            $Setting =$TestSetting
            Write-enhancedVerbose -MinimumVerboseLevel $ThisVerboseLevel -Message "      Project Level: $Setting"
            }
        
    }

    if ($TargetObject -ne "Project")
    {
        #At this point, the target could be vm
        $vm = $project.Vms | where {$_.VMName -eq $VMName}
        $TestSetting = $vm.$SettingsType.$settingsAttribute
        if ($TestSetting) {$Setting =$TestSetting}
    }

    $Setting


}