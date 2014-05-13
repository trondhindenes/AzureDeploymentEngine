Function Assert-AzdeStorageAccount
{
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$Subscription,
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName
    )


    $ProjectName = $Project.ProjectName
    $ProjectStoragePrefix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "ProjectStoragePrefix" -SettingsType "ProjectSettings" -TargetObject "Project"
    $ProjectStorageSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "ProjectStorageSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    #$Location = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "Location" -SettingsType "ProjectSettings" -TargetObject "Project"

    $ActualStorageAccountName = $ProjectStoragePrefix + $ProjectName + $ProjectStorageSuffix
    $ActualStorageAccountName = $ActualStorageAccountName.Replace(" ","").ToLower()
    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Storage Account Name is: $ActualStorageAccountName"
    Enable-AzdeAzureSubscription -SubscriptionId ($Subscription.SubscriptionId)

    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Creating Storage Account: $ActualStorageAccountName into Affinity Group $AffinityGroupName"
    Invoke-StorageAccount -StorageAccountName $ActualStorageAccountName -AffinityGroup $AffinityGroupName -SubscriptionId ($Subscription.SubscriptionId)
    return $ActualStorageAccountName
}