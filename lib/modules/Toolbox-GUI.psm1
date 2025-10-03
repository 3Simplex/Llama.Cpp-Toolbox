# Toolbox-GUI.psm1
# Contains the GUI elements.

# todo # Assist with update of Transformers

# Llama.cpp-Toolbox GUI version
$global:version_GUI = "0.1.6"

Add-Type -AssemblyName System.Windows.Forms

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Llama.cpp-Toolbox-$version"
$main_form.Width = 750
$main_form.Height = 700
$main_form.MinimumSize = New-Object System.Drawing.Size(750, 300)
$main_form.MaximumSize = New-Object System.Drawing.Size(1300, 1300)

$menuStrip1 = New-object system.windows.forms.menustrip
$mainMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$mainMenu.Text = "Main Menu"
$mainMenu.ShortcutKeyDisplayString="Ctrl+m"

$configItem = New-Object System.Windows.Forms.ToolStripMenuItem
$configItem.Text = "Config"
$configItem.ShortcutKeyDisplayString="Ctrl+c"
$configItem.Add_Click({ConfigForm})

$processManager = New-Object System.Windows.Forms.ToolStripMenuItem
$processManager.Text = "Process Manager"
$processManager.ShortcutKeyDisplayString="Ctrl+p"
$processManager.Add_Click({Show-ProcessManagerDialog})

$updaterLlama  = New-Object System.Windows.Forms.ToolStripMenuItem
$updaterLlama.Text = "Update Llama.cpp"
$updaterLlama.ShortcutKeyDisplayString="Ctrl+l"
$updaterLlama.Add_Click({ConfirmUpdate "UpdateLlama" "Updating Llama.cpp`n`nYou must set a branch in the Toolbox-Config to rebuild.`n`n Are you sure you want to proceed?" }) # Updates llama.cpp only.

$updaterGui = New-Object System.Windows.Forms.ToolStripMenuItem
$updaterGui.Text = "Update Toolbox"
$updaterGui.ShortcutKeyDisplayString="Ctrl+t"
$updaterGui.Add_Click({ConfirmUpdate "UpdateToolbox" "Updating the Llama.cpp-Toolbox GUI.`n`nThe program will restart after updating.`n`n Are you sure you want to proceed?"}) # Updates the Toolbox only.

$menuStrip1.Items.Add($mainMenu)
$menuStrip1.Items.Add($configItem)
$menuStrip1.Items.Add($processManager)
$mainMenu.DropDownItems.AddRange(@($configItem,$processManager,$updaterLlama,$updaterGui))

$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$helpMenu.Text   = "Help"
$helpMenu.ShortcutKeyDisplayString="F1"

$aboutItem  = New-Object System.Windows.Forms.ToolStripMenuItem
$aboutItem.Text = "About"
$aboutItem.Add_Click({AboutForm})

$menuStrip1.Items.Add($helpMenu)
$helpMenu.DropDownItems.AddRange(@($aboutItem))

$main_form.Controls.Add($menuStrip1)

# Label for Language Models dropdown list.
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select a Language Model:"
$Label.Location = New-Object System.Drawing.Point(10,122)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

# Dropdown list containing Language Models available to process.
$Global:ComboBox_LLM = New-Object System.Windows.Forms.ComboBox
$global:ComboBox_LLM.Width = 600
$global:ComboBox_LLM.Location  = New-Object System.Drawing.Point(10,150)
$global:ComboBox_LLM.DropDownHeight = 200  # Show more of the content in the drop down list.
$main_form.Controls.Add($global:ComboBox_LLM)

# Label for command or script in dropdown list to be processed.
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Type a command or select a pre-configured script from the dropdown:"
$Label.Location = New-Object System.Drawing.Point(10,182)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

# Dropdown list containing scripts to process using the selected Language Model.
$Global:ComboBox2 = New-Object System.Windows.Forms.ComboBox
$global:ComboBox2.Width = 600
$global:ComboBox2.Location  = New-Object System.Drawing.Point(10,210)
$global:ComboBox2.DropDownWidth = 600  # Show more of the content in the drop down list.
$global:ComboBox2.DropDownHeight = 200  # Show more of the content in the drop down list.
$main_form.Controls.Add($global:ComboBox2)

