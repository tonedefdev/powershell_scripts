[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Pandora Agent Configuration'
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(100,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(200,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(360,20)
$label.Text = 'Select the Pandora configuration(s) you wish to apply:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(360,20)
$listBox.Height = 80
$listBox.SelectionMode = "MultiExtended"

[void] $listBox.Items.Add('Exchange')
[void] $listBox.Items.Add('DFS')
[void] $listBox.Items.Add('DHCP')
[void] $listBox.Items.Add('Domain Controller')
[void] $listBox.Items.Add('Microsoft SQL')

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Selections = $listBox.SelectedItems
    
    if (!(Test-Path -Path $Path -ErrorAction SilentlyContinue))
	{
		Copy-Item -Path "\\PS-TASKS02\DSCResources\Pandora" -Destination "C:\Temp" -Recurse -Verbose -Force
	}

    foreach ($Selection in $Selections)
    {
        switch ($Selection)
        {
		    "Exchange" 
		    {
			    $Path = "C:\Temp\Pandora\Exchange"
			    $Modules = Get-Content -Path "$Path\Exchange.txt"
		    }
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
		    "Microsoft SQL" 
		    {
			    $Path = "C:\Temp\Pandora\Microsoft SQL"
			    $Modules = Get-Content -Path "$Path\Microsoft SQL"
		    }
			default 
			{
				
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
				    foreach ($File in $Util)
				    {
					    Copy-Item -Path "$OriginUtil\$($File.Name)" -Destination "$UtilPath\$($File.Name)" -Verbose -Force
				    }
			    }
			
			    "scripts"
			    {
				    $OriginScripts = "$Path\scripts"
				    $ScriptsPath = "$PandoraPath\scripts"
				    $Scripts = Get-ChildItem -Path $OriginScripts
				    foreach ($File in $Scripts)
				    {
					    Copy-Item -Path "$OriginScripts\$($File.Name)" -Destination "$ScriptsPath\$($File.Name)" -Verbose -Force
				    }
			    }

			    default
			    {
				    $Origin = "$Path\$($Item.Name)"
				    $Destination = "$PandoraPath\$($Item.Name)"
				    Copy-Item -Path $Origin -Destination $Destination -Verbose -Force
			    }
		    }
            [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
            $PandoraConfig.Add($Modules)
            Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force -Verbose
        }
    }
    $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
    $IP = $IP.trim()
    $PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
    $PandoraConfig[50] = "address $IP"
    Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force -Verbose

    Start-Service -Name PandoraFMSAgent -Verbose

    Remove-Item -Path "C:\Temp\Pandora" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}