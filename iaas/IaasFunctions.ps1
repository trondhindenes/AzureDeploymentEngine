#Internal Function
Function Invoke-AffinityGroup
{
	Param (
		$AffinityGroupName,
		$Location,
		$SubscriptionId
	)
	
	
	Enable-AzdeAzureSubscription $SubscriptionId
	$existingAffinityGroup = Get-AzureAffinityGroup $AffinityGroupName -ErrorAction 0
	if (!$existingAffinityGroup)
	{
        #Locally silence verbose logging
        if ($verboselevel -lt 3)
        {
            Set-variable -Name VerbosePreference -Scope local -Value "SilentlyContinue"
        }
	    New-AzureAffinityGroup -Name $AffinityGroupName -Location $Location | out-null
	}
	Else
	{
		if (($existingAffinityGroup.Location) -ne $Location)
		{
			Write-Error "Affinity group $AffinityGroupName but with the wrong location. Please delete it manually"
			Break
		}
	    Write-Verbose "Affinity group $AffinityGroupName with location $Location already exists."
	}

	
}

#Internal Function
Function Invoke-StorageAccount
{
	Param (
		$StorageAccountName,
		$AffinityGroupName,
		$SubscriptionId
	)
	
	
	Enable-AzdeAzureSubscription $SubscriptionId
    #Locally silence verbose logging
        if ($verboselevel -lt 3)
        {
            Set-variable -Name VerbosePreference -Scope local -Value "SilentlyContinue"
        }
	$ExistingStorageAccount = Get-AzureStorageAccount -StorageAccountName $StorageAccountName -ErrorAction 0
	if (!$ExistingStorageAccount)
	{
		Write-Verbose "Creating Storage account $StorageAccountName"
	    New-AzureStorageAccount -StorageAccountName $StorageAccountName  -AffinityGroup $AffinityGroupName | out-null
	}
	Else
	{
		if (($ExistingStorageAccount.AffinityGroup) -ne $AffinityGroupName)
		{
			Write-Error "Storage account $StorageAccountName exists, but in the wrong affinity group. Please delete manually"
			Write-Error "      Expected $AffinityGroupName, got $($ExistingStorageAccount.AffinityGroup)"
			Break
		}
	    Write-Verbose "Storage account $StorageAccountName already exists"
	}

    if ((Get-AzureSubscription -Current).CurrentStorageAccountName -ne $StorageAccountName)
    {
        Get-AzureSubscription -Current | Set-AzureSubscription -CurrentStorageAccountName $StorageAccountName
    }
    $StorageAccountName
	
}

#Invoke-Network -networksettings $NetworkSettings -SubscriptionId $SubscriptionId -project $ThisProject
Function Invoke-network
{
    Param (
    $subscriptionid,
    $AffinityGroupName,
    $project,
    $networkname)

    try
    {
        $existingNetwork = Get-AzureVNetSite -VNetName $networkname
    }
    catch
    {}

    if ($existingNetwork)
    {
        #Verify that the network is correctly setup
    }
    Else
    {
        Write-verbose "Creating network $networkname in Affinity Group $AffinityGroupName"
        
        #Get the subnets
        $subnets = $network.Subnets
        $ArSubnetsObj = @()
        Foreach ($subnet in $subnets)
        {
            
            $subnetname =  $subnet.subnet
            $subnetobj = "" | Select SubnetPrefix, SubnetName
            $subnetobj.Subnetprefix = $subnetname
            $subnetobj.SubnetName = "sn-" + $subnetname
            $ArSubnetsObj += $subnetobj
            $subnetobj,$subnetprefix,$subnetname = $null
        }

        #Create the network
        New-AzureANVNetSite -VNetName $networkname -AffinityGroupName $AffinityGroupName -VNetAddressPrefix $network.AddressPrefix -subnets $ArSubnetsObj #-SubnetName $SubnetName -SubnetAddressPrefix $SubnetAddressPrefix 
        Write-Verbose "NETWORK: network updated"
    }


}

function Invoke-AzDeVirtualMachine
{
    Param (
        [Parameter(ParameterSetName='SingleVm')]
        [AzureDeploymentEngine.Vm]$vm,
        [Parameter(ParameterSetName='SingleVm')]
        $cloudservicename,
        [Parameter(ParameterSetName='MultipleVMs')]
        $vms,
        $affinityGroupName,
        $vnetname,
        [int]$datadisk
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

    if ($cloudservices.count -eq 0)
    {
        throw "no cloud services defined. Something bad happened."
    }

    foreach ($cloudservice in $cloudservices)
    {
        $csvms = $vms | where {$_.vmsettings.CloudServiceName -eq $cloudservice}
        
        if (!(Get-AzureService -ServiceName $cloudservice -ErrorAction 0))
        {
            New-AzureService -AffinityGroup $affinityGroupName -ServiceName $cloudservice
        }

        #csvms is an array of vms going to the same cs. These will have to be done one by one
        foreach ($csvm in $csvms)
        {   
            $image = Get-AzureVMImage | where {$_.ImageFamily -eq $csvm.VmSettings.VmImage} | Sort-Object PublishedDate | Select -First 1
            if (!$image){throw "Could not find the image"}
            $azurevm = New-AzureVMConfig -Name $csvm.VmName -InstanceSize "Small" -Image $image.imagename
            $azurevm | Add-AzureProvisioningConfig -Windows -AdminUserName $csvm.VmSettings.LocalAdminCredential.UserName -Password $csvm.VmSettings.LocalAdminCredential.Password | out-null
            if ($datadisk)
            {
                $azurevm |Add-AzureDataDisk -CreateNew -DiskSizeInGB $datadisk -DiskLabel 'DataDrive' -LUN 0
            }

            if ($csvm.VmSettings.Subnet)
            {
                $azurevm | Set-AzureSubnet -SubnetNames $csvm.vmsettings.Subnet
            }
            $azurevm | New-AzureVM -ServiceName $csvm.vmsettings.cloudservicename -VNetName $networkname -WaitForBoot | out-null
        }
    }

}