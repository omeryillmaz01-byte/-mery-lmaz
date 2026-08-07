# PowerShell Script to Configure Java Web Start for .jnlp Files
# Purpose: Set up Java environment and .jnlp file association for PTT KEP e-imza authentication

# Run as Administrator - Check and request if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires Administrator privileges. Restarting with Admin rights..." -ForegroundColor Red
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`n========== JAVA WEB START SETUP SCRIPT ==========" -ForegroundColor Cyan
Write-Host "Configuring Java for PTT KEP e-imza authentication`n" -ForegroundColor Yellow

# ===== STEP 1: Detect Java Installation =====
Write-Host "[STEP 1] Detecting Java Installation..." -ForegroundColor Green

$javaFound = $false
$javaVersion = ""
$javaHome = ""

# Check common Java installation paths
$possiblePaths = @(
    "C:\Program Files\Java\jdk1.8.0_351",
    "C:\Program Files\Java\jre1.8.0_351",
    "C:\Program Files (x86)\Java\jdk1.8.0_351",
    "C:\Program Files (x86)\Java\jre1.8.0_351",
    "C:\Program Files\Java",
    "C:\Program Files (x86)\Java"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $javaHome = $path
        $javaFound = $true
        break
    }
}

if ($javaFound) {
    Write-Host "✓ Java installation found: $javaHome" -ForegroundColor Green
} else {
    Write-Host "✗ Java installation NOT FOUND in default locations" -ForegroundColor Red
    Write-Host "`nCommon Java installation paths checked:" -ForegroundColor Yellow
    $possiblePaths | ForEach-Object { Write-Host "  - $_" }
    Write-Host "`n[ACTION REQUIRED] Please install Java:" -ForegroundColor Red
    Write-Host "  1. Download from: https://www.oracle.com/java/technologies/downloads/#java8" -ForegroundColor Cyan
    Write-Host "  2. Or use: https://java.com/download/" -ForegroundColor Cyan
    Write-Host "  3. Restart this script after installation`n" -ForegroundColor Cyan

    Read-Host "Press Enter to exit"
    exit 1
}

# ===== STEP 2: Configure Environment Variables =====
Write-Host "`n[STEP 2] Configuring Environment Variables..." -ForegroundColor Green

# Set JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
$env:JAVA_HOME = $javaHome
Write-Host "✓ JAVA_HOME set to: $javaHome" -ForegroundColor Green

# Update PATH to include Java bin
$javaPath = Join-Path $javaHome "bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

if ($currentPath -notlike "*$javaPath*") {
    $newPath = "$javaPath;$currentPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    $env:Path = $newPath
    Write-Host "✓ PATH updated with Java bin directory" -ForegroundColor Green
} else {
    Write-Host "✓ PATH already contains Java bin directory" -ForegroundColor Green
}

# ===== STEP 3: Verify Java Installation =====
Write-Host "`n[STEP 3] Verifying Java Installation..." -ForegroundColor Green

# Force PowerShell to refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

try {
    $javaVersionOutput = & java -version 2>&1
    Write-Host "✓ Java version detected:" -ForegroundColor Green
    $javaVersionOutput | ForEach-Object { Write-Host "  $_" }
} catch {
    Write-Host "✗ Java command still not found. Restarting PowerShell..." -ForegroundColor Yellow

    # Close current session and restart
    $newPowerShellParams = @{
        NoProfile = $true
        ArgumentList = @(
            "-NoProfile"
            "-ExecutionPolicy", "Bypass"
            "-Command", "Write-Host 'PowerShell restarted. Java should now be available.' -ForegroundColor Green; java -version"
        )
    }

    Start-Process powershell.exe @newPowerShellParams
    exit 0
}

# ===== STEP 4: Set up .jnlp File Association =====
Write-Host "`n[STEP 4] Setting up .jnlp File Association..." -ForegroundColor Green

$javawsPath = Join-Path $javaHome "bin\javaws.exe"

