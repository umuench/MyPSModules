function Update-ExplorerIconCache {
    <#
    .SYNOPSIS
        Aktualisiert den Windows Explorer Icon-Cache.
    .DESCRIPTION
        Ruft ie4uinit.exe auf und sendet eine SHChangeNotify-Nachricht,
        damit Windows Explorer neu erstellte Ordner-Icons sofort anzeigt.
        Gibt $true zurueck, wenn die Aktualisierung erfolgreich war.
    .EXAMPLE
        Update-ExplorerIconCache
    #>
    [CmdletBinding()]
    param()

    try {
        $ie4uinit = "$env:SystemRoot\System32\ie4uinit.exe"
        if (Test-Path $ie4uinit) {
            Start-Process -FilePath $ie4uinit -ArgumentList '-show' -Wait -NoNewWindow -ErrorAction SilentlyContinue
        }

        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class ShellNotify {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
    public const int  SHCNE_ASSOCCHANGED = 0x08000000;
    public const uint SHCNF_IDLIST       = 0x0000;
    public static void RefreshIcons() {
        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, IntPtr.Zero, IntPtr.Zero);
    }
}
'@ -ErrorAction SilentlyContinue

        [ShellNotify]::RefreshIcons()
        return $true
    }
    catch {
        Write-Verbose "Icon-Cache-Aktualisierung fehlgeschlagen: $_"
        return $false
    }
}
