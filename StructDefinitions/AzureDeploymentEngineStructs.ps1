New-Struct @{
        AzureDeploymentEngine_Credential = {
        [string]$UserName;
        [string]$Password;
        [string]$Domain;
        [string]$SecurePassword;
        [string]$CredentialType;
    }

    AzureDeploymentEngine_VMSetting ={
        [string]$ImageFamily
        [string]$ImageSize
        [string]$subnet
        [string]$JoinDomain
        [bool]$WaitForVmDeployment
        [bool]$AlwaysRedeploy
        [AzureDeploymentEngine_Credential]$DefaultAdminCredential
        [AzureDeploymentEngine_Credential]$DefaultDomainJoinCredential
    }

    AzureDeploymentEngine_VM ={
        [string]$VMName
        [string]$subnet
        [string]$ipaddress
        [string]$cloudservice
        [bool]$WaitForVmDeployment
        [bool]$AlwaysRedeploy
        [bool]$OverrideNamingStandard
        [AzureDeploymentEngine_Credential]$AdminCredential
        [AzureDeploymentEngine_Credential]$DomainJoinCredential
    }

    AzureDeploymentEngine_network = {
        [String]$NetworkName
    }

    AzureDeploymentEngine_postdeploymentscript ={
        [string]$ScriptDisplayName
        [int]$Order
        [bool]$WaitForAll
        [string]$Runat
        [string]$path
        [string]$PathType
        [AzureDeploymentEngine_VM[]]$VMs
    }

    AzureDeploymentEngine_CloudServiceSetting ={
        [string]$CloudServiceVmSetting
        [string]$CloudServiceDeletionSetting
        [string]$CloudServicePrefix
        [string]$CloudServicesuffix
    }

    
    AzureDeploymentEngine_ProjectSetting ={
        [string]$ProjectPrefix
        [string]$Projectsuffix
        [string]$ProjectStoragePrefix
        [string]$ProjectStorageSuffix
        [string]$AffinityGroupPrefix
        [string]$AffinityGroupsuffix
        [string]$Location
        [AzureDeploymentEngine_Credential]$DomainAdminCredential
        [bool]$DeployDomainControllersPerProject
        [string]$AdDomainName
        [string]$DomainControllerNamePrefix
        [string]$DomainControllerNameSuffix
        [string]$VmNamePrefix
        [string]$VmNameSuffix
    }

    AzureDeploymentEngine_Project ={
        [String]$ProjectName
        [AzureDeploymentEngine_ProjectSetting]$ProjectSettings
        [AzureDeploymentEngine_VMSetting]$VmSettings
        [AzureDeploymentEngine_CloudServiceSetting]$CloudServiceSettings
        [AzureDeploymentEngine_VM[]]$VMs
        [AzureDeploymentEngine_network]$network
        [AzureDeploymentEngine_postdeploymentscript[]]$PostDeploymentScripts

    }

    AzureDeploymentEngine_Subscription ={
        [string]$SubscriptionFriendlyName
        [string]$Id
        [AzureDeploymentEngine_Project[]]$Projects
        }

    AzureDeploymentEngine_Deployment ={
        [string]$DeploymentFriendlyName
        [AzureDeploymentEngine_Subscription[]]$Subscriptions
        }
} -CreateConstructorFunction -Verbose 4> "outfile.txt"

