# VMware vSphere Snapshot Cleanup Script

This script is to help vSphere administrators cleanup aged snapshots that may have been forgotten.

## Use case

- You have a company IT policy to keep no snapshots more then 14 days, and forcifly delete snapshots that are 30+ days old.  You can run this script with the default 30 days and it will connect to vCenter and find all snapshots 30 days or older, remove them, and then send a report of the snapshots it removed to a designated email address.
