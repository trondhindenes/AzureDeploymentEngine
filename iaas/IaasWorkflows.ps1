Workflow NOTInvoke-AzDeVirtualMachine
{
    Param (
        [Parameter(ParameterSetName='SingleVm')]
        [AzureDeploymentEngine.Vm]$vm,
        [Parameter(ParameterSetName='SingleVm')]
        $cloudservicename,
        [Parameter(ParameterSetName='MultipleVMs')]
        $vms,
        $affinityGroupName
    )

    if (!($vms))
    {
      

        $vms = @()
        $vms += $vm
    }

    if ((!$vm) -and (!$vms))
    {
        throw "No VMs Specified"
    }

    #at this point, we have an array of vms
    $cloudservices = @()
    $cloudservices += $vms | ForEach-Object {$_.VmSettings.CloudServiceName}

    foreach -parallel ($cloudservice in $cloudservices)
    {
        $csvms = $vms | where {$_.vmsettings.CloudServiceName -eq $cloudservice}
        {
            #Ensure the cloud service is present
            if (!(Get-AzureService -ServiceName $cloudservice))
            {
                New-AzureService -AffinityGroup $affinityGroupName
            }

            #csvms is an array of vms going to the same cs. These will have to be done one by one
            foreach ($csvm in $csvms)
            {
                InlineScript {
                    $csvm = $using:csvm
                    $azurevm = New-AzureVMConfig -Name $csvm.VmName -InstanceSize "Small" -Image $csvm.VmSettings.VmImage
                    $azurevm | Add-AzureProvisioningConfig -Windows -AdminUserName $csvm.VmSettings.LocalAdminCredential.UserName -Password $csvm.VmSettings.LocalAdminCredential.Password
                    $azurevm | New-AzureVM -ServiceName $csvm.vmsettings.cloudservicename -VNetName $csvm.VmSettings.Subnet -WaitForBoot
                }
            
            }
        
        }
    
    }

}