# Button to process a script.
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Location = New-Object System.Drawing.Size(620,208)
$Button1.Size = New-Object System.Drawing.Size(100,23)
$Button1.Text = "Process"
$main_form.Controls.Add($Button1)

# 'Process' button action.
$Button1.Add_Click({
    $label3.Text = "";$TextBox2.Text = "" # Clear the text.
    $selectedDirectory = $global:ComboBox_LLM.Text # Selected language model from dropdown list.
    $selectedScript = $global:ComboBox2.Text # Selected script or command from dropdown list.
    If ($selectedScript -match "model-list") {ModelList} # Only requires Combobox2
    else{
        If ($selectedDirectory -eq $null) {$Label3.Text = "Select a language model and select a script to process."}
        else {
            If ($selectedScript -eq $null) {$Label3.Text = "Select a script to process the language lodel."}
            ElseIf ($selectedScript -match "quantize") {QuantizeModel $selectedDirectory $selectedScript}
            ElseIf ($selectedScript -match "convert") {ConvertModel $selectedDirectory $selectedScript}
            ElseIf (($selectedScript -match "server") -or ($selectedScript -match "cli")) { $returnedProcess = LlamaChat $selectedDirectory $selectedScript $global:HoldingProcess ; $global:HoldingProcess += $returnedProcess } #write-host "HoldingProcess array: $global:HoldingProcess"}
            ElseIf ($selectedScript -match "gguf_dump") {$selectedModel = $global:ComboBox_LLM.Text;$option = ($global:ComboBox2.Text -split ' ', 2)[1].Trim();$print=1;ggufDump $selectedModel $option $print}
            ElseIf ($selectedScript -match "symlink") {SymlinkModel}
            ElseIf ($selectedScript -match "cvector-generator") {ControlVectorGenerator $selectedDirectory $selectedScript}
            else {$Label3.Text = "The script entered:$selected Script was not handled."}
            }
    $print = 0 # Reset the flag so the screen wont show uncalled results from ggufDump.
    }
})

# Label for Status
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Status:"
$Label2.Location  = New-Object System.Drawing.Point(10,262)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)

# Label to display Status
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = ""
$Label3.Location  = New-Object System.Drawing.Point(50,262)
$Label3.AutoSize = $true
$main_form.Controls.Add($Label3)

function SetButton {
    # Check if the button already exists
    $existingButton = $main_form.Controls["BUL_Button"]

    $global:rebuild = Get-ConfigValue -Key "rebuild" # get the value for $rebuild.

    $buttonClickAction = {
        if($global:rebuild -eq "True" -and $global:firstRun -eq "True" ){
            $halt = Confirm "Please be patient, this may take a while. `n`nContinue?" # Inform the user this will take a while.
            if($halt -eq 0){BuildLlama}{}
        }
        elseif($global:rebuild -eq "True"){
            $halt = Confirm "Please be patient, this may take a while. `n`nContinue?" # Inform the user this will take a while.
            if($halt -eq 0){BuildLlama}{}
        } else {
            # Function to 'update' from list of Language Models.
            $label3.Text = ""
            $TextBox2.Text = "" # Clear the text.
            $selectedDirectory = $global:ComboBox_LLM.Text # Selected Language Model from dropdown list.
            If ($selectedDirectory -eq $null) {
                $Label3.Text = "Language Model list updated, select an Language Model to check git status."
            } Else {
                Set-Location $models\$selectedDirectory
                # Check for any updates using Git.
                $gitstatus = Invoke-Expression "git status"
                $TextBox2.Text = $gitstatus
                If ($gitstatus -match "up to date") {
                    $Label3.Text = "No changes to git detected."
                } Else {
                    $Label3.Text =  'Fetching changes...'
                    $gitstatus = Invoke-Expression "git pull"
                    $log_name = "$selectedDirectory"
                    Update-Log $gitstatus $log_name
                    $Label3.Text =  'Model updated!'
                }
            }
            ListModels
        }
    }

    if ($existingButton) {
        # Remove the existing button
        $main_form.Controls.Remove($existingButton)
    }
    # Button doesn't exist, create a new one
    $Button = New-Object System.Windows.Forms.Button
    $Button.Name = "BUL_Button" # Give the button a unique name
    $Button.Location = New-Object System.Drawing.Size(5,29)
    $Button.Size = New-Object System.Drawing.Size(100,23)
    $Button.Text = if($global:rebuild -eq "True" -and $global:firstRun -eq "True" ){"Build"}elseif($global:rebuild -eq "True"){"Rebuild"}else{"Update"}
    $main_form.Controls.Add($Button)

    if($global:rebuild -eq "True" -and $global:firstRun -eq "True" ){$label3.Text = "You must click 'build' before llama.cpp can be used."}elseif($global:rebuild -eq "True"){$label3.Text = "Remember to rebuild to use your updates."}
    # Add click event to the new button
    $Button.Add_Click($buttonClickAction)
    
}

