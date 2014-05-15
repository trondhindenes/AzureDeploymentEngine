using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management.Automation;

namespace AzureDeploymentEngine
{

    public class Credential
    {
        public string UserName { get; set; }
        public string Password { get; set; }
        public string Domain { get; set; }
        public string SecurePassword { get; set; }
        public PSCredential PSCredential { get; set; }
        public string CredentialType { get; set; }        
    }

    public class VmSetting
    {
        public string VmImage { get; set; }
        public string VmSize { get; set; }
        public string Subnet { get; set; }
        public bool JoinDomain { get; set; }
        public bool WaitforVmDeployment { get; set; }
        public bool AlwaysRedeploy { get; set; }
        public bool MoveVmToCorrectSubnet { get; set; }
        public bool AllowIpAddressChange { get; set; }
        public AzureDeploymentEngine.Credential LocalAdminCredential { get; set; }
        public AzureDeploymentEngine.Credential DomainJoinCredential { get; set; }
        public int VmCount { get; set; }
        public string CloudServiceName { get; set; }
        
    }

    public class Vm
    {
        public string VmName { get; set; }
        public string IpAddress { get; set; }
        public VmSetting VmSettings { get; set; }
    }

    public class network
    {
        public string NetworkName { get; set; }
        public string AddressPrefix { get; set; }
        public List<Subnet> Subnets { get; set; }

    }

    public class Subnet
    {
        public string subnetName { get; set; }
        public string SubnetCidr { get; set; }
    }

    public class PostDeploymentScript
    {
        public string PostDeploymentScriptName { get; set; }
        public int Order { get; set; }
        //public bool WaitforAll { get; set; }
        public string RunAt { get; set; }
        public string Path { get; set; }
        public string PathType { get; set; }
        public List<String> VmNames { get; set; }
    }

    public class CloudServiceSetting
    {
        public string CloudServiceName { get; set; }
        public string CloudServiceVmPlacement { get; set; }


    }

    public class ProjectSetting
    {
        public string ProjectStorageAccountName { get; set; }
        public string AffinityGroupName { get; set; }
        public string Location { get; set; }
        public Credential DomainAdminCredential { get; set; }
        public bool DeployDomainControllersPerProject { get; set; }
        public string AdDomainName { get; set; }
        public string DomainControllerName { get; set; }
        public string VmNamePrefix { get; set; }
        public string VmNameSuffix { get; set; }
        
        //not implemented:
        public bool DontUseVirtualNetworks { get; set; }

    }

    public class Project
    {
        public string ProjectName { get; set; }
        public ProjectSetting ProjectSettings { get; set; }
        public CloudServiceSetting CloudServiceSettings { get; set; }
        public VmSetting VmSettings { get; set; }
        public List<Vm> Vms { get; set; }
        public network Network { get; set; }
        public List<PostDeploymentScript> PostDeploymentScripts { get; set; }
        
    }

    public class Subscription
    {
        public string SubscriptionDisplayName { get; set; }
        public string SubscriptionId { get; set; }
        public List<Project> Projects { get; set; }
        public ProjectSetting ProjectSettings { get; set; }
        public CloudServiceSetting CloudServiceSettings { get; set; }
        public VmSetting VmSettings { get; set; }

    }

    public class Deployment
    {
        public string DeploymentName { get; set; }
        public List<Subscription> Subscriptions { get; set; }
        public ProjectSetting ProjectSettings { get; set; }
        public CloudServiceSetting CloudServiceSettings { get; set; }
        public VmSetting VmSettings { get; set; }
    }
}
