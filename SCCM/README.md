# SCCM Software Update "Kick-Start" Script

Script for those that need a bit more control of their automated SCCM pathcing.

## Use case

- You already have SCCM Maintence Windows setup for system patching
- You want the patches to install only a few hours before the maintence window.
    -Script is currently setup to start patch install 4 hours before the start of the next scheduled maintence window.

## What it does

This kickstart script runs agasint the local system (Typically steup as a repeating scheduled task) and checks the local WMI namespace for SCCM Maintence window information.
If a maintence window is found within  X hours of the check (default is 4) it then make another WMI call to start the install process of any pending patches. 
This allows your computer to be ready for reboot once the maintence window time comes, speeding things up a bit.