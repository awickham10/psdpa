$Classes = @( Get-ChildItem -Path "$PSScriptRoot\Classes\*.ps1" -Recurse )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse )
$Public = @( Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Recurse )

@($Classes + $Private + $Public) | ForEach-Object {
    Try {
        . $_.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($_.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
