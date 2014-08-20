Function Save-AzdeDeploymentConfiguration {
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [AzureDeploymentEngine.Deployment]$deployment,
        [string]$Path,
        [switch]$force
    )

    if (!($Path))
    {
        $SavePath = Join-Path -Path $artifactpath -ChildPath "$($deployment.Deploymentname)"
        $savepath = Join-Path -Path $SavePath -ChildPath "$($deployment.Deploymentname).json"
         
    }
    Else
    {
        $SavePath = $Path
    }

    if (!(test-path $SavePath))
    {
        new-item $SavePath -ItemType File -Force | out-null
    }
    ElseIf ((test-path $SavePath) -and ($force))
    {
        get-item $SavePath | remove-item -Force
        new-item $SavePath -ItemType File -Force | out-null

    }

    #Todo: Better logic for not overwriting files
    $deployment | ConvertTo-Json -Depth 15 | Set-Content -Path $SavePath -Force
    Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Writing deployment config to $savepath"
}


Function Import-AzdeDeploymentConfiguration
{
    Param ($Path)
    $jsonstring = Get-content $Path -Raw
    
    $jsonconverter = New-Object AzureDeploymentEngine.JsonFunctions
    $Deployment = $jsonconverter.ConvertToProjectFromJson($jsonstring)
    $Deployment
}


Function Import-AzdeVMConfiguration
{
    Param ($Path,$string)
    if ($string)
    {
        $jsonstring = $string
    }
    Else
    {
        $jsonstring = Get-content $Path -Raw
    }
    
    
    $jsonconverter = New-Object AzureDeploymentEngine.JsonFunctions
    $vm = $jsonconverter.ConvertToVmFromJson($jsonstring)
    $vm
}