# Textbox for output.
$TextBox2 = New-Object System.Windows.Forms.TextBox
$TextBox2.Anchor = "Top, Left, Right, Bottom"  # Resize with the form
$TextBox2.Multiline = $true
$TextBox2.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
$TextBox2.Location  = New-Object System.Drawing.Point(10,290)
$TextBox2.MinimumSize = New-Object System.Drawing.Size(710,250)  # Adjust width and minimum height
$main_form.Controls.Add($TextBox2)

# Label for Language Models to download.
$Label4 = New-Object System.Windows.Forms.Label
$Label4.Text = "Git Clone Language Model from URL:"
$Label4.Location = New-Object System.Drawing.Point(10,63)
$Label4.AutoSize = $true
$main_form.Controls.Add($Label4)

# Textbox for Language Models URL.
$TextBox1 = New-Object System.Windows.Forms.TextBox
$TextBox1.Width = 600
$TextBox1.Location  = New-Object System.Drawing.Point(10,90)
$main_form.Controls.Add($TextBox1)

# Button to clone a Language Model.
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Size(620,88)
$Button2.Size = New-Object System.Drawing.Size(100,23)
$Button2.Text = "Clone"
$main_form.Controls.Add($Button2)


# 'Clone' button action.
$Button2.Add_Click({
    # Function to clone from url.
    $label3.Text = "";$TextBox2.Text = "" # Clear the text.
    Set-Location $models
    $pattern = "(?<=.*)http\S+"
    $TextBox1.Text -match $pattern
    $cleanURL= $Matches[0]
    If ($cleanURL -ne $null) {
    $label3.Text = "Cloning..."
    git clone --progress $cleanURL
    $label3.Text = "Completed."
    }
    Else{$label3.Text = "No URL found."}
    ListModels
    }

)

# Request confirmation from the user.
function Confirm ($message) {
    $halt = 1 # Never proceed without permission.
    $title = "Confirm"
    $buttons = [System.Windows.Forms.MessageBoxButtons]::YesNo
    $icon = [System.Windows.Forms.MessageBoxIcon]::Question
    $result = [System.Windows.Forms.MessageBox]::Show($message, $title, $buttons, $icon)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {$halt=0;return $halt}
    if ($result -eq [System.Windows.Forms.DialogResult]::No) {$halt=1;return $halt}
}

# Update on request with confirmation.
function ConfirmUpdate ($update, $message) {
    $title = "Confirm Update"
    $buttons = [System.Windows.Forms.MessageBoxButtons]::YesNo
    $icon = [System.Windows.Forms.MessageBoxIcon]::Question
    $result = [System.Windows.Forms.MessageBox]::Show($message, $title, $buttons, $icon)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        if (Test-Path Function:\$update) {&$update}
        if ($repo -match "Toolbox"){
            If ($gitstatus -match "up to date") {$Label3.Text = "No changes to Llama.cpp-Toolbox detected."}
            else {Start-Process PowerShell -ArgumentList $path\LlamaCpp-Toolbox.ps1; [Environment]::Exit(1)}
        }
    }
    if ($result -eq [System.Windows.Forms.DialogResult]::No) {}
}

