Function Assert-AzdeStorageAccount
{
    Param (
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName
    )


    $ProjectName = $Project.ProjectName
    $ProjectStorageAccountName = Get-AzdeIntResultingSetting -ProjectName ($Project.ProjectName) -settingsAttribute "ProjectStorageAccountName" -SettingsType "ProjectSettings" -TargetObject "Project"
    #$ProjectStorageSuffix = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "ProjectStorageSuffix" -SettingsType "ProjectSettings" -TargetObject "Project"
    #$Location = Get-AzdeIntResultingSetting -deployment $Deployment -SubscriptionId ($Subscription.SubscriptionId) -ProjectName ($Project.ProjectName) -settingsAttribute "Location" -SettingsType "ProjectSettings" -TargetObject "Project"

    #Case-insensitive string replace
    $ActualStorageAccountName = [AzureDeploymentEngine.StringExtensions]::Replace($ProjectStorageAccountName,"projectname",$projectname,"OrdinalIgnoreCase")
    $ActualStorageAccountName = $ProjectStorageAccountName.Replace("projectname",($project.ProjectName))
    $ActualStorageAccountName = $ActualStorageAccountName.Replace(" ","").ToLower()
    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Storage Account Name is: $ActualStorageAccountName"
    Enable-AzdeAzureSubscription -SubscriptionId ($Project.Subscription.SubscriptionId)

    Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Creating Storage Account: $ActualStorageAccountName into Affinity Group $AffinityGroupName"
    Invoke-StorageAccount -StorageAccountName $ActualStorageAccountName -AffinityGroup $AffinityGroupName -SubscriptionId ($Project.Subscription.SubscriptionId)
    return $ActualStorageAccountName
}