#Internal function
Function Enable-AzdeAzureSubscription
{
    [Cmdletbinding()]
	Param ($SubscriptionId,$Storageaccountname)
	$Subs = get-azuresubscription | where {$_.SubscriptionId -eq $Subscriptionid}
	if (!($Subs))
	{
		Write-Error "Azure subscription $Subscriptionid is not installed on this computer"
		Break
	}
	
	$CurrentSubs = get-azuresubscription -Current
	if ($CurrentSubs.SubscriptionId -ne $SubscriptionId)
	{
		Write-Verbose "Switching to azure subscription $SubscriptionId"
		$Subs | Select-azuresubscription -current
		$CurrentSubs = $Subs
	}
	Else
	{
		Write-Verbose "Already on the correct azure subscription"
	}

    if ($Storageaccountname)
    {
        if ($CurrentSubs.CurrentStorageAccount -ne $Storageaccountname)
        {
            Write-Verbose "Setting correct storage account name ($storageaccountname) for subscription $subscriptionid"
            Set-AzureSubscription -subscriptionname ($CurrentSubs.SubscriptionName) -CurrentStorageAccountName ($Storageaccountname.ToLower())
        }
    }
}

