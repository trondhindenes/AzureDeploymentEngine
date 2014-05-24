Function Invoke-PostDeploymentScript
{
    [CmdletBinding()]
    Param (
        [AzureDeploymentEngine.PostDeploymentScript]$PostDeploymentScript,
        $storageaccount
    )

    foreach ($vm in $PostDeploymentScript.vms)
    {
        #Main loop for script
        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Staring post-deployment script for vm $($vm.VmName)"
        
        if ($PostDeploymentScript.CloudServiceName)
        {
            $cloudservicename = $PostDeploymentScript.CloudServiceName
        }
        ElseIf ($vm.VmSettings.CloudServiceName)
        {
                $cloudservicename = $vm.VmSettings.CloudServiceName
        }

        #Cloud service name may come in another format. More logic needed here
        $AzureVMObject = Get-AzureVM -Name $vm.VmName -ServiceName $cloudservicename
        $winRMUri = $AzureVMObject | Get-AzureWinRMUri
        $Pssessionoption = New-PSSessionOption
        $Pssessionoption.SkipCACheck = $true
        $Pssessionoption.SkipCNCheck = $true
        $Pssessionoption.SkipRevocationCheck = $true
        
        #Get the creds:
        $VMWinRmCreds = $vm.VmSettings.DomainJoinCredential
        if (!$VMWinRmCreds)
        {
            $VMWinRmCreds = $vm.VmSettings.LocalAdminCredential
        }

        $Credobject = Get-AzdeCredObject -credential $VMWinRmCreds

        #Attempt connection
        $retries = 0
        Do {
            if ($retries -gt 1)
            {
                Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "POSTINSTALLSCRIPT: Attempting to connect to computer $($vm.VmName) on uri $winrmuri - attempt $retries"
                start-sleep -Seconds 10
            }
            $testsession = Invoke-Command -ConnectionUri $winRMUri.AbsoluteUri -Credential $Credobject -SessionOption $Pssessionoption -ScriptBlock {
            $env:computername
                } -ErrorAction 0
            $retries ++
        }
        until (($retries -gt 10) -or ($testsession))
        if ($retries -gt 10)
        {
            Write-error "Could not connect to vm using URI $($winRMUri.AbsoluteUri). I'm treating this a a non-terminating error, so you can control it via ErrorActionPreference"
        }
    
        $ScriptType = $PostDeploymentScript.PathType
        $scriptpath = $PostDeploymentScript.Path
        $ScriptName = $PostDeploymentScript.PostDeploymentScriptName    
        $RebootOnCompletion = $PostDeploymentScript.RebootOnCompletion

        if ($ScriptType -eq "CopyFileFromLocal")
        {
            if (!(test-path $scriptpath))
            {
                
                throw "I couldnt find the file at path $scriptpath. Breaking"
            }

            
            #First, copy the file up. Then invoke script to have the VM download it
            $FileCopyObject = copy-FileToAzure -path $scriptpath -storageaccountname $storageaccount
            $copyscript = "$thismodulepath\PostDeploymentScripts-content\DownloadFileFromBlob.ps1"

            $scriptblockstring  = [system.io.file]::ReadAllText($copyscript)
            $scriptblock = $executioncontext.invokecommand.NewScriptBlock($scriptblockstring)
        }

        if ($ScriptType -eq "FileFromLocal")
        {
            if (!(test-path $scriptpath))
            {
                #The following is from the xml implementation
                <#
                #Try to find scriptname at some other locations, such as
                #Same folder as xml
                if (test-path (join-path ((get-item ($azurelabsettings.filepath)).Directory.ToString()) $scriptname))
                {
                   $scriptname = join-path ((get-item ($azurelabsettings.filepath)).Directory.ToString()) $scriptname
                }
                #Same folder as xml + subdir
                if (test-path (join-path ((get-item ($azurelabsettings.filepath)).Directory.ToString()) "scripts\$scriptname"))
                {
                   $scriptname = join-path ((get-item ($azurelabsettings.filepath)).Directory.ToString()) "scripts\$scriptname"
                }
                #>

            }

            $scriptblockstring  = [system.io.file]::ReadAllText($scriptpath)
            $scriptblock = $executioncontext.invokecommand.NewScriptBlock($scriptblockstring)
        }

        if ($ScriptType -eq "FileFromUrl")
        {
            $guid = [guid]::NewGuid()
            $networkfilename = $guid.tostring()
            $networkfilename = "$networkfilename.xml"
            $savepath = join-path $env:temp $networkfilename
            $clnt = new-object system.net.webclient
            $clnt.DownloadFile($scriptname,$savepath)

            $scriptblockstring  = [system.io.file]::ReadAllText($savepath)
            $scriptblock = $executioncontext.invokecommand.NewScriptBlock($scriptblockstring)
            remove-item $savepath -erroraction 0
        }

        Write-enhancedVerbose -MinimumVerboseLevel 1 -Message "Running script $ScriptName on VM $($vm.VmName)"
        $Result = Invoke-Command -ConnectionUri $winRMUri.AbsoluteUri -Credential $Credobject -SessionOption $Pssessionoption -ScriptBlock $Scriptblock -ErrorAction 0 -ErrorVariable scripterror
        if ($scripterror)
        {
            foreach ($message in $scripterror)
            {
                Write-error $message
            }
        }
        
        Write-verbose "POSTSCRIPT: Result:"
        $result

        if ($rebootoncompletion)
        {
            Write-enhancedVerbose -MinimumVerboseLevel 2 -Message "Running post-script reboot on VM $($vm.VmName)"
            #restart doesnt wait. Need to build some logic for dat.
            $AzureVMObject | restart-azurevm | out-null
        }

        $WaitSeconds = 0
        $vmisdeployed = $false
        Do {
            $AzureVMObject = get-azurevm -ServiceName $cloudservicename -Name $vm.VmName -ErrorAction 0
            start-sleep -seconds $WaitSeconds
            $waitseconds = 10
            #Wait for VM to be readyrole
            if ($AzureVMObject.InstanceStatus -eq "ReadyRole")
            {
                $vmisdeployed = $true
            }
            
        }
        until ($vmisdeployed)
     }

     #If this was a copy-operation, clean up the blob
     if ($ScriptType -eq "CopyFileFromLocal")
        {
            Write-enhancedVerbose -MinimumVerboseLevel 3 -Message "cleaning up blob"
            Remove-AzureBlobAndContainer -inputobj ($FileCopyObject.ReturnUri) -removeContainer $true
        }

    }


