Initialize-Disk 2 -PartitionStyle MBR 
New-Partition -DiskNumber 2 -UseMaximumSize -IsActive -DriveLetter F |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "AD DS Data" -Force:$true -Confirm:$false

Import-Module ServerManager
Install-WindowsFeature -Name AD-Domain-Services 
Install-WindowsFeature RSAT-AD-Tools
Import-Module ADDSDeployment

$params = @{
            CreateDnsDelegation = $false
            DatabasePath = 'F:\NTDS'
            DomainName = $Using:ActualAdFqdnName
            DomainNetbiosName = $Using:ActualAdNetbiosName
            InstallDns = $true
            LogPath = 'F:\NTDS'
            NoRebootOnCompletion = $true
            SysvolPath = 'F:\SYSVOL'
            Force = $true
            SafeModeAdministratorPassword = $Using:VMobject.DefaultCredentials.Password
        }

         Install-ADDSForest @params