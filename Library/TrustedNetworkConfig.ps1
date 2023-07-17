function TrustedNetworkConfig {
    mitre_details("TrustedNetworkConfig")

    #Get public IP
    $trusted_policy_name = Read-Host -Prompt "Provide a name to create the trusted network policy"

    $ip_addr = Read-Host -Prompt "Enter IP address to add as trusted named location (or leave blank and hit 'enter' for tool to automatically resolve and use your public IP)"

    if ($ip_addr -eq "") {
        Write-Host "`nResolving your public IP..."
        Write-Host "    Querying DNS..."
        $ip_addr = $(Resolve-DnsName -Name myip.opendns.com -Server 208.67.222.220).IPAddress
        Write-Host "`nYour public IP: $ip_addr`n"
        Pause

        if ($ip_addr -eq "") {
            Write-Host "`nFailed to resolve IP automatically." -ForegroundColor Gray
            $ip_addr = Read-Host -Prompt "Manually enter IP address to add as trusted named location"
        }
    }
    
    #Create trusted network policy
    try {
        Write-Host "Creating policy $trusted_policy_name to add your IP as trusted named location...`n"
        $trusted_nw = New-AzureADMSNamedLocationPolicy -OdataType "#microsoft.graph.ipNamedLocation" -DisplayName $trusted_policy_name -IsTrusted $true -IpRanges "$ip_addr/32" -ErrorAction Stop
        Write-Host "Displaying details of deployed policy ..." -ForegroundColor Gray
        $trusted_nw | Out-Host
        Write-Host "Successfully created trusted location policy $trusted_policy_name with IP $ip_addr !!!" -ForegroundColor Yellow -BackgroundColor Black
        $allow_undo = $true
    }
    catch {
        Write-Host "Error: Failed to create trusted location policy!"
    }
    
    #Undo changes
    if ($allow_undo -eq $true) {
        Write-Host "`n"
        $user_confirm = Read-Host -Prompt 'Would you like to undo changes by deleting the new trusted location policy? (yes/no)'

        if ($user_confirm -notin "No","no","N","n") {
            try {
                Write-Host "Removing trusted location policy: $trusted_policy_name ...`n"
                Remove-AzureADMSNamedLocationPolicy -PolicyId $trusted_nw.Id
                Write-Host "Undo successful: Removed the trusted location policy!!!" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to remove the trusted location policy!!!" -ForegroundColor Red
            }
            
        }
    }
    Pause
}