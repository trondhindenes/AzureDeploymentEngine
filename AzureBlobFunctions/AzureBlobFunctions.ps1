Function copy-FileToAzure
{
    Param (
        $path,
        $storageaccountname
    )

    $guid1 = [guid]::NewGuid()
    $guid1 = $guid1.ToString()
    $guid1 = $guid1.Substring(0,10)
    $guid2 = [guid]::NewGuid()
    $guid2 = $guid2.ToString()
    $storageAccountKey = Get-AzureStorageKey $storageAccountName 
    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey.Primary
    
    New-AzureStorageContainer $guid1 -Permission Off -Context $context | out-null
    $result = Set-AzureStorageBlobContent -Blob $guid2 -Container $guid1 -File $path -Context $context -Force -ClientTimeoutPerRequest 99999
    $sastoken = New-AzureStorageBlobSASToken  -Blob $guid2 -Container $guid1 -Context $context -Permission r
    
    #Construct URI for downloading the file
    [system.uri]$returnUri = $result.ICloudBlob.Uri.AbsoluteUri + $sastoken

    #Construct return object
    $returnobj = "" | Select OriginalFileName, ReturnUri
    $returnobj.OriginalFileName  = (get-item $path).Name
    $returnobj.ReturnUri = $returnUri

    return $returnobj
}

Function Remove-AzureBlobAndContainer
{
    Param (
        $inputobj,
        [bool]$removeContainer = $true
    )

    $BlobUri = $inputobj.AbsoluteUri
    $Container = $inputobj.LocalPath.Split("/")[1]
    $storageaccount = $inputobj.Host.split(".")[0]
    $blobname = $inputobj.Segments[2]

    Remove-AzureStorageBlob -Blob $blobname -Container $container
    if ($removeContainer)
    {
        Remove-AzureStorageContainer -Name $Container -Confirm:$false
    }
}





