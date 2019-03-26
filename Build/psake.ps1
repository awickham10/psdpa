# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
        }

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

Task Default -Depends Test

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Starting DPA VM"

    if (-not $ENV:PSDPA_AZ) {
        Stop-PSFFunction -Message "Environment variable PSDPA_AZ is not set" -EnableException $true
    }

    if (-not $ENV:PSDPA_AZ_APP) {
        Stop-PSFFunction -Message "Environment variable PSDPA_AZ_APP is not set" -EnableException $true
    }

    try {
        $azPassword = ConvertTo-SecureString -String $ENV:PSDPA_AZ -AsPlainText -Force
        $azCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @($ENV:PSDPA_AZ_APP, $azPassword)
        $null = Connect-AzAccount -Tenant $ENV:PSDPA_AZ_TENANT -Credential $azCredential -ServicePrincipal

        $dpaVm = Get-AzVM -ResourceGroupName 'PSDPA' -Name 'dpa' -Status
        $dpaVmStatus = $dpaVm.Statuses | Where-Object { $_.Code -like 'PowerState/*' }

        if ($dpaVmStatus.DisplayStatus -ne 'VM running') {
            "Starting DPA VM"
            $azStart = $dpaVm | Start-AzVM

            "Waiting up to 10 minutes for DPA to start"
            $maxCycles = 60
            $cycles = 0
            do {
                Start-Sleep -Seconds 10
                $cycles++
            } until ((Test-NetConnection '13.67.213.239' -Port 8123 | Where-Object { $_.TcpTestSucceeded }) -or $cycles++ -ge $maxCycles )
        } else {
            "DPA VM is already running"
        }
    } catch {
        Stop-PSFFunction -Message "Could not start Azure DPA VM" -ErrorRecord $_ -EnableException $true
    }
    $lines
    "`n"

    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Testing links on github requires >= tls 1.2
    $SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $CodeFiles = (Get-ChildItem $ENV:BHModulePath -Recurse -Include "*.psm1","*.ps1").FullName

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path "$ProjectRoot\Tests" -CodeCoverage $CodeFiles -PassThru -OutputFormat 'NUnitXml' -OutputFile "$ProjectRoot\$TestFile"
    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )

        Export-CodeCovIoJson -CodeCoverage $TestResults.CodeCoverage -RepoRoot $pwd -Path 'coverage.json'

        $env:PATH = 'C:\msys64\usr\bin;' + $env:PATH
        Invoke-WebRequest -Uri 'https://codecov.io/bash' -OutFile 'codecov.sh'
        bash codecov.sh -f "coverage.json" -t $ENV:CODECOV_TOKEN
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"

    $lines
    "`n`tSTATUS: Stopping DPA VM"

    try {
        $dpaVm | Stop-AzVM -Confirm:$false -Force
    } catch {
        Stop-PSFFunction -Message "Could not stop Azure DPA VM" -ErrorRecord $_ -EnableException $true
    }
}

Task Build -Depends Test {
    $lines

    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions

    # Bump the module version if we didn't already
    try {
        [version]$GalleryVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName -ErrorAction Stop
        [version]$GithubVersion = Get-MetaData -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -ErrorAction Stop
        if($GalleryVersion -ge $GithubVersion) {
            Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $GalleryVersion -ErrorAction stop
        }
    } catch {
        "Failed to update version for '$env:BHProjectName': $_.`nContinuing with existing version"
    }
}

Task Deploy -Depends Build {
    $lines

    $Params = @{
        Path = "$ProjectRoot\Build"
        Force = $true
    }
    Invoke-PSDeploy @Verbose @Params
}