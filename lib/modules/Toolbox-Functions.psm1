# Toolbox-Functions.psm1
# Contains the functions.

# Toolbox-Functions version
$global:version_func = "0.2.7"

# Check the version, run UpdateConfig if needed.
function VersionCheck {
    $global:rebuild = Get-ConfigValue -Key "rebuild" # get the value for $rebuild.
    $cfgVersion = Get-ConfigValue -Key "Llama.Cpp-Toolbox" # get the value of last used Toolbox version.
    if ($version -ne $cfgVersion){
    # Get all release notes files
    $releaseNotes = Get-ChildItem "$path\logs\release-notes\*.txt" | Sort-Object Name -Descending

    # Initialize an empty array to store the content
    $allContent = @()

    # Read the content of each file and add it to the array
    foreach ($file in $releaseNotes) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $allContent += (">>> Release Notes: $content",[System.Environment]::NewLine,[System.Environment]::NewLine)
    }

    # Join all content and set it to $TextBox2.Text
    $TextBox2.Text = $allContent -join [System.Environment]::NewLine
    Set-ConfigValue -Key "Llama.Cpp-Toolbox" -Value $version # set the new toolbox version.
    # Get the version of the config text, if it matches the file we can skip this update.
    $cfgVersion = Get-ConfigValue -Key "Config-Version" # get the config-version.
    if ($cfgVersion -ne $version_cfg){
        Set-ConfigValue -Key "Config-Version" -Value $version_cfg # set the new config-version.
        Update-Config # Update the config with new functionality as needed.
        }
    }
}

# Get list of models
function ListModels {
    $subdirectories = Get-ChildItem -Path $models -Directory
    if($global:ComboBox_llm.Items -ne $null){$global:ComboBox_llm.Items.Clear()}
    foreach ($dir in $subdirectories) {
        $global:ComboBox_llm.Items.Add($dir.Name)
    }
    $files = Get-ChildItem -Path "$path\Converted\" -File
    foreach ($file in $files) {
        $global:ComboBox_llm.Items.Add($file.Name)
    }
}

# Get list of scripts from config.
function ListScripts {
    $global:ComboBox2.Items.Clear()
    # Get all visible commands (for GUI display)
    $scripts = Get-CommandValues -Visibility "show"
    foreach ($script in $scripts){
        $global:ComboBox2.Items.Add($script)
    }
}

# Create and update .gitignore if something is tracked it will not be ignored.
function GitIgnore {
    Set-Location $Path
    New-Item -ItemType File -Path "$Path\.gitignore" -Force # Remove the old file to keep it updated with potential changes to git tracking.
    $newList = @()
    $data = git status --porcelain
    foreach ($item in $data) {
      if ($item -match "\?\?") {
        $parts = $item.Trim("\?\? ").Trim('"')
        $newList += $parts
      }
    }
    Set-Content -Path $path\.gitignore -Value $newList
}

# Convert the selected model from source file.
function ConvertModel ($selectedModel, $selectedScript) {
	# Navigate to the directory where llama.cpp resides
	Set-Location -Path $path
	# Activate the virtual environment.
	.\venv\Scripts\activate
    if ($selectedScript -match "bpe"){$option = "--vocab-type bpe"}
    else{$option=''} # did they burn --outtype? It's still an option but stopped working.
    $convertScript = ($selectedScript -split ' ', 2)[0].Trim() # Selected script for conversion.
    if (Test-Path $path\Converted\$selectedModel-f16.gguf){$halt = Confirm "Existing file will be overwritten."} # If the file exists then ask to overwrite.
    if (!$halt){
        if($halt -eq 0){Remove-Item $path\Converted\$selectedModel-f16.gguf}
        # Navigate to the directory containing conversion scripts.
        if ($convertScript -eq "convert_legacy_llama.py"){Set-Location $path\llama.cpp\examples}
        else{Set-Location $path\llama.cpp}
        $label3.Text = "Converting $selectedModel..."
        if ($convertScript -eq "convert_gptj_to_gguf.py"){try{accelerate}catch{pip install accelerate} Set-Location $path\lib\scripts; $command = "python $convertScript $models\$selectedModel"}
        else {$command = "python $convertScript $models\$selectedModel --outfile $path\Converted\$selectedModel-f16.gguf $option"}
        try {
            Invoke-Expression -Command "$command" # "Try" processing, run the command.
        } catch [Exception] {
            $TextBox2.Text = $_.Exception.Message  # Update textbox with error message
            $label3.Text = "Process failed..."
        }
        if ($_.Exception.Message){}
        else{
            $label3.Text = "$selectedModel Converted."
            $TextBox2.Text = "Model successfully exported to $path\Converted\$selectedModel-f16.gguf"
            ListModels}
    }
    deactivate # Deactivate (venv) python environment.
}

