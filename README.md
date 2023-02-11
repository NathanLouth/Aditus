# Aditus - The Gateway To Your Internal Servers
### Aditus provides a simple interface to RDP or Shadow any Windows server on your network

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusAdvancedView.png)

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusMain.png)
![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusMenu.png)

## Overview
- [Installation](https://github.com/NathanLouth/Aditus#installation)
- [Issues](https://github.com/NathanLouth/Aditus#issues)
- [Feature Request](https://github.com/NathanLouth/Aditus#feature-request)
- [Features](https://github.com/NathanLouth/Aditus#features)
- [Getting Started](https://github.com/NathanLouth/Aditus/blob/main/README.md#getting-started)

## Installation

Aditus is a Powershell script that has been compiled to an Portable Executable for convenience.

You can use either of the two options:

Download the latest Executable (x64)
[Download](https://github.com/NathanLouth/Aditus/releases)

Download the latest Script
[Download](https://github.com/NathanLouth/Aditus/releases)

## Issues

Please let me know if you encounter any bugs or issues, you can do this through the Issues tab on GitHub.

#### Known Issues

- If only one server is in the list it won't show - working on a fix

## Feature Request

Please let me know any feature you think would be beneficial to add, you can do this through the Issues tab on GitHub.

## Features

- Import Servers from Active Directory OUs (Requires PC being Domain Joined)
- Import Standalone servers using DNS Name
- Save Aditus Config (Doesnt Currently Save Server Usernames)
- Load Aditus Config (Doesnt Currently Load Server Usernames)
- Search Box to easily find servers and OUs
- Add Default Username used for RDP to allow easy login
- Add Server Specific Usernames used for RDP to allow easy login
- Start RDP Session to Server (Calls mstsc.exe)
- Start Shadow Session to view a live RDP Session on a Server (Calls mstsc.exe)
- Choose between control or view modes when shadowing
- Choose the option to keep program running or to close once starting RDP or Shadow Session
- Option to use computer name for domain when adding credentials to make bulk adding easier
- Advanced View:
  * View computer's IP Address
  * View computer's storage/drive space
  * View computer's shares

## Getting Started

### Adding Servers

Under "Menu" There are two options to add server:

1.Add Standalone Server

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusStandalonePC.png)

Adding a Standalone server is done by entering the servers DNS name like "FileServer001"

2.Add Server from OU

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusOU.png)

Adding servers from OUs allows Aditus dynamicaly add and remove servers from its interface when servers are added or are deleted within AD.

You can select multiple OUs or search to make finding OUs easier.

### Adding Credentials

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusAddCred.png)

Aditus allows you to save usernames when starting a remote desktop connection.

You can set a default username or select individual usernames for servers.

*Usernames are stored in the current users registry in the following key:*

*HKCU:\Software\Microsoft\Terminal Server Client\Servers*

*mstsc.exe checks this location to see if a "UsernameHint" is set for a given server*

### Removing Credentials

Aditus allows you to clear any saved rdp credentials this removes all keys in:

*HKCU:\Software\Microsoft\Terminal Server Client\Servers*

*mstsc.exe checks this location to see if a "UsernameHint" is set for a given server*

### Saving your config

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusConfigName.png)
![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusSelectFolderSave.png)

Aditus auto saves your config to a folder called Aditus in your HomeDrive or to Aditus in the C drive on a non domain joined computer (this folder is hidden by default).

Saving your config allows you to load it on differnet computers in create a backup of the config.

The saved config is a folder containing differnet .conf files

### Loading your config

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusLoadConfig.png)

You can load Aditus configs using this option

### Manualy editing your config

![image](https://github.com/NathanLouth/Aditus/blob/main/Images/AditusConfigFiles.png)

Aditus saves settings in .conf files these are human readable and you can edit these yourself

### Clear your config

Use this option when you want to start a fresh or start making a new config to save.

*This won't delete stored RDP Credentials*
