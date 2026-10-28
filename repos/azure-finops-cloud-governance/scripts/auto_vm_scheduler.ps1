<#
.SYNOPSIS
    Azure FinOps Non-Production Compute Auto-Scheduler
.DESCRIPTION
    PowerShell script/Azure Automation Runbook that automatically stops or starts
    virtual machines tagged with AutoSchedule=True.
    Delivers up to 60% compute cost savings for Dev and UAT environments.
.AUTHOR
    Yogendra Singh (DevOps Engineer)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action,

    [string]$TagKey = "AutoSchedule",
    [string]$TagValue = "True"
)

Write-Output "[*] Executing FinOps Compute Scheduler: Action = $Action"

# Authenticate via Azure Automation Managed Identity
try {
    Connect-AzAccount -Identity | Out-Null
    Write-Output "[+] Successfully connected using Managed Identity."
} catch {
    Write-Error "Failed to connect via Managed Identity: $_"
    exit 1
}

# Fetch all VMs matching the FinOps tag
$targetVMs = Get-AzVM -Status | Where-Object {
    $_.Tags[$TagKey] -eq $TagValue
}

Write-Output "[*] Total VMs found matching tag [$TagKey=$TagValue]: $($targetVMs.Count)"

foreach ($vm in $targetVMs) {
    $vmName = $vm.Name
    $rg = $vm.ResourceGroupName
    $status = ($vm.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus

    Write-Output "[>] VM: $vmName | ResourceGroup: $rg | Current Status: $status"

    if ($Action -eq "Stop" -and $status -eq "VM running") {
        Write-Output "[-] Stopping & Deallocating: $vmName..."
        Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force -NoWait | Out-Null
        Write-Output "[+] Deallocation initiated for $vmName."
    } elseif ($Action -eq "Start" -and $status -ne "VM running") {
        Write-Output "[+] Starting: $vmName..."
        Start-AzVM -ResourceGroupName $rg -Name $vmName -NoWait | Out-Null
        Write-Output "[+] Start command initiated for $vmName."
    } else {
        Write-Output "[=] No action required for $vmName (Already in target state)."
    }
}

Write-Output "[*] FinOps Scheduler execution completed."

