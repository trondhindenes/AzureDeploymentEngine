Function Assert-azdeAffinityGroup
{
    Param (
        [AzureDeploymentEngine.Project]$Project
    )


    $ProjectName = $Project.ProjectName
    $AGName = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "AffinityGroupName" -SettingsType "ProjectSettings" -TargetObject "Project"
    $AGSuffix = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "AffinityGroupSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $Location = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "Location" -SettingsType "ProjectSettings" -TargetObject "Project"

    if (!$AGName)
    {
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "I ended up with an empty Affinity Group Name. Using Project Name $($Project.ProjectName) for Affinity Group Name"
    }
    

    if (!$Location)
    {
        Write-Error "Ended up with an empty Location. I simply dont which datacenter to use for this project."
        Break
    }


    #case-insensitive replace
    $ActualAffinityGroupName = [AzureDeploymentEngine.StringExtensions]::Replace($AGName,"projectname",$projectname,"OrdinalIgnoreCase")
    
    $ActualAffinityGroupName = $ActualAffinityGroupName.Replace(" ","")
    Enable-AzdeAzureSubscription -SubscriptionId ($Project.Subscription.SubscriptionId)

    Invoke-AffinityGroup -AffinityGroupName $ActualAffinityGroupName -Location $Location -SubscriptionId ($Subscription.SubscriptionId)
    return $ActualAffinityGroupName
}