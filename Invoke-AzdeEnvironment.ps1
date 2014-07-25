$invocation = (Get-Variable MyInvocation).Value
$moduleFilePath =  $invocation.MyCommand.Path
$modulefolderpath = $moduleFilePath | split-path


function Invoke-AzdeProject {
    Param (
        [AzureDeploymentEngine.Project]$Project,
        [switch]$SkipDomainController
    )

    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Command: Invoke-AzdeProject"

    #Execution logic
    #1.verify required info
    #2. Construct names based on settings
    #3. Verify names /construct Azure things
    #4. Deploy DC/VMs
    #5. Execute postinstall-scripts

    $subscription = $Project.Subscription

    if (!($subscription))
    {
        throw "Subscription not specified"
    }

    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "      Current Subscription is: $($subscription.SubscriptionDisplayName)"
    #TODO: At this point, make sure we have a subscription

    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "      Current Project is: $($project.ProjectName)"


    #Construct list of AGs, Storage Account(s),Networks, VMs, postdeploymentscripts to be created
    $AffinityGroup = Assert-azdeAffinityGroup -Deployment $Deployment -subscription $subscription -project $project

    #Storage Account
    $StorageAccount = Assert-AzdeStorageAccount -Deployment $Deployment -subscription $subscription -project $project -AffinityGroupName $AffinityGroup

    #Network
    $Network = Assert-AzdeNetwork -Deployment $Deployment -subscription $subscription -project $project -AffinityGroupName $AffinityGroup

    #Project Cloud Service


    #DC
    if (!($SkipDomainController))
    {
        Assert-AzdeDomainController -subscription $subscription -project $project -AffinityGroupName $AffinityGroup
    }
    Else
    {
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Skipping Domain controller deployment"
    }

    #VMs
    $deployedVMs = Assert-azdeVirtualMachine -project $project -AffinityGroupName $AffinityGroup 
    Assert-AzdePostDeploymentScript -project $project -AffinityGroupName $AffinityGroup -vms $deployedVMs -storageaccount $storageaccount[0]

}