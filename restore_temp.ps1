$source = 'D:\Code\_BACKUPS\farm_dev_2025-10-13_130217\lib\screens\livestock\livestock_management_screen.dart'
$dest = 'D:\Code\farm\lib\screens\livestock\livestock_management_screen.dart'
Copy-Item -Path $source -Destination $dest -Force
Write-Output "✅ Restore สำเร็จ!"
