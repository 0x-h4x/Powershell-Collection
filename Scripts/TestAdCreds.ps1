$creds = Get-Credential

Function Test-ADCreds {
    param (
        [string]$username,
        [string]$password
    )

    try {
        # Get the default naming context from RootDSE
        $root = New-Object DirectoryServices.DirectoryEntry("LDAP://RootDSE")
        $defaultNamingContext = $root.Properties["defaultNamingContext"][0]
        $ldapPath = "LDAP://$defaultNamingContext"

        # Attempt to bind with provided credentials
        $entry = New-Object DirectoryServices.DirectoryEntry($ldapPath, $username, $password)

        # Search for the user object in AD
        $searcher = New-Object System.DirectoryServices.DirectorySearcher($entry)
        $searcher.Filter = "(samAccountName=$username)"
        $searcher.PageSize = 1
        $result = $searcher.FindOne()

        if ($result -ne $null) {
            Write-Host "`n✅ Authentication succeeded for user '$username'" -ForegroundColor Green
        }
        else {
            Write-Host "`n❌ Authentication failed for user '$username'" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "`n❌ Authentication failed for user '$username'" -ForegroundColor Red
    }
}

Test-ADCreds -username $creds.UserName -password $creds.GetNetworkCredential().Password
