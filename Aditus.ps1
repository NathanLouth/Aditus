#Aditus

$ProgramVersionNumber = "1.0.1"
$ErrorActionPreference = 'SilentlyContinue'

# Import the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

#Make Config Folder
$ConfigPath = "$env:HOMEDRIVE\Aditus"

if(!(Test-Path $ConfigPath)){
    mkdir $ConfigPath
    attrib +h $ConfigPath
    [System.Windows.Forms.MessageBox]::Show("Get Started!`nClick Menu >> Add Server from OU or Add Standalone Server", "Getting Started Aditus", "OK", "Information")
}

Function RefreshServerItemsList(){
    # Get Domain Servers and add to selection list
    $Servers = $null
    foreach($LoopOUs in Get-Content $ConfigPath\OU.Conf){
        if($Servers -eq $null){
            $Servers  = Get-ADComputer -Filter * -SearchBase $LoopOUs
        }else{
            $Servers += Get-ADComputer -Filter * -SearchBase $LoopOUs
        }
    }

    foreach($StandAloneServerTXT in Get-Content $ConfigPath\StandAlone.Conf){

        #Get custom Servers and Webpages and add to selection list
        $StandAloneOBJ = [PSCustomObject]@{
            Name = $StandAloneServerTXT
        }
        if($Servers -eq $null){
            $Servers = @($StandAloneOBJ)
        }else{
            $Servers += $StandAloneOBJ
        }
    }

    $Servers = $Servers | Where-Object {$_.Name} | sort -Unique Name

    $serverListBox.DataSource = $Servers.name
    $serverListBox.DisplayMember = "Name"
}

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Set the form's properties
$form.Text = "Aditus"
$form.Size = New-Object System.Drawing.Size(250,432)
$form.minimumsize = New-Object System.Drawing.Size(250,432)
$form.maximumsize = New-Object System.Drawing.Size(250,432)
$form.ShowIcon = $false
$form.StartPosition = "CenterScreen"

#Create a menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.Controls.Add($menuStrip)

#Create a menu item
$fileMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenuItem.Text = "Menu"
$menuStrip.Items.Add($fileMenuItem)

#Create an Import menu item
$importMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$importMenuItem.Text = "Add Standalone Server"
$fileMenuItem.DropDownItems.Add($importMenuItem)

#Add an event handler to the Import menu item's Click event
$importMenuItem.Add_Click({
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $StandAloneName = $text = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter your standalone PC Name", "Add a standalone PC")
    if($StandAloneName -ne $null){
        $StandAloneName.ToUpper() | Out-File $ConfigPath\StandAlone.Conf  -Append -Force
    }
    RefreshServerItemsList
})

#Create an Import menu item
$ImportOUMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ImportOUMenuItem.Text = "Add Server From OU"
$fileMenuItem.DropDownItems.Add($ImportOUMenuItem)

