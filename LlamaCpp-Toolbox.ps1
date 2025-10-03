# LlamaCpp-Toolbox.ps1
# Initialize the program then install or run it.
# This also acts as the toolbox environment setup script.

# Llama.cpp-Toolbox version
$global:version = "0.31.0"

#$global:debug = $true

# The directory where LlamaCpp-Toolbox.ps1 is initialized.
$global:path = $PSScriptRoot 

# Ensure we are starting on the right path.
Set-Location $path 

### --- Environment PATH Fix --- ###
# Relaunching into a dev console can sometimes fail to inherit the full user PATH.
# We will manually reconstruct it to ensure git, winget, and pyenv are found.
try {
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

    # Combine the existing path with the machine, user, and winget paths.
    $existingPath = $env:PATH.Split(';')
    $fullPath = ($existingPath + $machinePath.Split(';') + $userPath.Split(';') + $wingetPath) | Select-Object -Unique
    
    # Reassemble and set the new PATH
    $env:PATH = $fullPath -join ';'
    Write-Host "Successfully reconstructed environment PATH to find external tools." -ForegroundColor DarkGreen
}
catch {
    Write-Warning "Could not automatically fix the environment PATH. If you see errors about 'git' or 'winget' not being found, please run this script from a 'Developer Command Prompt for VS 2022' terminal directly."
}
### --- End of Environment PATH Fix --- ###

### Find installed VS developer tools ###
function Find-VsDevCmd {
    try {
        # vswhere is the official tool to find VS installations
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (-not (Test-Path $vswhere)) {
            Write-Warning "vswhere.exe not found. Cannot locate Visual Studio."
            return $null
        }
        
        $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        
        if ($vsPath) {
            $devCmdPath = Join-Path $vsPath "Common7\Tools\VsDevCmd.bat"
            if (Test-Path $devCmdPath) {
                return $devCmdPath
            }
        }
        return $null
    }
    catch {
        Write-Warning "Failed to find VsDevCmd.bat: $_"
        return $null
    }
}

# --- Environment Setup: Ensure we are running in a VS Developer Shell ---
if (-not $env:VSCMD_ARG_TGT_ARCH) {
    Write-Host "Not in a developer environment. Relaunching..." -ForegroundColor Yellow
    
    $devCmdPath = Find-VsDevCmd
    
    if (-not $devCmdPath) {
        Write-Error "Visual Studio 2019 or newer with the 'Desktop development with C++' workload is required."
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Could not find a valid Visual Studio C++ environment.`n`nPlease install 'Visual Studio Build Tools 2022' (or Community/Pro/Enterprise).`n`nIMPORTANT: During installation, you MUST select the 'Desktop development with C++' workload.`n`nAfter installation, please run this script again.", "Prerequisite Missing", "OK", "Error")
        Start-Process "https://visualstudio.microsoft.com/visual-cpp-build-tools/"
        Exit
    }
    
    $currentScript = $PSCommandPath
    $cmdArgs = "/k "" ""$devCmdPath"" -arch=x64 && powershell.exe -NoProfile -NoExit -File ""$currentScript"" "" "
    Start-Process cmd.exe -ArgumentList $cmdArgs
    Exit
}
# --- End of Environment Setup ---

# Define global paths and settings
$global:models = "$path\llama.cpp\models" 
$global:NumberOfCores = [Environment]::ProcessorCount / 2 

### Function to install vcpkg and curl ###
function Install-VcpkgAndCurl {
    Write-Host "--- Starting vcpkg and curl installation ---" -ForegroundColor Cyan
    $vcpkgDir = "$path\vcpkg"
    try {
        if (-not (Test-Path $vcpkgDir)) { git clone https://github.com/microsoft/vcpkg.git $vcpkgDir }
        if (-not (Test-Path "$vcpkgDir\vcpkg.exe")) { & "$vcpkgDir\bootstrap-vcpkg.bat" -disableMetrics }
        
        Write-Host "Installing curl via vcpkg. EXPECT A LONG WAIT." -ForegroundColor Yellow
        $originalPath = $env:PATH
        $env:PATH = ($env:PATH.Split(';') | Where-Object { $_ -notlike '*pyenv*' }) -join ';'
        Set-Location $vcpkgDir
        & ".\vcpkg.exe" install curl:x64-windows
        & ".\vcpkg.exe" integrate install
    }
    catch {
        Write-Error "A critical error occurred during vcpkg setup: $_"; Read-Host "Press Enter to exit."; Exit
    }
    finally {
        if ($originalPath) { $env:PATH = $originalPath }
        Set-Location $path
    }
    Write-Host "--- vcpkg and curl installation completed successfully! ---" -ForegroundColor Green
}

### Function to install ccache ###
function Install-Ccache {
    Write-Host "Installing ccache for faster compilation..." -ForegroundColor Cyan
    try {
        winget install --id ccache.ccache -e --accept-source-agreements --accept-package-agreements
        if (Get-Command ccache -ErrorAction SilentlyContinue) { Write-Host "ccache successfully installed." -ForegroundColor Green }
        else { throw "ccache command not found after install. A manual restart might be required." }
    }
    catch {
        Write-Error "An error occurred during ccache installation: $_"; Read-Host "Press Enter to continue."
    }
}

# Check for all prerequisites and install them if missing.
function PreReqs {
    Write-Host "--- Verifying Prerequisites and Environment ---" -ForegroundColor Cyan
    $setupComplete = $false
    while (-not $setupComplete) {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Warning "Git is not found."; Read-Host "Press Enter to install Git, then close this window and re-run the script."; winget install --id Git.Git -e; Exit
        }
        if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
            Write-Warning "pyenv-win is not found."; Read-Host "Press Enter to install pyenv-win. The script will restart automatically."
            Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
            Write-Host "Relaunching in a new developer console..." -ForegroundColor Yellow; Start-Sleep -Seconds 3
            $devCmdPath = Find-VsDevCmd
            $currentScript = $PSCommandPath; $cmdArgs = "/k "" ""$devCmdPath"" -arch=x64 && powershell.exe -NoProfile -NoExit -File ""$currentScript"" "" "; Start-Process cmd.exe -ArgumentList $cmdArgs; Exit
        }
        if (-not (Test-Path "$path\vcpkg\scripts\buildsystems\vcpkg.cmake")) {
            Write-Warning "vcpkg with curl is not found."; Read-Host "Press Enter to begin the vcpkg installation (20-40 minutes)."; Install-VcpkgAndCurl; continue
        }
        $requiredPythonVersion = "3.10.11"
        if (-not ((pyenv versions --bare) -contains $requiredPythonVersion)) {
            Write-Warning "Required Python version ($requiredPythonVersion) is not installed."; Write-Host "Installing via pyenv..."; pyenv install $requiredPythonVersion; pyenv rehash; continue
        }
        if (-not (Get-Command ccache -ErrorAction SilentlyContinue)) {
            $choice = Read-Host "Install 'ccache' to dramatically speed up future rebuilds? (y/n)"
            if ($choice -eq 'y') { Install-Ccache; continue }
        }
        Write-Host "All prerequisites are installed and ready." -ForegroundColor Green
        pyenv local $requiredPythonVersion; $setupComplete = $true
    }
}

