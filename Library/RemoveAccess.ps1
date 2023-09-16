#Delete users
function RemoveAccess {
    mitre_details("RemoveAccess")

    Write-Warning "Results of this action cannot be reversed!!!"

    EnterAccount("Enter an account to remove from Azure AD")
    $target_account = $global:account_username

    if ($target_account -eq $global:AdminUsername){
        Write-Host "`nSorry, you are too great to destroy yourself!" -ForegroundColor Red
        Write-Host "Tip: Try deleting another account or create a backdoor account then use it to delete this account (MAAD can help you with that)" -ForegroundColor Gray
        break
    }

    #Delete account
    try {
        Write-Host "`nDeleting the selected account ..."
        Remove-AzureADUser -ObjectId $target_account -ErrorAction Stop
        Start-Sleep -s 5 
        Write-Host "`n[Success] Account: $target_account deleted!" -ForegroundColor Yellow
    }
    catch {
        Write-Host "`n[Error] Failed to delete account $target_account" -ForegroundColor Red
    }
    
}
    