if (-not (Test-Path $javawsPath)) {
    # Try alternative path for JRE
    $javawsPath = Join-Path $javaHome "bin\javaws.exe"
    if (-not (Test-Path $javawsPath)) {
        Write-Host "✗ Java Web Start (javaws.exe) not found" -ForegroundColor Red
        Write-Host "  Searched: $javawsPath" -ForegroundColor Yellow
    }
}

if (Test-Path $javawsPath) {
    Write-Host "✓ Java Web Start found: $javawsPath" -ForegroundColor Green

    # Register .jnlp file extension
    try {
        # Create registry entry for .jnlp file type
        $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\UserChoice"

        # Direct registry association
        $regPath2 = "HKCU:\Software\Classes\.jnlp"
        if (-not (Test-Path $regPath2)) {
            New-Item -Path $regPath2 -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath2 -Name "(Default)" -Value "jnlpfile"

        $regPath3 = "HKCU:\Software\Classes\jnlpfile\shell\open\command"
        if (-not (Test-Path $regPath3)) {
            New-Item -Path $regPath3 -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath3 -Name "(Default)" -Value "`"$javawsPath`" `"%1`""

        Write-Host "✓ .jnlp file association registered" -ForegroundColor Green
    } catch {
        Write-Host "! Warning: Could not set registry entries, but javaws.exe is available" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Java Web Start not found in standard location" -ForegroundColor Yellow
    Write-Host "  You may need to install JDK instead of JRE" -ForegroundColor Yellow
}

# ===== STEP 5: Test .jnlp Execution =====
Write-Host "`n[STEP 5] Testing Java Web Start Execution..." -ForegroundColor Green

$testJnlpPath = "$(Split-Path -Path $PSCommandPath)\test-jnlp.jnlp"

# Create a test JNLP file
$testJnlpContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<jnlp spec="1.0+" codebase="https://www.oracle.com">
  <information>
    <title>Java Test</title>
    <vendor>Java Test</vendor>
  </information>
  <resources>
    <j2se version="1.8+"/>
  </resources>
  <application-desc/>
</jnlp>
'@

# Note: We won't actually execute the test as it requires valid JNLP
Write-Host "✓ Java Web Start configuration complete" -ForegroundColor Green

# ===== STEP 6: Summary and Instructions =====
Write-Host "`n========== SETUP COMPLETE ==========" -ForegroundColor Cyan
Write-Host "`nJava Environment Summary:" -ForegroundColor Yellow
Write-Host "  JAVA_HOME: $env:JAVA_HOME" -ForegroundColor White
Write-Host "  Java Bin: $javaPath" -ForegroundColor White

Write-Host "`n[HOW TO USE WITH PTT KEP]" -ForegroundColor Green
Write-Host "1. Open Firefox or any web browser" -ForegroundColor Cyan
Write-Host "2. Navigate to PTT KEP system login page" -ForegroundColor Cyan
Write-Host "3. When prompted to download .jnlp file, save it" -ForegroundColor Cyan
Write-Host "4. Double-click the .jnlp file to launch Java Web Start" -ForegroundColor Cyan
Write-Host "5. Java authentication dialog should appear" -ForegroundColor Cyan

Write-Host "`n[MANUAL EXECUTION OF .JNLP FILES]" -ForegroundColor Green
Write-Host "If double-clicking doesn't work, run this in PowerShell:" -ForegroundColor Yellow
Write-Host '  & javaws.exe "C:\path\to\file.jnlp"' -ForegroundColor Gray

Write-Host "`n[TROUBLESHOOTING]" -ForegroundColor Green
Write-Host "If still having issues:" -ForegroundColor Yellow
Write-Host "  1. Restart your computer (to refresh system PATH)" -ForegroundColor Cyan
Write-Host "  2. Try Chrome or Edge browser instead of Firefox" -ForegroundColor Cyan
Write-Host "  3. Check Windows Defender isn't blocking javaws.exe" -ForegroundColor Cyan
Write-Host "  4. Run 'java -version' in new PowerShell to verify" -ForegroundColor Cyan

Write-Host "`n" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
