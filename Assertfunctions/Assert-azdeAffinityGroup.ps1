Function Assert-azdeAffinityGroup
{
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$Subscription,
        [AzureDeploymentEngine.Project]$Project
    )


    $ProjectName = $Project.ProjectName
    $AGPrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "AffinityGroupPrefix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $AGSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "AffinityGroupSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $Location = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "Location" -SettingsType "ProjectSettings" -TargetObject "Project"

    if (!$Location)
    {
        Write-Error "Ended up with an empty Location. I simply dont which datacenter to use for this project."
        Break
    }



    $ActualAffinityGroupName = $AGPrefix + $ProjectName + $AGSuffix
    $ActualAffinityGroupName = $ActualAffinityGroupName.Replace(" ","")
    Enable-AzdeAzureSubscription -SubscriptionId ($Subscription.SubscriptionId)

    Invoke-AffinityGroup -AffinityGroupName $ActualAffinityGroupName -Location $Location -SubscriptionId ($Subscription.SubscriptionId)
    return $ActualAffinityGroupName
}