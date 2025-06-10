# PowerShell script to deploy gadget for development and restart Windows Sidebar
$gadgetFolder = "HomeAssistantGadget"
$sidebarGadgetDir = "$env:LocalAppData\Microsoft\Windows Sidebar\Gadgets\HomeAssistant.gadget"

# Remove old gadget files if they exist
if (Test-Path $sidebarGadgetDir) { Remove-Item $sidebarGadgetDir -Recurse -Force }

# Copy new gadget files
Copy-Item $gadgetFolder $sidebarGadgetDir -Recurse
Write-Host "Gadget files copied to: $sidebarGadgetDir"

# Restart Windows Sidebar (sidebar.exe)
$sidebarProc = Get-Process sidebar -ErrorAction SilentlyContinue
if ($sidebarProc) {
    Stop-Process -Name sidebar -Force
    Start-Sleep -Seconds 2
}
Start-Process "$env:ProgramFiles\Windows Sidebar\sidebar.exe"
Write-Host "Windows Sidebar restarted. All gadgets reloaded."
