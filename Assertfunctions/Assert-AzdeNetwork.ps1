Function Assert-AzdeNetwork
{
    Param (
        [AzureDeploymentEngine.Project]$Project,
        $AffinityGroupName
    )


    $ProjectName = $Project.ProjectName
    
    $network = $Project.Network
    $networkname = $network.NetworkName

    #case-insensitive replace
    $Actualnetworkname = [AzureDeploymentEngine.StringExtensions]::Replace($networkname,"projectname",$projectname,"OrdinalIgnoreCase")

    #Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Storage Account Name is: $ActualStorageAccountName"
    Enable-AzdeAzureSubscription -SubscriptionId ($Project.Subscription.SubscriptionId)

    #Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Creating Storage Account: $ActualStorageAccountName into Affinity Group $AffinityGroupName"
    Invoke-network -AffinityGroupName $AffinityGroupName -SubscriptionId ($Project.Subscription.SubscriptionId) -project $project -networkname $Actualnetworkname
    return $Actualnetworkname
}