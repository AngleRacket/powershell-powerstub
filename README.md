# PowerStub

## Summary

    Stub script to allow better organization of related commands and supporting files.

    Example: You have a product named AppleSauce, and you have scripts for Build, Deploy, Update, Configure, PatchDatabase, Clean, UpdatePackages, and so on...

    Solution:
    1. Use PowerStub to create a "ACmd.ps1" stub that exposes each of the sub commands.
    2. Put this in your path somewhere (along with the supporting folder).
    3. Move all you existing commands to the stub's /commands folder
    4. Execute your commands:
        PS C:\> acmd build param1 param2

## Details

    PowerStub was born out of frustration dealing with a PowerShell global scripts folder that had become unmanageable.

    Sure, in the beginning we all have the best intentions. We create a dothis.ps1 and a dothat.ps1, and we mean to come back and document it - but we never do. Instead, we come back and add an include to another function needed to dothis or dothat.

    In the meantime, we are testing a dothis2.ps1 that lives in the same folder. Careful, run the wrong version of your command at the wrong time and you could be looking at a really long workday.

## Features

- Commands are organized into a sub folder
  - /Commands/MyCommand.ps1 OR
  - /Commands/MyCommand/MyCommand.ps1 (allows for commands with multiple files to be isolated into a single separate folder)
- Commands are completely independent and may be called without stub
- Stub supports listing sub-commands
- Stub supports retrieving sub-command help information
- Stub command script can be altered to add behavior like setting env vars, or clearing redis before each command
- Support for pre-release commands that can be manually enabled
