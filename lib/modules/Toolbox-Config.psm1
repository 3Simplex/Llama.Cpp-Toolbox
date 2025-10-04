# Toolbox-Config.psm1
# Ordered JSON Config Module for Llama.Cpp-Toolbox

# Toolbox Config Text Version
$global:version_cfg = "0.2.5"



# Default configuration as an ordered array of entries
$script:defaultConfig = @(
    @{
        "type" = "config"
        "key" = "Llama.Cpp-Toolbox"
        "value" = $version
    },
    @{
        "type" = "config"
        "key" = "Config-Version"
        "value" = $global:version_cfg
    },
    @{
        "type" = "config"
        "key" = "rebuild"
        "value" = $false
    },
    @{
        "type" = "config"
        "key" = "build"
        "value" = "default"
    },
    @{
        "type" = "config"
        "key" = "repo"
        "value" = "ggml-org/llama.cpp.git"
    },
    @{
        "type" = "config"
        "key" = "branch"
        "value" = "master"
    },
    @{
        "type" = "config"
        "key" = "dev_branch"
        "value" = "default"
    },
    @{
        "type" = "config"
        "key" = "release_branch"
        "value" = "default"
    },
    @{
        "type" = "config"
        "key" = "symlinkdir"
        "value" = "$path\Symlinks"
    },
    @{
        "type" = "config"
        "key" = "minCtx"
        "value" = 4096
    },
    @{
        "type" = "config"
        "key" = "cutLayers"
        "value" = 0
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "symlink"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "model-list"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-cli -cnv --prompt `"Your system prompt.`""
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-server 8080"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-server 8080 --top-k 1 --n-predict 128 --reasoning-budget 0  --threads -1 --jinja --flash-attn auto --cache-type-k q8_0 --cache-type-v q8_0"
    },
        @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-server 8080 --top-k 40 --n-predict -1 --reasoning-budget -1  --threads -1 --jinja --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-cvector-generator -c 2048 -ngl 10 --positive-file `"$path\llama.cpp\examples\cvector-generator\positive.txt`" --negative-file `"$path\llama.cpp\examples\cvector-generator\negative.txt`""
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "convert_hf_to_gguf.py"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "convert_gptj_to_gguf.py"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "convert_legacy_llama.py"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "convert_legacy_llama.py bpe"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q2_K"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q2_K_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q3_K"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q3_K_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q3_K_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q3_K_L"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q4_0"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q4_1"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q4_K"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q4_K_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q4_K_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q5_0"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q5_1"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q5_K"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q5_K_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q5_K_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q6_K"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe Q8_0"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ4_NL"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ4_XS"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ3_XXS"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ3_XS"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ3_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ3_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ2_XXS"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ2_XS"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ2_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ2_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ1_S"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "llama-quantize.exe IQ1_M"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py dump"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py keys"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py architecture"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py context_length"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py block_count"
    },
    @{
        "type" = "command"
        "visibility" = "show"
        "command" = "gguf_dump.py chat_template"
    }
)


# Function to update the config while preserving user's order and allowing new entries
function Update-Config {
    param(
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    # Backup the curent config.
    if (Test-Path $ConfigPath) {cp "$path\lib\settings\config.json" "$path\lib\settings\bak.config.json"}

    if (Test-Path $ConfigPath) {
        $currentConfig = Get-Content $ConfigPath | ConvertFrom-Json
        $defaultEntryOrder = @{}
        $currentEntryOrder = @{}
        
        # Create index of default order
        for ($i = 0; $i -lt $script:defaultConfig.Count; $i++) {
            $defaultEntry = $script:defaultConfig[$i]
            $key = if ($defaultEntry.type -eq "config") { $defaultEntry.key } else { $defaultEntry.command }
            $defaultEntryOrder[$key] = $i
        }
        
        # Create index of current order and entries
        for ($i = 0; $i -lt $currentConfig.Count; $i++) {
            $entry = $currentConfig[$i]
            $key = if ($entry.type -eq "config") { $entry.key } else { $entry.command }
            $currentEntryOrder[$key] = $i
        }
        
        # Create new config array
        $newConfig = @()
        $processedKeys = @{}
        
        # First, add all existing entries in their current order
        foreach ($entry in $currentConfig) {
            $key = if ($entry.type -eq "config") { $entry.key } else { $entry.command }
            $newConfig += $entry
            $processedKeys[$key] = $true
        }
        
        # Then, add new entries from defaultConfig in their specified order
        foreach ($defaultEntry in $script:defaultConfig) {
            $key = if ($defaultEntry.type -eq "config") { $defaultEntry.key } else { $defaultEntry.command }
            
            if (-not $processedKeys.ContainsKey($key)) {
                # Find the correct position to insert the new entry
                $insertIndex = $newConfig.Count
                
                # Look for the next known entry in defaultConfig to determine insertion point
                for ($i = [array]::IndexOf($script:defaultConfig, $defaultEntry) + 1; $i -lt $script:defaultConfig.Count; $i++) {
                    $nextKey = if ($script:defaultConfig[$i].type -eq "config") { 
                        $script:defaultConfig[$i].key 
                    } else { 
                        $script:defaultConfig[$i].command 
                    }
                    
                    if ($currentEntryOrder.ContainsKey($nextKey)) {
                        $insertIndex = $currentEntryOrder[$nextKey]
                        break
                    }
                }
                
                # Insert the new entry
                $newConfig = $newConfig[0..($insertIndex-1)] + $defaultEntry + $newConfig[$insertIndex..($newConfig.Count-1)]
                
                # Update current entry orders
                for ($i = $insertIndex; $i -lt $newConfig.Count; $i++) {
                    $updateKey = if ($newConfig[$i].type -eq "config") { $newConfig[$i].key } else { $newConfig[$i].command }
                    $currentEntryOrder[$updateKey] = $i
                }
            }
        }
        
        # Save the updated config
        $newConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
    }
    else {
        Restore-Config -ConfigPath $ConfigPath
    }
}

# Function to restore the config to default
function Restore-Config {
    param(
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    if (Test-Path "$path\lib\settings"){ } else { mkdir "$path\lib\settings" }
    $script:defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Force
}

# Function to get config as ordered lines
function Get-ConfigLines {
    param(
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    
    $lines = [System.Collections.ArrayList]::new()
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        
        foreach ($entry in $config) {
            if ($entry.type -eq "config") {
                [void]$lines.Add("$($entry.key)¦$($entry.value)")
            }
            elseif ($entry.type -eq "command") {
                [void]$lines.Add("$($entry.visibility)¦$($entry.command)")
            }
        }
        
        return $lines
    }
    else {
        Write-Error "Config file not found at $ConfigPath"
        return $null
    }
}

# Function to get a specific configuration value
function Get-ConfigValue {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $configEntry = $config | Where-Object { $_.type -eq "config" -and $_.key -eq $Key } | Select-Object -First 1
        if ($configEntry) {
            return $configEntry.value
        }
    }
    return $null
}

# Function to set a specific configuration value
function Set-ConfigValue {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$true)]
        $Value,
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $configEntry = $config | Where-Object { $_.type -eq "config" -and $_.key -eq $Key } | Select-Object -First 1
        if ($configEntry) {
            $configEntry.value = $Value
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        }
        else {
            $newEntry = @{
                "type" = "config"
                "key" = $Key
                "value" = $Value
            }
            $config += $newEntry
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        }
    }
    else {
        Write-Error "Config file not found at $ConfigPath"
    }
}

# Function to set a specific configuration value
function Set-CommandValue {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Visibility,
        [Parameter(Mandatory=$true)]
        $Value,
        [Parameter(Mandatory=$true)]
        $LastValue,
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $configEntry = $config | Where-Object { $_.type -eq "command" -and $_.visibility -eq $Visibility -and $_.command -eq $LastValue } | Select-Object -First 1
        if ($configEntry) {
            $configEntry.command = $Value
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        }
        else {
            $newEntry = @{
                "visibility" = $Visibility
                "type" = "command"
                "command" = $Value
            }
            $config += $newEntry
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        }
    }
    else {
        Write-Error "Config file not found at $ConfigPath"
    }
}


# Function to toggle command visibility
function Set-CommandVisibility {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [Parameter(Mandatory=$true)]
        [ValidateSet("show", "hide")]
        [string]$Visibility,
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    $LastVisibility = if ($Visibility -eq "show") {"hide"}else{"show"}
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $commandEntry = $config | Where-Object { $_.type -eq "command" -and $_.command -eq $Command } | Select-Object -First 1
        if ($commandEntry) {
            $commandEntry.visibility = $Visibility
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        }
        else {
            Write-Error "Command not found in config"
        }
    }
    else {
        Write-Error "Config file not found at $ConfigPath"
    }
}

# Function to get all visible commands
function Get-CommandValues {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Visibility,
        [string]$ConfigPath = "$path\lib\settings\config.json"
    )
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        
        # Filter for command entries that are set to "show" and return just the command text
        $requestedCommands = $config | 
            Where-Object { $_.type -eq "command" -and $_.visibility -eq $Visibility } |
            Select-Object -ExpandProperty command
        
        return $requestedCommands
    }
    return @()
}

Export-ModuleMember -Function Get-ConfigLines, Update-Config, Get-ConfigValue, Set-ConfigValue,
                              Set-CommandValue, Set-CommandVisibility, Restore-Config, Get-CommandValues
