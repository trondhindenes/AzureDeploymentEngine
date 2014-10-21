if (!(get-psdrive F -ErrorAction 0))
{
    #setup disk
    Initialize-Disk 2 -PartitionStyle MBR 
    New-Partition -DiskNumber 2 -UseMaximumSize -IsActive -DriveLetter F |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "AD DS Data" -Force:$true -Confirm:$false
}


Import-Module ServerManager
Install-WindowsFeature -Name AD-Domain-Services 
Install-WindowsFeature RSAT-AD-Tools
Import-Module ADDSDeployment

$addomainname = $using:azdeAdDomainName
Write-Verbose "AD Domain name is $addomainname"
$netbiosdomainname = $addomainname.split(".")[0]
$credobject = $using:Credobject
$password = $credobject.password

$params = @{
            CreateDnsDelegation = $false
            DatabasePath = 'F:\NTDS'
            DomainName = $addomainname
            DomainNetbiosName = $netbiosdomainname
            InstallDns = $true
            LogPath = 'F:\NTDS'
            NoRebootOnCompletion = $true
            SysvolPath = 'F:\SYSVOL'
            Force = $true
            SafeModeAdministratorPassword = $password
        }

         Install-ADDSForest @params -WarningAction SilentlyContinue