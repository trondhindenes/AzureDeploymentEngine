function Get-AzdeCredobject 
{
    Param (
        [AzureDeploymentEngine.Credential]$credential
    )

    if ($credential.PSCredential)
    {
        
        $credobject = $credential.PSCredential
        return $credobject
    }

    if ($credential.CredentialType -eq "cleartext")
    {
        #Construct object from cleartext
        $Strpassword = $credential.Password
        $Strusername = $credential.UserName

        if ($credential.Domain)
        {
            $Strusername = $credential.Domain + "\" + $Strusername
        }

        $securePassword = $Strpassword | ConvertTo-SecureString -AsPlainText -Force
        $credobject = new-object System.Management.Automation.PSCredential($Strusername,$securePassword)

        return $credobject
    }


}