#Add an event handler to the Import menu item's Click event
$ImportOUMenuItem.Add_Click({

    # Create a new form
    $form = New-Object System.Windows.Forms.Form

    # Set the form's properties
    $form.Text = "Select OUs"
    $form.Size = New-Object System.Drawing.Size(450,300)
    $form.minimumsize = New-Object System.Drawing.Size(450,300)
    $form.maximumsize = New-Object System.Drawing.Size(450,300)
    $form.ShowIcon = $false

    # Create a label to display a message
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Please select the OUs you want to work with `n(NOTE USING SEARCH REMOVE ANY CURRENTLY SELECTED OUS):"
    $label.Location = New-Object System.Drawing.Point(20, 10)
    $label.Size = New-Object System.Drawing.Size(400, 30)
    $form.Controls.Add($label)

    # Create a list box to display the OUs
    $ouListBox = New-Object System.Windows.Forms.ListBox
    $ouListBox.Location = New-Object System.Drawing.Point(20, 50)
    $ouListBox.Size = New-Object System.Drawing.Size(400, 150)
    $ouListBox.Font = New-Object System.Drawing.Font("Lucida Console",14,[System.Drawing.FontStyle]::Regular)
    $ouListBox.SelectionMode = "MultiSimple"
    $form.Controls.Add($ouListBox)

    # Get the OUs and add them to the list box
    $ous = Get-ADOrganizationalUnit -Filter *
    $ouListBox.DataSource = $ous.DistinguishedName
    $ouListBox.DisplayMember = "Name"

    # Create a button to confirm the selection
    $confirmButton = New-Object System.Windows.Forms.Button
    $confirmButton.Text = "Confirm"
    $confirmButton.Location = New-Object System.Drawing.Point(285, 210)
    $confirmButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($confirmButton)

    # Create a search box
    $searchBox = New-Object System.Windows.Forms.TextBox
    $searchBox.Location = New-Object System.Drawing.Point(20,210)
    $searchBox.Size = New-Object System.Drawing.Size(205,20)
    $form.Controls.Add($searchBox)

    # Add an event handler to the search box's TextChanged event
    $searchBox.Add_TextChanged({
        # Get the search text
        $searchText = $searchBox.Text

        # Filter the servers list by the search text
        $filteredous = $ous | Where-Object { $_.name -like "*$searchText*" }

        # Update the list box's data source
        $ouListBox.DataSource = $filteredous.DistinguishedName
        $ouListBox.DisplayMember = "Name"
    })

    # Add an event handler to the button's Click event
    $confirmButton.Add_Click({
        # Get the selected OUs
        $Global:selectedOus = $ouListBox.SelectedItems
        $form.Close()
    })

    # Show the form
    $form.ShowDialog()

    foreach($qweLine in $selectedOus){
       $qweLine | Out-File $ConfigPath\OU.Conf  -Append -Force
    }
    RefreshServerItemsList
})

#Create an Import menu item
$CredentialstMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$CredentialstMenuItem.Text = "Add Credentials"
$fileMenuItem.DropDownItems.Add($CredentialstMenuItem)

#Add an event handler to the Import menu item's Click event
$CredentialstMenuItem.Add_Click({
    
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Computer Credentials"
    $form.Size = New-Object System.Drawing.Size(370,200)
    $form.MinimumSize = New-Object System.Drawing.Size(370,200)
    $form.MaximumSize = New-Object System.Drawing.Size(370,200)
    $form.ShowIcon = $false

    # Create the computer name label
    $computerNameLabel = New-Object System.Windows.Forms.Label
    $computerNameLabel.Text = "Computer Name:"
    $computerNameLabel.Location = New-Object System.Drawing.Size(10,10)
    $computerNameLabel.AutoSize = $true

    # Create the computer name text box
    $Global:computerNameTextBox = New-Object System.Windows.Forms.TextBox
    $computerNameTextBox.Text = $env:COMPUTERNAME
    $computerNameTextBox.Location = New-Object System.Drawing.Size(120,10)
    $computerNameTextBox.size =  New-Object System.Drawing.Size(200,10)

    # Create the username label
    $usernameLabel = New-Object System.Windows.Forms.Label
    $usernameLabel.Text = "Username:"
    $usernameLabel.Location = New-Object System.Drawing.Size(10,40)
    $usernameLabel.AutoSize = $true

    # Create the username text box
    $usernameTextBox = New-Object System.Windows.Forms.TextBox
    $usernameTextBox.Text = $env:USERDOMAIN + "\" + $env:USERNAME
    $usernameTextBox.Location = New-Object System.Drawing.Size(120,40)
    $usernameTextBox.size =  New-Object System.Drawing.Size(200,10)

    # Create the Default username TickBox 
    $defaultTickbox = New-Object System.Windows.Forms.CheckBox
    $defaultTickbox.Text = "Use this as a default for all servers"
    $defaultTickbox.Location = New-Object System.Drawing.Size(15,70)
    $defaultTickbox.Size = New-Object System.Drawing.Size(200,20)

    # Create event for TickBox
    $defaultTickbox.Add_Click({
        if($defaultTickbox.Checked){
            $computerNameTextBox.Text = "ALL SERVERS BY DEFAULT"
            $computerNameTextBox.ReadOnly = $true
        }else{
            $computerNameTextBox.Text = $env:COMPUTERNAME
            $computerNameTextBox.ReadOnly = $false

        }
    })

    # Create the OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Location = New-Object System.Drawing.Size(90,120)

    # Create the Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cancelButton.Location = New-Object System.Drawing.Size(190,120)

    #Add the elements to the form
    $form.Controls.Add($computerNameLabel)
    $form.Controls.Add($computerNameTextBox)
    $form.Controls.Add($usernameLabel)
    $form.Controls.Add($usernameTextBox)
    $form.Controls.Add($defaultTickbox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    #Show the form
    $result = $form.ShowDialog()

    #Check the result of the form
    if($result -eq [System.Windows.Forms.DialogResult]::OK){
        
        if($defaultTickbox.Checked){
            $FULLSERVERLIST = $serverListBox.DataSource
            foreach($FULLSERVER in $FULLSERVERLIST){
                $FULLREGPATH = "HKCU:\Software\Microsoft\Terminal Server Client\Servers\" + $FULLSERVER
                if(!(Test-Path $FULLREGPATH)){
                    New-Item "HKCU:\Software\Microsoft\Terminal Server Client\Servers" -Name $FULLSERVER
                    New-ItemProperty -Path $FULLREGPATH -Name UsernameHint -PropertyType String -Value $usernameTextBox.Text
                }
            }
        }else{
            $FULLREGPATH = "HKCU:\Software\Microsoft\Terminal Server Client\Servers\" + $computerNameTextBox.text
            if(!(Test-Path $FULLREGPATH)){
                New-Item "HKCU:\Software\Microsoft\Terminal Server Client\Servers" -Name $computerNameTextBox.text
                New-ItemProperty -Path $FULLREGPATH -Name UsernameHint -PropertyType String -Value $usernameTextBox.Text
            }else{
                $TEMPCOMPUTERNAMEKEY = $computerNameTextBox.text
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Terminal Server Client\Servers\$TEMPCOMPUTERNAMEKEY" -Name UsernameHint -Value $usernameTextBox.Text -Force
            }
        }

    }

})

#Create an Save Import menu item
$ClearCredMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ClearCredMenuItem.Text = "Clear Credentials"
$fileMenuItem.DropDownItems.Add($ClearCredMenuItem)

#Add an event handler to the Import menu item's Click event
$ClearCredMenuItem.Add_Click({
     $Q2DelConf = [System.Windows.Forms.MessageBox]::Show("Press Yes to delete all stored RDP Credentials","Delete Credentials", "YesNo" , "Information" , "Button1")
     if($Q2DelConf -eq "Yes"){
        Remove-Item -Path "HKCU:\Software\Microsoft\Terminal Server Client\Servers\*" -Recurse
     }
})

#Create an Save Import menu item
$SaveConfigMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$SaveConfigMenuItem.Text = "Save Config"
$fileMenuItem.DropDownItems.Add($SaveConfigMenuItem)

#Add an event handler to the Import menu item's Click event
$SaveConfigMenuItem.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $Savefoldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $Savefoldername.rootfolder = "MyComputer"

    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $SaveFileName = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter a Config Name", "Config Name")

    if($SaveFileName -ne ""){
        if($Savefoldername.ShowDialog() -eq "OK") {
            $FullSavePath = $Savefoldername.SelectedPath + "\" + $SaveFileName
            mkdir $FullSavePath
            Get-ChildItem $ConfigPath | Copy-Item -Destination $FullSavePath -Force
        }  
    }
})

#Create an Load Import menu item
$LoadConfigMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$LoadConfigMenuItem.Text = "Load Config"
$fileMenuItem.DropDownItems.Add($LoadConfigMenuItem)

#Add an event handler to the Import menu item's Click event
$LoadConfigMenuItem.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $Loadfoldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $Loadfoldername.rootfolder = "MyComputer"

    if($Loadfoldername.ShowDialog() -eq "OK") {
        Get-ChildItem $Loadfoldername.SelectedPath | Copy-Item -Destination $ConfigPath -Force
        RefreshServerItemsList
    }  
})

#Create an Save Import menu item
$EditConfigMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$EditConfigMenuItem.Text = "Edit Config"
$fileMenuItem.DropDownItems.Add($EditConfigMenuItem)

#Add an event handler to the Import menu item's Click event
$EditConfigMenuItem.Add_Click({

    & explorer.exe $ConfigPath

})

#Create an Import menu item
$RemoveConfigMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$RemoveConfigMenuItem.Text = "Clear Config"
$fileMenuItem.DropDownItems.Add($RemoveConfigMenuItem)

#Add an event handler to the Import menu item's Click event
$RemoveConfigMenuItem.Add_Click({
    $QDelConf = [System.Windows.Forms.MessageBox]::Show("Press Yes to delete config","Delete config", "YesNo" , "Information" , "Button1")
    if($QDelConf -eq "Yes"){
        Remove-Item $ConfigPath\OU.Conf -Force
        Remove-Item $ConfigPath\Standalone.Conf -Force
    }
    RefreshServerItemsList
})

#Create an About menu item
$aboutMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$aboutMenuItem.Text = "About"
$fileMenuItem.DropDownItems.Add($aboutMenuItem)

#Add an event handler to the About menu item's Click event
$aboutMenuItem.Add_Click({
[System.Windows.Forms.MessageBox]::Show("Aditus Version $ProgramVersionNumber Created by Nathan Louth`nAditus is Licensed under the GPL-2.0 License", "About Aditus", "OK", "Information")
})

