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
            
            $subnetname =  $subnet.subnetname
            $subnetobj = "" | Select SubnetPrefix, SubnetName
            $subnetobj.Subnetprefix = $subnet.SubnetCidr
            $subnetobj.SubnetName = $subnetname
            $ArSubnetsObj += $subnetobj
            $subnetobj,$subnetprefix,$subnetname = $null
        }

        #Create the network
        New-AzureANVNetSite -VNetName $networkname -AffinityGroupName $AffinityGroupName -VNetAddressPrefix $network.AddressPrefix -subnets $ArSubnetsObj #-SubnetName $SubnetName -SubnetAddressPrefix $SubnetAddressPrefix 
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Network updated"
    }


}

function Invoke-AzDeVirtualMachine
{
    Param (
        [Parameter(ParameterSetName='SingleVm')]
        [AzureDeploymentEngine.Vm]$vm,
        $affinityGroupName
    )

    $cloudserviceName = $vm.VmSettings.CloudServiceName

    if (!($cloudserviceName))
    {
        Throw "Invalid or no cloudservice defined"
    }


    
        
    if (!(Get-AzureService -ServiceName $cloudserviceName -ErrorAction 0 -verbose:$false))
    {
        Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Creating new cloud service $cloudservice"
        New-AzureService -AffinityGroup $affinityGroupName -ServiceName $cloudserviceName | out-null
    }

    #csvms is an array of vms going to the same cs. These will have to be done one by one
   
    #Test if the VM exists
    $VMsCheck = Get-AzureVM -verbose:$false
    if ($vmsCheck | where {$_.Name -eq $vm.VmName})
    {
        #VM exists
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Found existing vm $($vm.VmName). Skipping."
        $VMCheck = $VMsCheck | where {$_.Name -eq $vm.VmName}
        if ($VMCheck.ServiceName -ne $cloudservice)
        {
            #VM exists, but in different subnet
        } 
        
        $vmcheck | Add-Member -MemberType NoteProperty -Name "AlreadyExistingVm" -Value $true -Force

        return $VMCheck                               
    }
    Else
    {
        #Create the VM
        $image = Get-AzureVMImage -verbose:$false| where {$_.ImageFamily -eq $vm.VmSettings.VmImage} | Sort-Object PublishedDate | Select -First 1
        if (!$image){throw "Could not find the image specified ( $($vm.VmSettings.VmImage) )"}
        $azurevm = New-AzureVMConfig -Name $vm.VmName -InstanceSize "Small" -Image $image.imagename
        $azurevm | Add-AzureProvisioningConfig -Windows -AdminUserName $vm.VmSettings.LocalAdminCredential.UserName -Password $vm.VmSettings.LocalAdminCredential.Password
        if ($vm.VmSettings.DataDiskSize -gt 0)
        {
            $datadisksizeInGb = ($vm.VmSettings.DataDiskSize) / 1GB
            $azurevm |Add-AzureDataDisk -CreateNew -DiskSizeInGB $datadisksizeInGb -DiskLabel 'DataDrive' -LUN 0 | out-null
        }

        if ($vm.VmSettings.Subnet)
        {
            $azurevm | Set-AzureSubnet -SubnetNames $vm.vmsettings.Subnet | out-null
        }
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Deploying vm $($vm.VmName)"
        $azurevm | New-AzureVM -ServiceName $vm.vmsettings.cloudservicename -VNetName ($vm.VmSettings.VnetName) -WaitForBoot -Verbose:$false
        $azurevm | Add-Member -MemberType NoteProperty -Name "AlreadyExistingVm" -Value $true -Force
        return $azurevm
    }

      
    


}