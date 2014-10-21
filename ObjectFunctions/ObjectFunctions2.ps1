function New-AzdeDeployment {
    [OutputType([AzureDeploymentEngine.Deployment])]
    Param (
        $DeploymentName
    )

    $deployment = New-Object AzureDeploymentEngine.Deployment
    $Deployment.DeploymentName = $DeploymentName
    $deployment
}

Function Add-AzdeSubscription {
    [OutputType([AzureDeploymentEngine.Deployment])]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$Subscription
    )

    if ($Deployment.Subscriptions.count -eq 0)
    {
        #Add the first sub
        $deployment.Subscriptions = $Subscription
    }
    Else
    {
        #add consecutive
        $Deployment.Subscriptions.Add($Subscription)
    }
}

Function new-AzdeSubscription {
    [OutputType([AzureDeploymentEngine.Subscription])]
    Param (
        [Parameter(ParameterSetName='ByName')]
        [string]$subscriptionName,
        [Parameter(ParameterSetName='ByName')]
        [string]$SubscriptionId,
        [Parameter(ValueFromPipeline=$true,ParameterSetName='ByAzureSubscriptionObject')]
        [Microsoft.WindowsAzure.Commands.Profile.Models.PSAzureSubscription]$AzureSubscription
    )

    $Subscription = New-Object AzureDeploymentEngine.Subscription

    if ($AzureSubscription)
    {
        $Subscription.SubscriptionDisplayName = $AzureSubscription.SubscriptionName
        $subscription.SubscriptionId = $AzureSubscription.SubscriptionId
    }
    else
    {
        $Subscription.SubscriptionDisplayName = $subscriptionName
        $subscription.SubscriptionId = $SubscriptionId
    }

    $subscription

}

Function New-AzdeProject {
    [OutputType([AzureDeploymentEngine.Project])]
    Param (
        [string]$ProjectName,
        [AzureDeploymentEngine.ProjectSetting]$ProjectSettings
    )

    $project = New-Object AzureDeploymentEngine.Project
    $project.ProjectName = $ProjectName
    
    if ($ProjectSettings)
    {
        $project.ProjectSettings
    }
    
    $project
}

function Add-AzdeProject {
    [OutputType([AzureDeploymentEngine.Subscription])]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [AzureDeploymentEngine.Subscription]$Subscription,
        
        [Parameter(Mandatory=$true)]
        [AzureDeploymentEngine.Project]$Project

    )

    if ($Subscription.Projects.count -eq 0)
    {
        #add the first one 
        $Subscription.Projects = $Project
    }
    Else
    {
        #Add consecutive if name is unique
        if ($Subscription.projects.ProjectName -notcontains $project.projectName)
        {
        $Subscription.Projects.add($project)
        }
        Else
        {
            Write-error "Each project must be unique"
        }
        
    }
    $Subscription
}

Function New-AzdeVmSettings
{
    Param (
        [bool]$AlwaysRedeploy,
        [AzureDeploymentEngine.Credential]$DomainJoinCredential,
        [AzureDeploymentEngine.Credential]$localadmincredential,
        [bool]$joindomain,
        [string]$subnet,
        [int]$vmcount = 1,
        [string]$vmimage,
        [bool]$waitforVmDeployment
    
    )
    

    $vmsettings = new-object AzureDeploymentEngine.VmSetting
    $vmsettings.AlwaysRedeploy = $AlwaysRedeploy
    $vmsettings.DomainJoinCredential = $DomainJoinCredential
    $vmsettings.JoinDomain = $joindomain
    $vmsettings.LocalAdminCredential = $localadmincredential
    $vmsettings.Subnet = $subnet
    $vmsettings.VmCount = 1
    $vmsettings.VmImage = $vmimage
    $vmsettings.WaitforVmDeployment = $WaitforVmDeployment

    $vmsettings


}

function Add-AzdeVmSettings
{
    Param (
        [AzureDeploymentEngine.VmSetting]$settings,
        [AzureDeploymentEngine.Deployment]$Deployment,
        [AzureDeploymentEngine.Subscription]$subscription,
        [AzureDeploymentEngine.Project]$Project,
        [AzureDeploymentEngine.Vm]$vm
    )

    if ($Deployment)
    {
        $Deployment.VmSettings = $settings
    }
    ElseIf ($subscription)
    {
        $subscription.VmSettings = $settings
    }
    ElseIf ($Project)
    {
        $Project.VmSettings = $settings
    }
    ElseIf ($vm)
    {
        $vm.VmSettings = $settings
    }

}

Function get-azdeInternalResultingSetting 
{
    Param (
        [AzureDeploymentEngine.Deployment]$Deployment,
        $object,
        $AttributeName,
        $AttributeType
    )




}