# Define the AboutForm to display information about the application.
function AboutForm {
    # Create a new form for displaying information about the tool
    $about_form = New-Object System.Windows.Forms.Form

    # Set properties of the form
    $about_form.Text = "About Llama.cpp-Toolbox"
    $about_form.Width = 500
    $about_form.Height = 200
    $about_form.MinimumSize = New-Object System.Drawing.Size(500, 150)
    $about_form.MaximumSize = New-Object System.Drawing.Size(600, 300)

    # Add a label to display the repo and version of Llama.cpp
    $label_about_name = New-Object System.Windows.Forms.Label
    $label_about_name.Text = "Llama.cpp-Version:"
    $label_about_name.Location = New-Object System.Drawing.Point(10, 10)
    $label_about_name.AutoSize = $true
    $label_about_version = New-Object System.Windows.Forms.Label
    $label_about_version.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
    Set-Location $path\llama.cpp
    $label_about_version.Text = (git rev-parse --short HEAD)
    Set-Location $path
    $label_about_version.Location = New-Object System.Drawing.Point(115, 9)
    $label_about_version.AutoSize = $true

    $cfgRepo = Get-ConfigValue -Key "repo" # get-set the flag for repo.
    $cfgbranch = Get-ConfigValue -Key "branch" # get-set the flag for branch.
    $label_about_repo = New-Object System.Windows.Forms.label
    $label_about_repo.Text = "Repo: https://github.com/$cfgRepo $cfgbranch"
    $label_about_repo.Location = New-Object System.Drawing.Point(10, 30)
    $label_about_repo.AutoSize = $true

    # Add the labels to the form and set text for them
    $about_form.Controls.Add($label_about_name)
    $about_form.Controls.Add($label_about_version)
    $about_form.Controls.Add($label_about_repo)

    # Display the about form as a dialog box
    $about_form.ShowDialog()
}

