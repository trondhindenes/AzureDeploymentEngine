$invocation = (Get-Variable MyInvocation).Value
$moduleFilePath =  $invocation.MyCommand.Path
$modulefolderpath = $moduleFilePath | split-path


function Invoke-AzdeDeployment {
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        $subscription,
        $Project,
        [switch]$SkipDomainController
    )

    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Command: Invoke-AzdeDeployment"

    #Execution logic
    #1.verify required info
    #2. Construct names based on settings
    #3. Verify names /construct Azure things
    #4. Deploy DC/VMs
    #5. Execute postinstall-scripts

    if ($Deployment.Subscriptions.count -eq $null)
    {
        Write-Error "The specified deployment doesnt contain any subscriptions"
    }
    Elseif (($Deployment.Subscriptions.count -gt 1) -and (!($subscription)))
    {
        Write-Error "
        This deployment contains more than one subscription. Specify which one either by name or object"
    }
    Elseif ($subscription)
    {
        if ($subscription.GetType().Name -eq "String")
        {
            #Subscription specified as string. Check that deployment contains it
        }
        Elseif ($subscription.GetType().Name -eq "AzureDeploymentEngine.Subscription")
        {
            #SUbscription specified as object
        }

    }
    Else
    {
        $subscription = $Deployment.Subscriptions[0]
    }

    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "      Current Subscription is: $($subscription.SubscriptionDisplayName)"
    #TODO: At this point, make sure we have a subscription

    if ((!$project) -and ($subscription.Projects.count -eq 1))
    {
        #ONly one project in subscription, use that one
        $project = $subscription.Projects[0]
    }

    
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
        Assert-AzdeDomainController -Deployment $Deployment -subscription $subscription -project $project -AffinityGroupName $AffinityGroup
    }
    Else
    {
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Skipping Domain controller deployment"
    }

    #VMs
    $deployedVMs = Assert-azdeVirtualMachine -Deployment $Deployment -subscription $subscription -project $project -AffinityGroupName $AffinityGroup 
    Assert-AzdePostDeploymentScript -Deployment $Deployment -subscription $subscription -project $project -AffinityGroupName $AffinityGroup -vms $deployedVMs

}