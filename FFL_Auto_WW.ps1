$ESPNFFL = "https://www.espn.com/fantasy/football/"

$ESPN = New-Object -ComObject InternetExplorer.Application
$ESPN.visible = $true
$ESPN.navigate($ESPNFFL)
while ($ESPN.Busy -eq $true) {Start-Sleep -Seconds 1}

Start-Sleep -Seconds 8
$Login = "med button-alt sign-in"
($ESPN.Document.getElementsbyClassName($Login) | Select -First 1).Click()

Start-Sleep -Seconds 8
$Login = "ng-pristine ng-invalid ng-invalid-required ng-valid-pattern ng-touched"
($ESPN.Document.getElementsbyClassName($Login) | Select -First 1).Click()
while ($ESPN.Busy -eq $true) {Start-Sleep -Seconds 1}

