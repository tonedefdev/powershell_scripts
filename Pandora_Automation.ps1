$URL = 'http://nvapandora.nvanet.com/pandora_console/'
$Credentials = $host.UI.PromptForCredential('Your Credentials', 'Enter Credentials', '', '')

$Pandora = Invoke-WebRequest -Uri "http://nvapandora.nvanet.com/pandora_console/index.php?sec=gagente&sec2=godmode/agentes/configurar_agente" -SessionVariable my_session

$Form = $Pandora.Forms[0]

$Form.Fields['nick'] = $Credentials.UserName
$Form.Fields['pass'] = $Credentials.GetNetworkCredential().Password

$Login = Invoke-WebRequest -Uri ($Form.Action) -WebSession $my_session -Method POST -Body $Form.Fields

Start-Sleep -Seconds 2

$Form = $Login.Forms[1]
$Form.Fields['text-alias'] = "NEWONE"
$Form.Fields['text-direccion'] = "10.8.51.250"
$Form.Fields['hidden-quiet_sent'] = 0
$Form.Fields['hidden-create_agent'] = 0

$Submit = Invoke-WebRequest -Uri ($URL + $Form.Action) -WebSession $my_session -Method POST -Body $Form.Fields