function ConfigForm {
    if($global:debug){Write-Host "Debug: Entering ConfigForm function"}

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Config Llama.cpp-Toolbox"
    $form.Size = New-Object System.Drawing.Size(750, 500)
    if($global:debug){Write-Host "Debug: Created form with size 550x300"}
    
    # Create the bottom Panel first. (form fills from bottom up)
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $panel.AutoSize = $true
    $panel.AutoScroll = $true
    $form.Controls.Add($panel)
    if($global:debug){Write-Host "Debug: Created and added panel to form"}
    
    # Create the top ToolStrip last. (form fills from bottom up)
    $toolStrip = New-Object System.Windows.Forms.ToolStrip
    $toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
    $toolStrip.AutoSize = $true
    $form.Controls.Add($toolStrip)
    if($global:debug){Write-Host "Debug: Created and added toolStrip to form"}

    # Create a ToolStripButton for BranchManager
    $bmButton = New-Object System.Windows.Forms.ToolStripButton
    $bmButton.Text = "Branch Manager"
    $bmButton.Add_Click({BranchManager})
    if($global:debug){Write-Host "Debug: Created Branch Manager button"}

    # Add buttons to the ToolStrip
    $toolStrip.Items.Add($bmButton)
    if($global:debug){Write-Host "Debug: Added Branch Manager button to toolStrip"}

    # Get the config lines from config.json
    function RefreshConfigLines {
        $global:lines = Get-ConfigLines
        if($global:debug){Write-Host "Debug: Refreshed config. Now have $($global:lines.Count) lines from config.txt"}
    }

    # Get list of combobox items for ConfigForm.
    function Get-ComboBoxItems ($labelText, $comboBox) {
        if($global:debug){Write-Host "Debug: Get-ComboBoxItems called for label: $labelText"}
    
        if ($null -eq $comboBox) {
            if($global:debug){Write-Host "Debug: ComboBox is null for label: $labelText"}
            return
        }

        $comboBox.Items.Clear()
        if($global:debug){Write-Host "Debug: Cleared ComboBox items"}

        $items = @()
        switch -Regex ($labelText) {
            "build" {
                $items = @("cpu", "cuda", "vulkan")
                if($global:debug){Write-Host "Debug: Set items for build: $($items -join ', ')"}
            }
            "branch" {
                $items = Get-GitBranch
                if($global:debug){Write-Host "Debug: Got Git branches: $($items -join ', ')"}
            }
        }

        foreach ($item in $items) {
            $comboBox.Items.Add($item)
        }
        if($global:debug){Write-Host "Debug: Added $($items.Count) items to ComboBox"}

        if ($comboBox.Items.Count -gt 0) {
            $comboBox.SelectedIndex = 0
            if($global:debug){Write-Host "Debug: Set SelectedIndex to 0"}
        }

        if($global:debug){Write-Host "Debug: ComboBox now has $($comboBox.Items.Count) items"}
    }

    $global:controlStates = @{}

    function CreateFormControls {
        $panel.Controls.Clear()
        $global:textBoxes = @{}
        $global:formLabels = @{}
        $global:comboBoxes = @{}
        $global:combinedButtons = @{}
        $global:buttonIndices = @{}
        RefreshConfigLines

        $yPosition = 10
    
        foreach ($index in 0..($lines.Count - 1)) {
            $line = $lines[$index]
            if ($line -ne "" -and $line.Split('¦')[0] -notmatch "Toolbox" -and $line.Split('¦')[0] -notmatch "config.txt" -and $line.Split('¦')[0] -notmatch "Config-Version" -and $line.Split('¦')[0] -notmatch "help" -and $line.Split('¦')[0] -notmatch "rebuild" -and $line.Split('¦')[0].Trim() -ne "branch") {
                $parts = $line.Split('¦')
                $labelText = $parts[0].Trim()
                $controlText = $parts[1].Trim()
            
                $label = New-Object System.Windows.Forms.Label
                $label.Text = $labelText
                $label.AutoSize = $true
                $label.Location = New-Object System.Drawing.Point(10, $yPosition)
                $global:formLabels[$index] = $label
                $panel.Controls.Add($label)

                if ($labelText -match "build|branch") {
                    $control = New-Object System.Windows.Forms.ComboBox
                    $global:comboBoxes[$index] = $control
                    Get-ComboBoxItems $labelText $global:comboBoxes[$index]
                } else {
                    $control = New-Object System.Windows.Forms.TextBox
                    $global:textBoxes[$index] = $control
                }

                $control.Name = "Control_$index"
                $control.Text = $controlText
                $control.Location = New-Object System.Drawing.Point(120, $yPosition)
                $control.Width = 500
                $panel.Controls.Add($control)

                $global:controlStates[$index] = @{
                    OriginalText = $controlText
                    LastCommittedText = $controlText
                    HasUncommittedChanges = $false
                }

                CombinedButton $index $yPosition $labelText $control
            
                $yPosition += 30
            }
        }
    }

    function CombinedButton($index, $yPosition, $labelText, $control) {
        $button = New-Object System.Windows.Forms.Button
        $button.Name = "Button_$index"
        $global:buttonIndices[$button] = $index
        $button.Location = New-Object System.Drawing.Point(630, $yPosition)
        $button.Size = New-Object System.Drawing.Size(80,23)
        $button.Text = if ($labelText -match "show") { "hide" } elseif ($labelText -match "hide") { "show" } else { "Commit" }
        $panel.Controls.Add($button)

        $global:combinedButtons[$index] = $button

        if($global:debug){Write-Host "Debug: Initial state for control $($control.Name)"}
        if($global:debug){Write-Host "  Original Text: '$($global:controlStates[$index].OriginalText)'"}
        if($global:debug){Write-Host "  Last Committed Text: '$($global:controlStates[$index].LastCommittedText)'"}
        if($global:debug){Write-Host "  Has Uncommitted Changes: $($global:controlStates[$index].HasUncommittedChanges)"}
        if($global:debug){Write-Host "  Initial Button Text: $($button.Text)"}

        $control.Add_TextChanged({
            $thisControl = $this
            $newText = $thisControl.Text
            $associatedIndex = [int]($thisControl.Name -replace 'Control_', '')
            $state = $global:controlStates[$associatedIndex]
            $associatedButton = $global:combinedButtons[$associatedIndex]
            $associatedLabelText = $global:formLabels[$associatedIndex].Text

            if($global:debug){Write-Host "Debug: Text Changed Event"}
            if($global:debug){Write-Host "  Control: $($thisControl.Name)"}
            if($global:debug){Write-Host "  Associated Label: $associatedLabelText"}
            if($global:debug){Write-Host "  Original Text: '$($state.OriginalText)'"}
            if($global:debug){Write-Host "  Last Committed Text: '$($state.LastCommittedText)'"}
            if($global:debug){Write-Host "  New Text: '$newText'"}
            if($global:debug){Write-Host "  Change: '$($state.LastCommittedText)' -> '$newText'"}

            if ($newText -ne $state.LastCommittedText) {
                $state.HasUncommittedChanges = $true
                $associatedButton.Text = "Commit"
                if($global:debug){Write-Host "  Button text changed to: Commit (text is different from last committed)"}
            } else {
                $state.HasUncommittedChanges = $false
                $buttonText = if ($associatedLabelText -match "show") { "hide" } 
                              elseif ($associatedLabelText -match "hide") { "show" } 
                              else { "Commit" }
                $associatedButton.Text = $buttonText
                if($global:debug){Write-Host "  Button text reverted to: $buttonText (text matches last committed)"}
            }

            if($global:debug){Write-Host "  Has Uncommitted Changes: $($state.HasUncommittedChanges)"}
            if($global:debug){Write-Host "  Current Button Text: $($associatedButton.Text)"}
        })

        $button.Add_Click({
            $clickedButton = $this
            $clickedButtonIndex = $global:buttonIndices[$clickedButton]
            $state = $global:controlStates[$clickedButtonIndex]
            $labelText = $lines[$clickedButtonIndex]
            $global:labelText = $labelText.Split('¦')[0].Trim()

            $control = if ($labelText -match "build|branch") { $global:comboBoxes[$clickedButtonIndex] } else { $global:textBoxes[$clickedButtonIndex] }
            $value = $control.Text

            if ($labelText -match "show|hide" -and $clickedButton.Text -ne "Commit") {
                # Handle show/hide toggle
                $newLabelText = if ($labelText.Split('¦')[0].Trim() -eq "show") { "hide" } else { "show" }
                # Update config.json
                Set-CommandVisibility -Command $value -Visibility $newLabelText
                RefreshConfigLines
                $global:formLabels[$clickedButtonIndex].Text = $newLabelText
                $global:labelText = $newLabelText
                $clickedButton.Text = if ($newLabelText -eq "show") { "hide" } else { "show" }
                $state.LastCommittedText = $value
                $state.HasUncommittedChanges = $false
            }
            elseif ($labelText -match "show|hide" -and $clickedButton.Text -eq "Commit"){
                $newValue = $value.Trim()
                $lastValue = $state.LastCommittedText
                # Update config.json
                Set-CommandValue -Visibility $labelText.Split('¦')[0].Trim() -Value $value.Trim() -LastValue $lastValue
                PerformAction "Saved" $newValue
                RefreshConfigLines
                $global:labelText = $newLabelText
                $clickedButton.Text = if ($newLabelText -eq "show") { "show" } else { "hide" }
                $state.LastCommittedText = $value.Trim()
                $state.HasUncommittedChanges = $false
            }
            elseif ($state.HasUncommittedChanges) {
                # Handle other commits
                $action = DetermineAction $clickedButtonIndex $value $clickedButton.Text
                PerformAction $action $value
                RefreshConfigLines
                $state.LastCommittedText = $value
                $state.HasUncommittedChanges = $false
                $clickedButton.Text = "Commit"
            }
            ListScripts
        })
    }

    CreateFormControls
    RefreshBranchComboBox
    $form.ShowDialog()
}