# Get Domain Servers and add to selection list
$Servers = $null
foreach($LoopOUs in Get-Content $ConfigPath\OU.Conf){
    if($Servers -eq $null){
        $Servers  = Get-ADComputer -Filter * -SearchBase $LoopOUs
    }else{
        $Servers += Get-ADComputer -Filter * -SearchBase $LoopOUs
    }
}

foreach($StandAloneServerTXT in Get-Content $ConfigPath\StandAlone.Conf){

    #Get custom Servers and Webpages and add to selection list
    $StandAloneOBJ = [PSCustomObject]@{
        Name = $StandAloneServerTXT
    }
    if($Servers -eq $null){
        $Servers = @($StandAloneOBJ)
    }else{
        $Servers += $StandAloneOBJ
    }
}

$Servers = $Servers | Where-Object {$_.Name} | sort -Unique Name

# Create a search box
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(15,360)
$searchBox.Size = New-Object System.Drawing.Size(205,20)
$form.Controls.Add($searchBox)

# Add an event handler to the search box's TextChanged event
$searchBox.Add_TextChanged({
    # Get the search text
    $searchText = $searchBox.Text

    # Filter the servers list by the search text
    $filteredServers = $Servers | Where-Object { $_.name -like "*$searchText*" }

    # Update the list box's data source
    $serverListBox.DataSource = $filteredServers.name
    $serverListBox.DisplayMember = "Name"
})


