# SCCM Software Update "Kick-Start" Script

Script for those that need a bit more control of their automated SCCM pathcing.
Use case:
    - You already have SCCM Maintence Windows setup for system patching
    - You want the patches to install only a few hours before the maintence window.
        -Script is currently setup to start patch install 4 hours before the start of the next scheduled maintence window.
