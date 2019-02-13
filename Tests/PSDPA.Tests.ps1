. $PSScriptRoot\Shared.ps1
$Path = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($ENV:BHProjectPath) {
    $ModulePath = Join-Path $ENV:BHProjectPath $ModuleName
} else {
    $ModulePath = (Get-Item $Path).Parent.FullName + '\' + $ModuleName
}
Write-Host "ModulePath: $ModulePath"

function Split-ArrayInParts($array, [int]$parts) {
    #splits an array in "equal" parts
    $size = $array.Length / $parts
    $counter = [pscustomobject] @{ Value = 0 }
    $groups = $array | Group-Object -Property { [math]::Floor($counter.Value++ / $size) }
    $rtn = @()
    foreach ($g in $groups) {
        $rtn += , @($g.Group)
    }
    $rtn
}

Describe "$ModuleName style" -Tag 'Compliance' {
    <#
    Ensures common formatting standards are applied:
    - OTSB style, courtesy of PSSA's Invoke-Formatter, is what dbatools uses
    - UTF8 without BOM is what is going to be used in PS Core, so we adopt this standard for dbatools
       #>
    $AllFiles = Get-ChildItem -Path $ModulePath -File -Recurse -Filter '*.ps*1'
    $AllFunctionFiles = Get-ChildItem -Path "$ModulePath\Public", "$ModulePath\Private", "$ModulePath\Classes" -Filter '*.ps*1'
    Context "formatting" {
        $maxConcurrentJobs = $env:NUMBER_OF_PROCESSORS
        $whatever = Split-ArrayInParts -array $AllFunctionFiles -parts $maxConcurrentJobs
        $jobs = @()
        foreach ($piece in $whatever) {
            $jobs += Start-Job -ScriptBlock {
                foreach ($p in $Args) {
                    $content = Get-Content -Path $p.FullName -Raw -Encoding UTF8
                    $result = Invoke-Formatter -ScriptDefinition $content -Settings CodeFormattingOTBS
                    if ($result -ne $content) {
                        $p
                    }
                }
            } -ArgumentList $piece
        }
        $null = $jobs | Wait-Job #-Timeout 120
        $results = $jobs | Receive-Job

        foreach ($f in $results) {
            It "$f is adopting OTSB formatting style. Please run Invoke-DbatoolsFormatter against the failing file and commit the changes." {
                1 | Should -Be 0
            }
        }
    }

    Context "BOM" {
        foreach ($f in $AllFiles) {
            [byte[]]$byteContent = Get-Content -Path $f.FullName -Encoding Byte -ReadCount 4 -TotalCount 4
            if ( $byteContent[0] -eq 0xef -and $byteContent[1] -eq 0xbb -and $byteContent[2] -eq 0xbf ) {
                It "$f has no BOM in it" {
                    "utf8bom" | Should -Be "utf8"
                }
            }
        }
    }

    Context "indentation" {
        foreach ($f in $AllFiles) {
            $LeadingTabs = Select-String -Path $f -Pattern '^[\t]+'
            if ($LeadingTabs.Count -gt 0) {
                It "$f is not indented with tabs (line(s) $($LeadingTabs.LineNumber -join ','))" {
                    $LeadingTabs.Count | Should -Be 0
                }
            }
            $TrailingSpaces = Select-String -Path $f -Pattern '([^ \t\r\n])[ \t]+$'
            if ($TrailingSpaces.Count -gt 0) {
                It "$f has no trailing spaces (line(s) $($TrailingSpaces.LineNumber -join ','))" {
                    $TrailingSpaces.Count | Should -Be 0
                }
            }
        }
    }
}

Describe "$ModuleName style" -Tag 'Compliance' {
    <#
    Ensures avoiding already discovered pitfalls
    #>
    $AllPublicFunctions = Get-ChildItem -Path "$ModulePath\Public" -Filter '*.ps*1'

    Context "NoCompatibleTLS" {
        # .NET defaults clash with recent TLS hardening (e.g. no TLS 1.2 by default)
        foreach ($f in $AllPublicFunctions) {
            $NotAllowed = Select-String -Path $f -Pattern 'Invoke-WebRequest | New-Object System.Net.WebClient|\.DownloadFile'
            if ($NotAllowed.Count -gt 0) {
                It "$f should instead use Invoke-TlsWebRequest, see #4250" {
                    $NotAllowed.Count | Should -Be 0
                }
            }
        }
    }

}


Describe "$ModuleName ScriptAnalyzerErrors" -Tag 'Compliance' {
    $ScriptAnalyzerErrors = @()
    $ScriptAnalyzerErrors += Invoke-ScriptAnalyzer -Path "$ModulePath\Public" -Severity Error
    $ScriptAnalyzerErrors += Invoke-ScriptAnalyzer -Path "$ModulePath\Private" -Severity Error
    Context "Errors" {
        if ($ScriptAnalyzerErrors.Count -gt 0) {
            foreach ($err in $ScriptAnalyzerErrors) {
                It "$($err.scriptName) has Error(s) : $($err.RuleName)" {
                    $err.Message | Should -Be $null
                }
            }
        }
    }
}

Describe "$ModuleName Tests missing" -Tag 'Tests' {
    $functions = Get-ChildItem (Join-Path -Path $ModulePath -ChildPath 'Public') -Recurse -Include *.ps1
    Context "Every function should have tests" {
        foreach ($f in $functions) {
            It "$($f.basename) has a tests.ps1 file" {
                Test-Path "Tests\$($f.basename).Tests.ps1" | Should Be $true
            }
            <#
            If (Test-Path "Tests\$($f.basename).Tests.ps1") {
                It "$($f.basename) has validate parameters unit test" {
                    "Tests\$($f.basename).Tests.ps1" | should FileContentMatch 'Context "Validate parameters"'
                }
            }
            #>
        }
    }
}