# Create a list box to display the servers
$serverListBox = New-Object System.Windows.Forms.ListBox
$serverListBox.Location = New-Object System.Drawing.Point(15,30)
$serverListBox.Size = New-Object System.Drawing.Size(205,300)
$serverListBox.Font = New-Object System.Drawing.Font("Lucida Console",14,[System.Drawing.FontStyle]::Regular)
$serverListBox.DataSource = $Servers.name
$serverListBox.DisplayMember = "Name"
$form.Controls.Add($serverListBox)

# Create a button to RDP to the selected server
$rdpButton = New-Object System.Windows.Forms.Button
$rdpButton.Text = "RDP"
$rdpButton.AutoSize = $true
$rdpButton.Location = New-Object System.Drawing.Point(55,330)
$rdpButton.Add_Click({

    $Global:ConnectServer = ($serverListBox.SelectedItem).ToString()

    #Run Remote desktop in admin mode (mainly for Gateway servers)
    & mstsc.exe /V:$ConnectServer /admin

    $form.Close()

})

# Create a button to connect to the selected server
$connectButton = New-Object System.Windows.Forms.Button
$connectButton.Text = "Shadow"
$connectButton.AutoSize = $true
$connectButton.Location = New-Object System.Drawing.Point(135,330)
$connectButton.Add_Click({
    
    $Global:ConnectServer = ($serverListBox.SelectedItem).ToString()

    $UQuery = (query user /server:$ConnectServer) -split "\n" -replace '\s\s+', ';' | convertfrom-csv -Delimiter ';' | where {$_.STATE -eq "Active"}

if ($UQuery){
    $Global:UID = $UQuery[0].id
    
    $connectButton.Text = "View";
    $connectButton.Location = New-Object System.Drawing.Point(135,330);
    $form.Controls.Add($connectButton);

    $rdpbutton.visible = $fasle
    
    $controlButton = New-Object System.Windows.Forms.Button;
    $controlButton.Text = "Control";
    $controlButton.AutoSize = $true;
    $controlButton.Location = New-Object System.Drawing.Point(55,330);
    $form.Controls.Add($controlButton);
    
    $connectButton.Add_Click({
        write-host $ConnectServer
        mstsc /v:$ConnectServer /shadow:$UID
        $form.Close()

    });
    
    $controlButton.Add_Click({
        mstsc /v:$ConnectServer /shadow:$UID /Control
        $form.Close()

    });
} else {
    [System.Windows.Forms.MessageBox]::Show("No RDP Session found")
}


})
$form.Controls.Add($rdpButton)
$form.Controls.Add($connectButton)

# Show the form
$form.ShowDialog()
