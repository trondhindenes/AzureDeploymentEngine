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
            $subnetobj.SubnetName = "sn" + $subnetname
            $ArSubnetsObj += $subnetobj
            $subnetobj,$subnetprefix,$subnetname = $null
        }

        #Create the network
        New-AzureANVNetSite -VNetName $networkname -AffinityGroupName $AffinityGroupName -VNetAddressPrefix $network.AddressPrefix -subnets $ArSubnetsObj #-SubnetName $SubnetName -SubnetAddressPrefix $SubnetAddressPrefix 
        Write-Verbose "NETWORK: network updated"
    }


}