function DetermineAction($index, $value, $ButtonState) {
    $lineText = $lines[$index]
    $global:cfgValue = $value.Trim()
    $global:cfg = $lineText.Split('¦')[0].Trim()
    
    switch -Regex ($lineText) {
        "show|hide" {
            if ($global:cfgValue -eq "") { return "Error" }
            else { return "ToggleVisibility" }
        }
        "repo" {
            
            if ($global:cfgValue -eq "") { return "Error" }
            else {$global:cfgValue = CleanRepo $global:cfgValue ; return "RepoSet" }
        }
        "branch" {
            if ($global:cfgValue -eq "") { return "Error" }
            else { 
                Set-GitBranch $global:cfgValue
                RefreshBranchComboBox
                return "BuildLlama" }
        }
        "build" {
            if ($global:cfgValue -eq "") { return "Error" }
            else {
                if($value.Trim() -eq "cuda"){
                    try {if (nvcc --version){$BuildTest = $true}
                    } catch {$BuildTest = $false;[System.Windows.Forms.MessageBox]::Show("Nvidia CudaToolkit is required for NVIDIA GPU build.")}
                    }
                if($value.Trim() -eq "vulkan"){
                    try {if (vulkaninfo --help){$BuildTest = $true}
                    } catch {$BuildTest = $false;[System.Windows.Forms.MessageBox]::Show("AMD VulkanSDK is required for AMD GPU build.")}
                    }
                if($value.Trim() -eq "cpu"){
                    $BuildTest = $true
                }
                if ($BuildTest -ne $false){ Set-ConfigValue -Key $global:cfg -Value $value ; return "BuildLlama" } else { "Error" }
            }
        }
        default {
            if ($global:cfgValue -eq "") { return "Error" }
            else { return "DefaultAction" }
        }
    }
}

