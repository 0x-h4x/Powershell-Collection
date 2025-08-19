$creds = Get-Credential

Function Test-ADCreds {
    param (
        [string]$username,
        [string]$password
    )

    try {
        # Bind to the domain with provided credentials
        $root = New-Object DirectoryServices.DirectoryEntry("LDAP://RootDSE")
        $defaultNamingContext = $root.Properties["defaultNamingContext"][0]
        $ldapPath = "LDAP://$defaultNamingContext"

        $entry = New-Object DirectoryServices.DirectoryEntry($ldapPath, $username, $password)

        # Use DirectorySearcher to validate the user exists
        $searcher = New-Object System.DirectoryServices.DirectorySearcher($entry)
        $searcher.Filter = "(samAccountName=$username)"
        $searcher.PageSize = 1
        $result = $searcher.FindOne()

        if ($result -ne $null) {
            Write-Host "`n✅ Authentication succeeded for user '$username'" -ForegroundColor Green
        }
        else {
            Write-Host "`n❌ Authentication failed: user '$username' not found in directory." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "`n❌ Authentication failed for user '$username'" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

Test-ADCreds -username $creds.UserName -password $creds.GetNetworkCredential().Password
