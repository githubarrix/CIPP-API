function Remove-CIPPMailboxRule {
    [CmdletBinding()]
    param (
        $UserId,
        $Username,
        $TenantFilter,
        $APIName = 'Mailbox Rules Removal',
        $Headers,
        $RuleId,
        $RuleName,
        [switch]$RemoveAllRules
    )

    if ($RemoveAllRules.IsPresent -eq $true) {
        # Delete all rules
        try {
            Write-Host "Checking rules for $Username"
            $Rules = New-ExoRequest -tenantid $TenantFilter -cmdlet 'Get-InboxRule' -cmdParams @{Mailbox = $Username; IncludeHidden = $true } | Where-Object { $_.Name -ne 'Junk E-Mail Rule' -and $_.Name -notlike 'Microsoft.Exchange.OOF.*' }
            Write-Host "$($Rules.count) rules found"
            if ($null -eq $Rules) {
                Write-LogMessage -headers $Headers -API $APIName -message "No Rules for $($Username) to delete" -Sev 'Info' -tenant $TenantFilter
                return "No rules for $($Username) to delete"
            } else {
                ForEach ($rule in $Rules) {
                    $null = New-ExoRequest -tenantid $TenantFilter -cmdlet 'Remove-InboxRule' -Anchor $Username -cmdParams @{Identity = $rule.Identity }
                }
                Write-LogMessage -headers $Headers -API $APIName -message "Deleted rules for $($Username)" -Sev 'Info' -tenant $TenantFilter
                return "Deleted rules for $($Username)"
            }
        } catch {
            $ErrorMessage = Get-CippException -Exception $_
            Write-LogMessage -headers $Headers -API $APIName -message "Could not delete rules for $($Username): $($ErrorMessage.NormalizedError)" -Sev 'Error' -tenant $TenantFilter -LogData $ErrorMessage
            return "Could not delete rules for $($Username). Error: $($ErrorMessage.NormalizedError)"
        }
    } else {
        # Only delete 1 rule
        try {
            $null = New-ExoRequest -tenantid $TenantFilter -cmdlet 'Remove-InboxRule' -Anchor $Username -cmdParams @{Identity = $RuleId }
            Write-LogMessage -headers $Headers -API $APIName -message "Deleted mailbox rule $($RuleName) for $($Username)" -Sev 'Info' -tenant $TenantFilter
            return "Deleted mailbox rule $($RuleName) for $($Username)"
        } catch {
            $ErrorMessage = Get-CippException -Exception $_
            Write-LogMessage -headers $Headers -API $APIName -message "Could not delete rule for $($Username): $($ErrorMessage.NormalizedError)" -Sev 'Error' -tenant $TenantFilter -LogData $ErrorMessage
            return "Could not delete rule for $($Username). Error: $($ErrorMessage.NormalizedError)"
        }
    }
}
