$Path = "C:\Program Files\WindowsPowerShell\Configuration"

Set-Location -Path $Path -Verbose

[DSCLocalConfigurationManager()]
configuration AzureAutomationPullConfig
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationMode = 'ApplyAndMonitor'
            ConfigurationModeFrequencyMins = 15
            ActionAfterReboot = 'ContinueConfiguration'
        }

        ConfigurationRepositoryWeb AzureAutomation
        {
            ServerURL = 'https://eus2-agentservice-prod-1.azure-automation.net/accounts/06cdb295-ad88-49be-a02b-29216f429920'
            RegistrationKey = 'YMrfwyCqMWiaBKNNfKzgiYXSTg33YZ/r+aiamKLfX+68PTsN5+XdBDETO3gfXaGgvVJ5naKebBlJnMwKtnthKQ=='
            ConfigurationNames = 'FrontEndWebServerTest.FrontEndWebServer'
        }

        ResourceRepositoryWeb AzureAutomation
        {
            ServerURL = 'https://eus2-agentservice-prod-1.azure-automation.net/accounts/06cdb295-ad88-49be-a02b-29216f429920'
            RegistrationKey = 'YMrfwyCqMWiaBKNNfKzgiYXSTg33YZ/r+aiamKLfX+68PTsN5+XdBDETO3gfXaGgvVJ5naKebBlJnMwKtnthKQ=='
        }

        ReportServerWeb AzureAutomation
        {
            ServerURL = 'https://eus2-agentservice-prod-1.azure-automation.net/accounts/06cdb295-ad88-49be-a02b-29216f429920'
            RegistrationKey = 'YMrfwyCqMWiaBKNNfKzgiYXSTg33YZ/r+aiamKLfX+68PTsN5+XdBDETO3gfXaGgvVJ5naKebBlJnMwKtnthKQ=='
        }
    }
}

AzureAutomationPullConfig

Set-DscLocalConfigurationManager -Path ($Path + "\AzureAutomationPullConfig") -Verbose