$classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )
$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$filesToLoad = @([object[]]$classes + [object[]]$private + [object[]]$public)
$moduleRoot = $PSScriptRoot

$developerMode = Get-PSFConfigValue -FullName 'psdpa.developer'
if ($developerMode) {
    Write-PSFMessage -Level Verbose -Message 'Developer mode enabled'
}

# Dot source the files
# Thanks to Bartek, Constatine
# https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
foreach ($file in $filesToLoad) {
    Write-PSFMessage -Level Verbose -Message "Importing [$file]"
    try {
        if ($developerMode) {
            . $file.FullName
        }
        else {
            $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($file.FullName))), $null, $null)
        }
    }
    catch {
        Write-PSFMessage -Level Critical -Message "Failed to import function $($file.FullName)" -ErrorRecord $_
    }
}

#Export-ModuleMember -Function $public.BaseName