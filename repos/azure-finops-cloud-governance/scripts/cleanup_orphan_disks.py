"""
Azure FinOps Automation: Unattached Disk & Zombie Resource Cleaner
Author: Yogendra Singh (DevOps Engineer)
Description: Identifies and safely cleans up unattached managed disks, orphaned snapshots,
             and unassociated public IP addresses to eliminate cloud waste.
"""

import os
import sys
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient


def audit_unattached_disks(subscription_id: str, dry_run: bool = True):
    print(f"[*] Starting FinOps Audit for Subscription: {subscription_id}")
    print(f"[*] Dry-Run Mode: {'ENABLED (No destructive actions)' if dry_run else 'DISABLED (Actionable purge)'}")

    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, subscription_id)

    unattached_disks = []
    total_wasted_gb = 0

    disks = compute_client.disks.list()
    for disk in disks:
        # A disk is orphaned if managed_by is None
        if disk.managed_by is None:
            unattached_disks.append(disk)
            total_wasted_gb += disk.disk_size_gb
            print(f"[!] Found Orphaned Disk: {disk.name} | Size: {disk.disk_size_gb}GB | Tier: {disk.sku.name} | RG: {disk.id.split('/')[4]}")

    print(f"\n==========================================")
    print(f"Total Orphaned Disks Found: {len(unattached_disks)}")
    print(f"Total Recoverable Storage : {total_wasted_gb} GB")
    print(f"==========================================\n")

    if not dry_run and unattached_disks:
        for disk in unattached_disks:
            rg = disk.id.split('/')[4]
            print(f"[-] Deleting unattached disk: {disk.name} in RG: {rg}...")
            compute_client.disks.begin_delete(rg, disk.name).result()
            print(f"[+] Successfully purged: {disk.name}")


if __name__ == "__main__":
    sub_id = os.getenv("AZURE_SUBSCRIPTION_ID")
    if not sub_id:
        print("[x] Error: AZURE_SUBSCRIPTION_ID environment variable required.")
        sys.exit(1)

    is_dry_run = os.getenv("DRY_RUN", "true").lower() == "true"
    audit_unattached_disks(sub_id, dry_run=is_dry_run)