function PerformAction($action, $value) {
    switch ($action) {
        "ToggleVisibility" { 
            # This is now handled in the button click event
        }
        "Saved" { 
            [System.Windows.Forms.MessageBox]::Show("Committed record $value")
        }
        "Error" { 
            [System.Windows.Forms.MessageBox]::Show("Invalid input or missing requirements.")
        }
        "RepoSet" { 
            Set-GitRepo $global:cfgValue
            RefreshBranchComboBox
            [System.Windows.Forms.MessageBox]::Show("The repo for Llama.Cpp has been changed, you must set the branch to be built.")
        }
        "BuildLlama" { 
            Set-ConfigValue -Key "rebuild" -Value "True"
            [System.Windows.Forms.MessageBox]::Show("Llama.Cpp has been scheduled to be rebuilt.")
            SetButton
        }
        "DefaultAction" { 
            Set-ConfigValue -Key $global:cfg  -Value $value
            [System.Windows.Forms.MessageBox]::Show("Committed record $global:cfg¦$value")
        }
    }
}

function CleanRepo ($text) {
    if ($text -match '([\w-]+/llama\.cpp)(\.git)?$') {
        return $Matches[1] + ".git"
    } else {
        Write-Error "The input string does not end with the required pattern."
        return $null
    }
}

function RefreshBranchComboBox {
    $dev_branchComboBox = $null
    $dev_branchIndex = -1
    $release_branchComboBox = $null
    $release_branchIndex = -1
    
    Set-Location $path\llama.cpp
    $repo = Get-ConfigValue -Key "repo"
    $checkBranch = (git branch --show-current)
    # if checkbranch is null then we are using the tag of a release.
    if($checkBranch -ne $null){$currentBranch = $checkBranch.Trim()}else{$currentBranch = Get-ConfigValue -Key "branch" }
    
    # Find the branch ComboBoxes
    foreach ($index in $global:comboBoxes.Keys) {
        $line = $lines[$index]
        if ($line -match "dev_branch") {
            $dev_branchComboBox = $global:comboBoxes[$index]
            $dev_branchIndex = $index
        }
        if ($line -match "release_branch") {
            $release_branchComboBox = $global:comboBoxes[$index]
            $release_branchIndex = $index
        }
    }

    if ($dev_branchComboBox -ne $null) {
        $dev_branchComboBox.Items.Clear()
        $dev_branches = git branch -a
        foreach ($dev_branch in $dev_branches) {
            $dev_branch = $dev_branch.Trim()
            
            if ($dev_branch -match "HEAD") {
                continue
            }
            $dev_branch = $dev_branch -replace '^\* ', ''
            if ($dev_branch -match "remotes/origin/(.+)") {
                $dev_branch = $matches[1]
            }
            $dev_branchComboBox.Items.Add($dev_branch.Trim())
        }
    }

    if ($release_branchComboBox -ne $null) {
        $release_branchComboBox.Items.Clear()
        $release_branches = git tag -l "b*" | Sort-Object -Descending
        foreach ($release_branch in $release_branches) {
            $release_branchComboBox.Items.Add($release_branch.Trim())
        }
    }

    # Determine if the current branch is a dev branch or a release branch
    $isDevBranch = $dev_branchComboBox.Items -contains $currentBranch
    $isReleaseBranch = $release_branchComboBox.Items -contains $currentBranch

    if ($isDevBranch) {
        $dev_branchComboBox.SelectedItem = $currentBranch
        $release_branchComboBox.Text = ""
    } elseif ($isReleaseBranch) {
        $dev_branchComboBox.Text = ""
        $release_branchComboBox.SelectedItem = $currentBranch
    } else {
        # If the current branch is neither in dev nor release, force latest release.
        $dev_branchComboBox.Text = ""
        $release_branchComboBox.Text = Get-NewRelease
    }

}