# Quantize the selected model from f16 or f32.
function QuantizeModel ( $selectedModel, $selectedScript ) {
    # Navigate to the build directory where llama-quantize.exe resides
    Set-Location -Path $path\llama.cpp\build\bin\Release
    
    if ($selectedModel -match ".gguf") {
        # Get the new models name and prepare it to be used with the option later.
        if ($selectedModel -match "-f16"){$renameModel = ($selectedModel -split "-f16", 2)[0].Trim()}
        if ($selectedModel -match "-f32"){$renameModel = ($selectedModel -split "-f32", 2)[0].Trim()}
        # Extract parts from the selected item in the combobox.
        $executable = ($selectedScript).Split(' ')[0] # The executable to run.
        $outtype = ($selectedScript).Split(' ')[1] # The outtype which will also be used in the name.
        $nthreads = [Environment]::ProcessorCount #$NumberOfCores
        $args = "" # Empty list to be filled with all the args the user wants to apply.
            
        # Get arguments prepared
        foreach ($arg in (($selectedScript).Split(' '))){
            if (($arg -ne $executable)-and($arg -ne $outtype)) {
                $args += "$arg "
            }
        }
        # Write-Host .\llama-quantize.exe $args.Trim() $path\Converted\$selectedModel $path\Converted\$renameModel-$outtype.gguf $outtype $nthreads # debug
        # Quantize the selected model with the new name, selected option and arguments.
        try { & .\llama-quantize.exe $args.Trim() $path\Converted\$selectedModel $path\Converted\$renameModel-$outtype.gguf $outtype $nthreads}
        catch [Exception] {$label3.Text = "Quantizing failed...";$TextBox2.Text = $_.Exception.Message}

        # Update the GUI
        if ($_.Exception.Message) {}
        else {
            $label3.Text = "$selectedModel Quantized using the following args: "+$args.Trim()+" $outtype $nthreads"
            $TextBox2.Text = "Model successfully exported to $path\Converted\$renameModel-$outtype.gguf"
            ListModels
        }
    }

    # If the selected model was not a gguf we can't do anything with it!
    else {
        $label3.Text = "Quantizing failed..."
        $TextBox2.Text = "You must select a .gguf model, either -f16 or -f32"
    }
}