# Main execution logic.
function Main {
    # Handle the bootstrap scenario (running from outside the project folder)
    if ($path -notmatch "[/\\]Llama\.Cpp-Toolbox$") {
        Write-Host "Bootstrapping: Script is not in the 'Llama.Cpp-Toolbox' directory." -ForegroundColor Yellow
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Warning "Git is required to download the toolbox."; Read-Host "Press Enter to install Git, then re-run this script."; winget install --id Git.Git -e; Exit
        }
        Write-Host "Cloning the repository..."
        git clone https://github.com/3Simplex/Llama.Cpp-Toolbox.git
        $newScriptPath = Join-Path $path "Llama.Cpp-Toolbox\LlamaCpp-Toolbox.ps1"
        if (! (Test-Path $newScriptPath)) {
            Write-Error "Failed to clone repository."; Read-Host "Press Enter to exit."; Exit
        }
        $devCmdPath = Find-VsDevCmd
        $cmdArgs = "/k "" ""$devCmdPath"" -arch=x64 && powershell.exe -NoProfile -NoExit -File ""$newScriptPath"" "" "
        Start-Process cmd.exe -ArgumentList $cmdArgs

        # Gracefully close this bootstrap window after launching the new one.
        Write-Host "Bootstrap complete. The new window has been opened. This temporary window will now close." -ForegroundColor Green
        Start-Sleep -Seconds 3 # Give user time to read the message
        (Get-Process -Id $PID).CloseMainWindow() | Out-Null
        Exit
    }

    # Verify installation integrity (running from inside the folder)
    if (-not (Test-Path "$path\lib\modules\Toolbox-Functions.psm1")) {
        Write-Error "FATAL: Essential module files are missing from the 'lib' directory."
        Write-Error "Your installation may be corrupt. Please try running 'git reset --hard' or re-cloning the repository."
        Read-Host "Press Enter to exit."
        Exit
    }
    
    # Proceed with normal startup.
    PreReqs

    # Load modules now that all prerequisites are confirmed.
    Import-Module $path\lib\modules\Toolbox-Config.psm1 
    Import-Module $path\lib\modules\Llama-Chat.psm1
    Import-Module $path\lib\modules\Toolbox-Functions.psm1
    Import-Module $path\lib\modules\Toolbox-GUI.psm1
    Import-Module $path\lib\modules\Toolbox-Functions-Args.psm1
    Import-Module $path\lib\modules\Toolbox-GUI-ProcessManager.psm1

    # Check if this is the user's first time running the fully set up toolbox.
    if (-not (Test-Path "$path\lib\settings\config.json")) { $global:firstRun = "True" }

    # If the llama.cpp directory is missing, install it.
    if (-not (Test-Path "$path\llama.cpp")) {
        Write-Warning "The llama.cpp directory is missing. Installing it now..."; InstallLlama; $global:firstRun = "True" 
    }

    # Populate the GUI with the latest info.
    VersionCheck; SetButton; GitIgnore; ListScripts; ListModels

    # If the $firstRun flag was set, show the welcome message.
    if ($global:firstRun -eq "True") {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("This is your first run!`n`nI've already selected the most recent llama.cpp release for you.`n`nI'm opening the config form now. You should choose the device you wish to 'build' for (e.g., cuda, vulkan) and click 'Commit'.`n`nThen close the config form to trigger the first build.", "Welcome to Llama.cpp Toolbox!", "OK", "Information")
        ConfigForm
    }

    # Start the GUI.
    $main_form.ShowDialog()
}

# --- Run the program ---
Main