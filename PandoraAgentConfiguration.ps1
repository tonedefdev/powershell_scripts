$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

Function Show-Powershell()
{
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}

Function Hide-Powershell()
{
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}

Hide-Powershell

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Pandora Agent Configuration'
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(100,130)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(200,130)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,15)
$label.Size = New-Object System.Drawing.Size(360,30)
$label.Text = 'Select the Pandora configuration(s) you wish to apply. Multiple choices can be selected:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,50)
$listBox.Size = New-Object System.Drawing.Size(360,20)
$listBox.Height = 80
$listBox.SelectionMode = "MultiExtended"

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,60)
$progressBar.Size = New-Object System.Drawing.Size(360,50)
$progressBar.Height = 25

[void] $listBox.Items.Add('DFS')
[void] $listBox.Items.Add('DHCP')
[void] $listBox.Items.Add('Domain Controller')
[void] $listBox.Items.Add('Exchange')
[void] $listBox.Items.Add('JDE')
[void] $listBox.Items.Add('Microsoft SQL')

$form.Controls.Add($listBox)
$form.Controls.Add($progressBar)
$progressBar.Visible = $false
$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Selections = $listBox.SelectedItems

    if ($Selections -ne $null)
    {
    	$CancelButton.Visible = $false
		$OKButton.Visible = $false
		$listBox.Visible = $false
		$progressBar.Visible = $true

        $Path = "C:\Temp\Pandora"
        $Artifacts = "\\PS-TASKS02\DSCResources\Pandora"
        
        if (!(Test-Path -Path $Path -ErrorAction SilentlyContinue))
	    {
            New-Item -Path $Path -ItemType Directory | Out-Null
            $Pandora = Get-ChildItem -Path $Artifacts
            $progressBar.Minimum = 1
			$progressBar.Value = 1
			$progressBar.Step = 1
			$progressBar.Maximum = $Pandora.Length
            $form.Show()
            foreach ($File in $Pandora)
            {
                $label.Text = "Copying: $Path\$($File.Name)"
                $form.Refresh()
                Copy-Item -Path "$Artifacts\$($File.Name)" -Destination "$Path\$($File.Name)" -Recurse -Force
                $progressBar.PerformStep()
            }
            Copy-Item -Path "$Path\pandora_agent.conf" -Destination "C:\Program Files\pandora_agent\pandora_agent.conf" -Force
		}

        foreach ($Selection in $Selections)
        {
            switch ($Selection)
            {
		        "DFS" 
		        {
			        $Path = "C:\Temp\Pandora\DFS"
			        $Modules = Get-Content -Path "$Path\DFS.txt"
		        }

		        "DHCP" 
		        {
			        $Path = "C:\Temp\Pandora\DHCP"
			        $Modules = Get-Content -Path "$Path\DHCP.txt"
		        }

                "Domain Controller"
                {
                    $Path = "C:\Temp\Pandora\Domain Controller"
                    $Modules = Get-Content -Path "$Path\Domain Controller.txt"
                }

                "Exchange" 
		        {
			        $Path = "C:\Temp\Pandora\Exchange"
			        $Modules = Get-Content -Path "$Path\Exchange.txt"
		        }

		        "Microsoft SQL" 
		        {
			        $Path = "C:\Temp\Pandora\Microsoft SQL"
			        $Modules = Get-Content -Path "$Path\Microsoft SQL"
		        }
	        }
	
            $PandoraPath = "C:\Program Files\pandora_agent"
            $Items = Get-ChildItem -Path $Path

            foreach ($Item in $Items)
            {
		        switch ($Item.Name)
		        {
			        "util" 
			        {	
				        $OriginUtil = "$Path\util"
				        $UtilPath = "$PandoraPath\util"
				        $Util = Get-ChildItem -Path $OriginUtil
						$progressBar.Minimum = 1
						$progressBar.Value = 1
						$progressBar.Step = 1
						$progressBar.Maximum = $Util.Length
						$form.Show()
						foreach ($File in $Util)
				        {
							$label.Text = "Copying: $OriginUtil\$($File.Name)"
							$form.Refresh()
							Copy-Item -Path "$OriginUtil\$($File.Name)" -Destination "$UtilPath\$($File.Name)" -Force
                            Start-Sleep -Seconds 1
							$progressBar.PerformStep()
						}
			        }
			
			        "scripts"
			        {
				        $OriginScripts = "$Path\scripts"
				        $ScriptsPath = "$PandoraPath\scripts"
						$Scripts = Get-ChildItem -Path $OriginScripts
						$progressBar.Minimum = 1
						$progressBar.Value = 1
						$progressBar.Step = 1
						$progressBar.Maximum = $Scripts.Length
						$form.Show()
				        foreach ($File in $Scripts)
				        {
							$label.Text = "Copying: $OriginScripts\$($File.Name)"
							$form.Refresh()
							Copy-Item -Path "$OriginScripts\$($File.Name)" -Destination "$ScriptsPath\$($File.Name)" -Force
                            Start-Sleep -Seconds 1
							$progressBar.PerformStep()
						}
			        }
		        }

            }

            $progressBar.Minimum = 1
			$progressBar.Value = 1
			$progressBar.Step = 1
			$progressBar.Maximum = 4
            $label.Text = "Inserting modules into '$PandoraPath\pandora_agent.conf'"
			$form.Show()
            Start-Sleep -Seconds 3
            [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
            $PandoraConfig.Add($Modules)
            Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force
            $progressBar.PerformStep()
        }

        $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
        $IP = $IP.trim()
        $label.Text = "Inserting server IP '$IP' into '$PandoraPath\pandora_agent.conf'"
        $form.Refresh()
        Start-Sleep -Seconds 3
        $PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
        $PandoraConfig[50] = "address $IP"
        Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force
        $progressBar.PerformStep()

        $label.Text = "Starting 'Pandora Agent Service'"
        $form.Refresh()
        Start-Sleep -Seconds 3
        Start-Service -Name PandoraFMSAgent
        $progressBar.PerformStep()

        $label.Text = "Cleaning up 'C:\Temp\Pandora'"
        $form.Refresh()
        Remove-Item -Path "C:\Temp\Pandora" -Recurse -Force -ErrorAction SilentlyContinue
        $progressBar.PerformStep()
        $form.Dispose()

        $Exit = [System.Windows.Forms.MessageBox]::Show("Pandora Agent has been successfully configured. Press 'OK' to close.","Pandora Configuration Completed","OK","Information")
        switch ($Exit)
        {
            "OK" {Exit}
        }

    } else {

        $Exit = [System.Windows.Forms.MessageBox]::Show("No Pandora configuration was selected. Choose 'OK' to restart script, or 'Cancel' to exit.","No Pandora Configuration Selected!","OKCancel","Error")
        switch ($Exit)
        {
            "OK"
            {
                $currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
                & "$currentPath\PandoraAgentConfiguration.ps1"
            }

            "Cancel"
            {
                Exit
            }
        }
    }
}