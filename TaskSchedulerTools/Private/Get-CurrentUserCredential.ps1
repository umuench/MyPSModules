function Get-CurrentUserCredential {
    <#
    .SYNOPSIS
        Erstellt ein PSCredential-Objekt fuer den aktuell angemeldeten Benutzer.
    .DESCRIPTION
        Liest den aktuellen Benutzernamen aus WindowsIdentity und kombiniert ihn mit
        einem leeren Passwort. Wird von Import-TaskBranch als Fallback-Credential
        verwendet, wenn kein explizites Credential angegeben wird.
    .EXAMPLE
        $cred = Get-CurrentUserCredential
        Write-Host $cred.UserName
    #>

    $user          = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $emptyPassword = New-Object System.Security.SecureString

    return New-Object System.Management.Automation.PSCredential($user, $emptyPassword)
}
