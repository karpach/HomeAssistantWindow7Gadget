# PowerShell script to build a Windows Gadget (.gadget file)
$gadgetFolder = "HomeAssistantGadget"
$outputGadget = "HomeAssistant.gadget"
$tempZip = "HomeAssistant.zip"

# Remove old files if they exist
if (Test-Path $tempZip) { Remove-Item $tempZip }
if (Test-Path $outputGadget) { Remove-Item $outputGadget }

# Zip the contents of the gadget folder (not the folder itself)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($gadgetFolder, $tempZip)

# Rename .zip to .gadget
Rename-Item $tempZip $outputGadget

Write-Host "Gadget built: $outputGadget"
Write-Host "To test: Double-click $outputGadget on Windows 7 to install the gadget."
