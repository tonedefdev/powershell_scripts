do {
$disk = Get-Disk -UniqueId 60022480119128EE797515B5B353DE76 | Select-Object -ExpandProperty Path
Dismount-DiskImage -ImagePath "$disk"
}
while ($disk -eq "\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}")
Write-Host "Profile Disks Disconnected" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")