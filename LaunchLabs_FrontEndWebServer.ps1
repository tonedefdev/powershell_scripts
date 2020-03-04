$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            CertificateFile = "Z:\DscPublicKey.cer"
            Thumbprint = "0f91fb5c2cd559532bb58ce4c92c2cb8b02424d5"
        };
    );
}

Configuration FrontEndWebServer
{

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration
    Import-DscResource -Module CertificateDsc
    Import-DscResource -Module cChoco

        Node $AllNodes.NodeName {

            WindowsFeature IIS 
            {

                Ensure = "Present"
                Name = "Web-Server"

            }

            LocalConfigurationManager 
            {

                CertificateID = "0f91fb5c2cd559532bb58ce4c92c2cb8b02424d5"

            }

            PfxImport AlphaAccountCert
            {

                ThumbPrint = "1c4296632efac256e23f9c18c8ce6b1ee8f5d860"
                Path = "Z:\alpha-account.alexandrialaunchlabs.com.pfx"
                Location = "LocalMachine"
                Store = "WebHosting"
                Credential = $Credential
                DependsOn = "[WindowsFeature]IIS"

            }

            xWebsite "alpha-account.alexandrialaunchlabs.com" 
            
            {
                
                Ensure = "Present"
                Name = "alpha-account.alexandrialaunchlabs.com"
                State = "Started"
                PhysicalPath = "C:\inetpub\wwwroot\alpha-account.alexandrialaunchlabs.com"
                ApplicationPool = "alpha-account.alexandrialaunchlabs.com"

                BindingInfo = @( MSFT_xWebBindingInformation

                    {

                        Protocol = "HTTPS"
                        Port = "443"
                        CertificateThumbprint = "‎1c4296632efac256e23f9c18c8ce6b1ee8f5d860"
                        CertificateStoreName = 'WebHosting'
                        HostName = "alpha-account.alexandrialaunchlabs.com"

                    }

                )

                DependsOn = "[WindowsFeature]IIS","[PfxImport]AlphaAccountCert"

            }

            cChocoinstaller Install 
            {

                InstallDir = "C:\Choco"

            }

            cChocoPackageInstaller DotNetCore
            {
            
                Name = "dotnetcore-windowshosting.install"
                DependsOn = "[cChocoinstaller]Install"

            } 

        }
}