# Generate control vectors for the selected model.
function ControlVectorGenerator ( $selectedModel, $selectedScript ) {
    
    if ($selectedModel -match ".gguf") {
        # Get the models name and prepare it to be used with the option later.
        $modelName = ggufDump $selectedModel "general.name"
        $nameModelDir = $modelName.Replace(" ","-")
        if ($nameModelDir -eq ""){$nameModelDir = "Output"}
        # Extract parts from the selected item in the combobox.
        $executable = ($selectedScript).Split(' ')[0] # The executable to run.
        $nthreads = [Environment]::ProcessorCount /2 #$NumberOfCores
        $arguments = "" # Empty list to be filled with all the args the user wants to apply.

        # Ensure directory exists
        if (Test-Path $path\Generated\Control-Vectors\$nameModelDir){}else{mkdir $path\Generated\Control-Vectors\$nameModelDir}

        # Create timestamp for file to be named
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"

        # Get arguments prepared
        foreach ($argument in (($selectedScript).Split(' '))){
            if ($argument -ne $executable) {
                $arguments = $arguments + "$argument "
            }
        }

        $arguments = $arguments.Trim()
        
        # Navigate to the build directory where llama-cvector-generator.exe resides
        Set-Location -Path $path\llama.cpp\build\bin\Release
        
        if (Test-Path .\llama-cvector-generator.exe) {
            Write-Host "Executable found"
        } else {
            $label3.Text = "Generating control vector failed..."
            $TextBox2.Text = "Executable not found in current directory[System.Environment]::NewLineCurrent directory: $PWD"
            break
        }

        # Clear old info.
        $TextBox2.Text = ""
        
        # Generate cVector for the selected model with the new name, and arguments.        
        $arguments = "--model `"$path\Converted\$selectedModel`" --output-file `"$path\Generated\Control-Vectors\$nameModelDir\$timestamp-control_vector.gguf`" $arguments --threads $nthreads"
        try {
            Start-Process -FilePath ".\llama-cvector-generator.exe" -ArgumentList $arguments -NoNewWindow -Wait
        }
        catch [Exception] {
            $label3.Text = "Generating control vector failed..."
            $TextBox2.Text = $_.Exception.Message
        }

        # Update the GUI
        if ($TextBox2.Text -ne "") {}
        else {
            $label3.Text = "Generated control vector for $selectedModel"
            $TextBox2.Text = "Successfully generated control vector, $path\Generated\Control-Vectors\$nameModelDir\$timestamp-control_vector.gguf",[System.Environment]::NewLine,[System.Environment]::NewLine,"Generated using the following args: `".\llama-cvector-generator.exe --model $path\Converted\$selectedModel --output-file $path\Generated\Control-Vectors\$nameModelDir\$timestamp-control_vector.gguf $arguments`""
        }
    }

    # If the selected model was not a gguf we can't do anything with it!
    else {
        $label3.Text = "Generating control vector failed..."
        $TextBox2.Text = "You must select a .gguf model."
    }
}

# Get a list of models.
function ModelList {
    $fileList = Get-ChildItem -Path $path\Converted

    $label3.Text = "List of gguf models..."
    $option = "name"
    foreach ($file in $fileList) {
        $selectedModel = $file.Name
        $model = $file.Name -replace ("(-f\d+)|(-bf\d+)|(-iQ\d_.*)|(\.iQ\d_.*)|(-Q\d_.*)|(\.Q\d_.*)|(-gguf.*)|(\.gguf.*)","")
        if($list -notmatch $model){$list = $list +"$($model);`n"}
        }
    $TextBox2.Text = $list
}

# Pull metadata from any gguf using the gguf_dump script.
function ggufDump ($selectedModel, $option, $print) {
    # gguf_dump needs a $option and a $selectedModel to fucntion, send that when calling ggufDump.
    # use ($print = 1) if you want it to update the gui with data.
    if ($selectedModel -match ".gguf"){
        # Navigate to the directory where llama.cpp resides
        Set-Location -Path $path
        # Activate the virtual environment.
        .\venv\Scripts\activate
        # Path to the Python script
        $scriptPath = "$path\llama.cpp\gguf-py\gguf\scripts\gguf_dump.py"

        # Target directory containing GGUF files
        $ggufDir = "$path\Converted\"

        # Build the full path to the GGUF file
        $filePath = Join-Path $ggufDir $selectedModel

        # Run the Python script with JSON output and capture the result
        $fileContent = python $scriptPath --json --no-tensors $filePath
    
        $jsonData = ConvertFrom-Json -InputObject $fileContent
        $metadata = $jsonData.metadata
        $matchingKey = ($metadata | Get-Member -Name *"$option").Name | Where-Object { $_ -like "*$option*" } | Select-Object -First 1
        $label3Text = $matchingKey
        try {if ($metadata | Get-Member -Name $matchingKey){
            if ($metadata.$matchingKey.value){
                $value = $metadata.$matchingKey.value -replace '(?<=\{[^}]*)\n(?=[^}]*\})', '\n'}}}
            catch{
                if ($option -eq "dump"){
                $label3Text = "gguf_dump..."
                $value = $fileContent
                } elseif ($option -eq "keys"){
                $label3Text = "Metadata keys..."
                $value = $metadata
                } else {
                $label3Text = "$option does not exist, available metadata keys below."
                $value = $metadata
                }}
            finally{if ($print){$TextBox2.Text = $value -replace '\s*\}\s*\n', ("}"+[Environment]::NewLine); $label3.Text = $label3Text}}
        deactivate # Deactivate (venv) python environment.
        return $value
    }else{$label3.Text = "Failed...";$TextBox2.Text = "You must select a .gguf model to process."}
}

# Update Toolbox if updates found in repo.
function UpdateToolbox {
    cd $path
    $fetch = Invoke-Expression "git fetch" # Check for any updates using Git.
    $gitstatus = Invoke-Expression "git status"
    $TextBox2.Text = $gitstatus
    If ($gitstatus -match "pull") {# If updates exist get and build them.
        $label3.Text = "Updating..."
        $log_name = "Toolbox" # Send this to Log-GitUpdate for the file name.
        $gitstatus = Invoke-Expression "git pull"
        Update-Log $gitstatus $log_name
        Start-Process PowerShell -ArgumentList $path\LlamaCpp-Toolbox.ps1; [Environment]::Exit(1)
        }
    Else {$label3.Text = "No changes to Toolbox detected."}
}

# Update Llama.cpp if repo is changed or if updates found in repo.
function UpdateLlama {
    # The user needs to select a branch to build, thats when the flag is set true.
    Set-ConfigValue -Key "rebuild" -Value "False" # set the value for $rebuild.
    cd $path\llama.cpp
    git checkout master
    $fetch = Invoke-Expression "git fetch" # Check for any updates using Git.
    $gitstatus = Invoke-Expression "git status"
    $TextBox2.Text = $gitstatus
    $log_name = "llamaCpp" # Send this to Log-GitUpdate for the file name.
    If ($gitstatus -match "pull") {# If updates exist get them and update the packages.
        $label3.Text = "Updating..."
        $gitstatus = Invoke-Expression "git pull"
        Update-Log $gitstatus $log_name
        UpdatePackages
        $label3.Text = "Update completed, set a new branch to build."
        }
    Else {$label3.Text = "No changes to llama.cpp detected."}
    $branch = Get-ConfigValue -Key "branch" # get the value for $branch.
    git checkout $branch # Return to expected branch.
}

# Ensure expected packages are installed and ready.
function UpdatePackages {
    Set-Location -Path $path
    
    # Forcefully get the full path to the python executable managed by pyenv.
    # This bypasses any ambiguity in the system PATH.
    $pythonExecutable = pyenv which python
    if ($null -eq $pythonExecutable -or -not (Test-Path $pythonExecutable)) {
        Write-Error "Could not find the python executable managed by pyenv. The script cannot continue."
        Read-Host "Press Enter to exit."
        Exit
    }
    
    Write-Host "Creating virtual environment with: $pythonExecutable" -ForegroundColor Green
    
    # Create the venv using the explicit, correct python version.
    & $pythonExecutable -m venv venv
    
    # Activate the new venv and install all packages into it.
    .\venv\Scripts\activate
    python.exe -m pip install --upgrade pip
    python.exe -m pip install cmake
    python.exe -m pip install -r $path\llama.cpp\requirements.txt
    
    pyenv rehash
    deactivate
}

# Install Llama.Cpp for the toolbox on first run.
function InstallLlama {
    Write-Host "Installing llama.cpp, please wait..." -ForegroundColor Cyan
    Set-Location -Path $path
    if (-not (Test-Path "$path\Converted")) { mkdir $path\Converted }
    git clone --progress --recurse-submodules https://github.com/ggml-org/llama.cpp.git
    
    # Ensure pyenv uses the correct local version before we do anything with Python.
    pyenv local 3.10.11
    pyenv rehash
    
    UpdatePackages
    
    Update-Config # Create the config file
    Set-ConfigValue -Key "rebuild" -Value "True"
    Set-Location -Path $path\llama.cpp
    $branch = Get-NewRelease # Get the latest release version.
    Set-GitBranch $branch # Set the cfg to this branch then build it.
    
    # Set the flag for the main script, but DO NOT call Main here.
    $global:firstRun = "True" 
}


# Build Llama as needed.
function BuildLlama {
    if (Test-Path $path\logs\build){}else{mkdir $path\logs\build} #if the logs dir does not exist make it.
    $label3.Text = "The build flag clears after a rebuild is complete. Building..."
    $build = Get-ConfigValue -Key "build" # get the value for $build.

    $buildFlag = switch ($build) {
        'vulkan' { "-DGGML_VULKAN=ON" }
        'cuda'   { "-DGGML_CUDA=ON" }
        'cpu'    { "-DGGML_NATIVE=ON" }
        default  { throw "Invalid build type: $build" }
    }

    Set-Location $path\llama.cpp
	# Added -DLLAMA_CURL=ON to explicitly enable the feature.
    # Added -DCMAKE_TOOLCHAIN_FILE to point CMake to the vcpkg installation, allowing it to find CURL.
    $vcpkgToolchainFile = "$path\vcpkg\scripts\buildsystems\vcpkg.cmake"
    $cmakeArgs1 = "-B .\build $buildFlag -DGGML_NATIVE=ON -DLLAMA_CURL=ON -DCMAKE_TOOLCHAIN_FILE=$vcpkgToolchainFile"
    $cmakeArgs2 = "--build build --config Release -j $NumberOfCores"

    Write-Warning "Running CMake configure"
    $process = Start-Process -FilePath "cmake" -ArgumentList $cmakeArgs1 -NoNewWindow -PassThru
    Wait-Process -InputObject $process
    if ($process.ExitCode -eq 0){
        Write-Host -ForegroundColor Green "CMake configure completed successfully. Proceeding to build step."
    
        Write-Warning "Running CMake build"
        $TextBox2.Text = "The section `"Generating Code...`" will take a while without updating the screen."
        $process = Start-Process -FilePath "cmake" -ArgumentList $cmakeArgs2 -NoNewWindow -PassThru
        Wait-Process -InputObject $process
    }{Write-Warning "Configure-Error"
    $label3.Text = "Configuration failed."
    $TextBox2.Text = ""
    }
    if ($process.ExitCode -eq 0){
    Write-Host -ForegroundColor Green "CMake build completed successfully."

    Set-ConfigValue -Key "rebuild" -Value "False" # set the value for $rebuild.
    SetButton
    $label3.Text = "Build completed successfully."
    $TextBox2.Text = ""
    }{Write-Warning "Build-Error"
    $label3.Text = "Build failed."
    $TextBox2.Text = ""
    }
}

# Determine the branch in use.
function Get-GitBranch {
    $gitBranch = (git branch | ? { $_ -match '\*' }) -replace '\*', ''
    return $gitBranch.Trim()
}

# Display and log the changes, after asigning a $log_name and using $gitstatus = Invoke-Expression "git pull".
function Update-Log ($gitstatus,$log_name){
    $gitstatusf = $gitstatus -replace '\|', [System.Environment]::NewLine # Format the text from git pull.
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    if (Test-Path $path\logs\updates){}else{mkdir $path\logs\updates} #if the logs dir does not exist make it.
    if ($gitstatusf -ne ""){
    $gitstatusf | Out-File -FilePath "$path\logs\updates\$timestamp-$version-$log_name.txt" -Force
    $TextBox2.Text = $gitstatusf}
    }

# Change the branch to use, $branch is set when changed in ConfigForm.
function Set-GitBranch ($branch) {
    Set-ConfigValue -Key "branch" -Value $branch.Trim() # set the value for $branch.
    git submodule deinit -f --all
    git checkout $branch # Change branch using Git.
    git reset --hard $branch # Remove changes from other repo/branch.
    git submodule update --init --recursive
    UpdatePackages # Ensure the expected packages are installed.
    $label3.Text = "Branch changed, remember to rebuild..."
}

# Change the repo to use, $repo is set when changed in ConfigForm.
function Set-GitRepo ($repo) {
    cd $path\llama.cpp
    Set-ConfigValue -Key "repo" -Value $repo.Trim() #  # set the value for $repo.
    git remote set-url origin https://github.com/$repo # Change repo using Git.
    $fetch = Invoke-Expression "git fetch" # Check for any changes using Git.
    git submodule deinit -f --all
    git reset --hard origin/master # Remove changes from other repo/branch.
    git submodule update --init --recursive
    UpdateLlama
    $label3.Text = "Repo changed, remember to rebuild..."
}

# Llama.Cpp releases use "b####" tags.
# Search all tags that start with 'b', sort them in descending order, select the most recent one.
function Get-NewRelease{
    
    $latestBTag = git tag -l "b*" | Sort-Object -Descending | Select-Object -First 1

    if ($latestBTag) {
        return $latestBTag
    }
}

# Make Symlink for a selected model in the directory you designated in config.
function SymlinkModel {
    $selectedModel = $global:ComboBox_llm.selectedItem # Selected LLM from dropdown list.
    if ($selectedModel -match ".gguf"){
        $symlinkdir = Get-ConfigValue -Key "symlinkdir" # get the value for $symlinkdir.
        $halt = Confirm "Admin permission required to create symlink in... $symlinkdir`n`nContinue?" # If the file exists then ask to overwrite.
        if($halt -eq 0){
            if(test-path $symlinkdir){}else{$halt = Confirm "Create symlink directory in... $symlinkdir`n`nContinue?" ; if($halt -eq 0){mkdir $symlinkdir}}
            $command = "New-Item -Path $symlinkdir -Name $selectedModel -Value $path\Converted\$selectedModel -ItemType SymbolicLink"
            Start-Process -FilePath powershell.exe -ArgumentList "-ExecutionPolicy Bypass -Command $command" -Verb RunAs # Requests admin permission.
        }
        $errormsg = $Error[0].Exception.Message
        $output = "mklink $selectedModel $path\Converted\$selectedModel"
        if($halt-eq 1){$label3.Text = "Symlink provided!"}
        else{if ($errormsg){$label3.Text = $errormsg}
            else{$label3.Text = "Symlink created!"}}
        $TextBox2.Text = $output  # Provides a cmd prompt command which requires admin permission for the user even if they don't approve the automated symlink.
    }else{$label3.Text = "Failed...";$TextBox2.Text = "Select a .gguf to create a symlink"}
}

Export-ModuleMember -Function * -Variable * -Alias *