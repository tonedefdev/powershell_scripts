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

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,60)
$progressBar.Size = New-Object System.Drawing.Size(360,50)
$progressBar.Height = 25
$progressBar.Minimum = 1
$progressBar.Maximum = 1000
$progressBar.Value = 1
$progressBar.Step = 1

$CancelButton.Visible = $true
$OKButton.Visible = $true

$form.Controls.Add($progressBar)
$progressBar.Visible = $false
$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $CancelButton.Visible = $false
    $OKButton.Visible = $false
    $progressBar.Visible = $true
    $form.Show()

    for ($i = 0; $i -lt 1000; $i++)
    {
        $label.Text = $i        
        $progressBar.PerformStep()
        $form.Refresh()
    }

    $form.Dispose()
}

$form.Show()