function BranchManager {
    $RepoPath = "$path\llama.cpp"

    $BMform = New-Object System.Windows.Forms.Form
    $BMform.Text = "Dev_Branch Manager"
    $BMform.Size = New-Object System.Drawing.Size(535,200)
    $BMform.StartPosition = "CenterScreen"

    $BMpanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $BMpanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $BMpanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
    $BMpanel.WrapContents = $false
    $BMpanel.AutoScroll = $true

    function GitBranches {
        Set-Location $RepoPath
        $branches = git branch --list
        return $branches | Where-Object { $_ -notmatch '(HEAD)' } | ForEach-Object { $_.Trim() }
    }
    
    function BranchPanel {
        $BMpanel.Controls.Clear()
        $branches = GitBranches
        foreach ($branch in $branches) {
            $rowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
            $rowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
            $rowPanel.Width = 519
            $rowPanel.Height = 30
            $rowPanel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 5)

            $updateButton = New-Object System.Windows.Forms.Button
            $updateButton.Text = "Update"
            $updateButton.Width = 100
            $updateButton.Add_Click({
                param($sender, $e)
                $branchToUpdate = $sender.Parent.Controls[1].Text -replace '^\* ', ''
                Set-Location $RepoPath
                $currentBranch = Get-ConfigValue -Key "branch" # get-set the flag for $branch.
                git checkout $branchToUpdate
                $log_name = $branchToUpdate -replace "[-/]","_"
                $gitstatus = Invoke-Expression "git pull"
                Update-Log $gitstatus $log_name
                git checkout $currentBranch
                [System.Windows.Forms.MessageBox]::Show("Branch '$branchToUpdate' updated successfully!", "Update Complete")
                RefreshBranchComboBox
            })
            $rowPanel.Controls.Add($updateButton)

            $BMlabel = New-Object System.Windows.Forms.Label
            $BMlabel.Text = $branch
            $BMlabel.Width = 300
            $BMlabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            $rowPanel.Controls.Add($BMlabel)

            if ($branch -notmatch '^\*' -and $branch -ne 'master') {
                $deleteButton = New-Object System.Windows.Forms.Button
                $deleteButton.Text = "Delete"
                $deleteButton.Width = 100
                $deleteButton.Add_Click({
                    param($sender, $e)
                    $branchToDelete = $sender.Parent.Controls[1].Text
                    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to delete branch '$branchToDelete'?", "Confirm Delete", [System.Windows.Forms.MessageBoxButtons]::YesNo)
                    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                        Set-Location $RepoPath
                        git branch -D $branchToDelete
                        BranchPanel
                    }
                })
                $rowPanel.Controls.Add($deleteButton)
            }

            $BMpanel.Controls.Add($rowPanel)
        }
    }
    $BMform.Controls.Add($BMpanel)

    BranchPanel
    $BMform.ShowDialog()
    
}

Export-ModuleMember -Function * -Variable * -Alias *
