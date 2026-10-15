# Builds Wisetalk for Windows (x64) and adds it to the tag's release on
# Forgejo, next to what the other release scripts sent: the installer, and
# Velopack's update package and feed (the release before supplies a delta).
#
# Usage, in PowerShell from the repository:
#   .\scripts\release-windows.ps1 vX.Y.Z
# Needs the tag checked out and pushed, and a Forgejo token that can write
# releases in $env:WISETALK_FORGEJO_TOKEN or in
# %APPDATA%\wisetalk\forgejo-token. The tools it needs, and how to get
# them, it says itself.
#
# The installer isn't signed: Windows SmartScreen warns about it the first
# time ("More info", then "Run anyway").
#
# ASCII only: Windows PowerShell 5.1 reads a script without a byte order
# mark in the ANSI code page.

param([Parameter(Mandatory = $true)][string]$Tag)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

function Fail([string]$Message) {
    Write-Host "release: $Message" -ForegroundColor Red
    exit 1
}

# Runs a program, its error output mixed into what it prints. Windows
# PowerShell 5.1 takes any line a program writes to stderr ("Building
# flutter tool...") for a failure while errors stop the script; the exit
# code ($LASTEXITCODE) says whether it failed.
function Run([scriptblock]$Block) {
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        (& $Block 2>&1 | ForEach-Object { "$_" }) -join "`n"
    } finally {
        $ErrorActionPreference = $saved
    }
}

if ($Tag -notmatch '^v\d') { Fail 'usage: .\scripts\release-windows.ps1 vX.Y.Z' }
$version = $Tag.Substring(1)
$base = ($version -split '-')[0]
$repo = 'https://git.wiseless.net/Wisetalk/client'
$api = 'https://git.wiseless.net/api/v1/repos/Wisetalk/client'
$dockerfile = Get-Content ci\Dockerfile
$flutterVersion = ($dockerfile | Select-String '^ARG FLUTTER_VERSION=(.+)$').Matches[0].Groups[1].Value
$vpkVersion = ($dockerfile | Select-String '^ARG VPK_VERSION=(.+)$').Matches[0].Groups[1].Value

# --- What it needs ---------------------------------------------------------

$missing = @()
function Need([string]$Command, [string]$Hint) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        $script:missing += "  ${Command}: $Hint"
    }
}
Need git 'https://git-scm.com/download/win'
Need flutter "Flutter $flutterVersion, https://docs.flutter.dev/install/archive"
Need rustup 'https://rustup.rs (the default MSVC toolchain)'
Need dotnet 'winget install Microsoft.DotNet.SDK.8'
Need vpk "dotnet tool install -g vpk --version $vpkVersion"
Need curl.exe 'comes with Windows 10 and later'
if ($missing.Count -gt 0) { Fail ("missing tools:`n" + ($missing -join "`n")) }

$flutterSays = Run { flutter --version }
if ($flutterSays -notmatch "Flutter $([regex]::Escape($flutterVersion)) ") {
    Fail "Flutter $flutterVersion needed (flutter --version says otherwise)"
}

# The tag's app, built by release scripts that may be newer than it.
$null = Run { git rev-parse -q --verify "$Tag^{commit}" }
if ($LASTEXITCODE -ne 0) { Fail "no tag $Tag here: git fetch --tags" }
$null = Run { git diff --quiet $Tag HEAD -- . ':!scripts' }
if ($LASTEXITCODE -ne 0) { Fail "check out $Tag first (git checkout $Tag)" }
$null = Run { git diff --quiet }
$dirty = $LASTEXITCODE
$null = Run { git diff --cached --quiet }
if ($dirty -ne 0 -or $LASTEXITCODE -ne 0) { Fail 'commit or stash your changes first' }
$null = Run { git ls-remote --exit-code --tags origin $Tag }
if ($LASTEXITCODE -ne 0) { Fail "push $Tag first" }

$token = $env:WISETALK_FORGEJO_TOKEN
$tokenFile = Join-Path $env:APPDATA 'wisetalk\forgejo-token'
if (-not $token -and (Test-Path $tokenFile)) { $token = (Get-Content $tokenFile -Raw).Trim() }
if (-not $token) { Fail "put a Forgejo token in $tokenFile or in `$env:WISETALK_FORGEJO_TOKEN" }

# vpk is built for .NET 8; a newer runtime runs it too.
$env:DOTNET_ROLL_FORWARD = 'Major'

# --- How the steps look ----------------------------------------------------
# One line per step with a running clock and how long it took last time;
# what it prints goes to dist\logs and only shows when it fails.

$steps = 4
$step = 0
$timesFile = Join-Path $env:LOCALAPPDATA 'wisetalk\release-times-windows'
New-Item -ItemType Directory -Force (Split-Path $timesFile) | Out-Null
$times = @{}
if (Test-Path $timesFile) {
    foreach ($line in Get-Content $timesFile) {
        $name, $seconds = $line -split ' '
        $times[$name] = [int]$seconds
    }
}
$started = [Diagnostics.Stopwatch]::StartNew()

function Clock([int]$Seconds) { '{0}:{1:00}' -f [math]::Floor($Seconds / 60), ($Seconds % 60) }

function Step([string]$Name, [string]$Title, [string]$Command) {
    $script:step++
    $log = "dist\logs\$Name.log"
    $hint = ''
    if ($times.ContainsKey($Name)) { $hint = " of ~$(Clock $times[$Name])" }
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $process = Start-Process cmd.exe -ArgumentList '/d', '/s', '/c', "`"$Command > $log 2>&1`"" `
        -NoNewWindow -PassThru
    $null = $process.Handle # or ExitCode stays empty
    $frames = '|/-\'
    $i = 0
    while (-not $process.HasExited) {
        $line = "{0} [{1}/{2}] {3}  {4}{5}" -f $frames[$i % 4], $script:step, $steps, $Title, (Clock $clock.Elapsed.TotalSeconds), $hint
        Write-Host -NoNewline ("`r" + $line.PadRight(78))
        Start-Sleep -Milliseconds 200
        $i++
    }
    $process.WaitForExit()
    $took = [int]$clock.Elapsed.TotalSeconds
    Write-Host -NoNewline ("`r" + ''.PadRight(78) + "`r")
    if ($process.ExitCode -ne 0) {
        Write-Host ("x [{0}/{1}] {2}  failed after {3}" -f $script:step, $steps, $Title, (Clock $took)) -ForegroundColor Red
        Write-Host ''
        Get-Content $log -Tail 30
        Write-Host ''
        Write-Host "The whole log: $log"
        exit 1
    }
    $times[$Name] = $took
    ($times.GetEnumerator() | ForEach-Object { "$($_.Key) $($_.Value)" }) | Set-Content $timesFile
    Write-Host ("+ [{0}/{1}] {2}  {3}" -f $script:step, $steps, $Title, (Clock $took)) -ForegroundColor Green
}

# --- The build -------------------------------------------------------------

if (Test-Path dist) { Remove-Item -Recurse -Force dist }
New-Item -ItemType Directory -Force dist\logs | Out-Null
$total = ($times.Values | Measure-Object -Sum).Sum
if ($total -gt 0) {
    Write-Host "Wisetalk $version for Windows, about $(Clock $total) going by the last release"
} else {
    Write-Host "Wisetalk $version for Windows"
}

$parts = $base -split '\.'
$buildNumber = [int]$parts[0] * 1000000 + [int]$parts[1] * 1000 + [int]$parts[2]

Step 'prepare' 'Packages' 'flutter pub get --enforce-lockfile'

Step 'build' 'Building for Windows' ("flutter build windows --release --build-name=$base " +
    "--build-number=$buildNumber --dart-define=WISETALK_VERSION=$version")

# The release before, so updates from it are a small delta; then the
# installer, the update package and the feed.
Step 'pack' 'Packing the installer and updates' (
    "(vpk download gitea --repoUrl $repo --channel win -o dist || echo no release to make a delta from) && " +
    "vpk pack --packId Wisetalk --packVersion $version --channel win " +
    "--packDir build\windows\x64\runner\Release --mainExe wisetalk.exe --packTitle Wisetalk " +
    "--icon windows\runner\resources\app_icon.ico -o dist")
$installer = "dist\Wisetalk-$version-x64-Setup.exe"
# Velopack's installer, whatever it names it, under a name with the version.
$setup = Get-ChildItem dist\*Setup*.exe | Select-Object -First 1
if (-not $setup) { Fail 'vpk made no installer (dist\logs\pack.log)' }
Move-Item -Force $setup.FullName $installer
$files = @($installer) + @(Get-ChildItem "dist\Wisetalk-$version-win-*.nupkg" | ForEach-Object { $_.FullName }) +
    @('dist\releases.win.json')

# --- Uploading -------------------------------------------------------------
# The same as scripts/release-upload.sh: the tag's release, made if there is
# none yet, with files of the same name replaced.

function Upload {
    $headers = @{ Authorization = "token $token" }
    try {
        $release = Invoke-RestMethod -Headers $headers "$api/releases/tags/$Tag"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
        $notes = @()
        $on = $false
        foreach ($line in Get-Content CHANGELOG.md) {
            if ($line -match "^## $([regex]::Escape($version))( |$)") { $on = $true; continue }
            if ($on -and $line -match '^## ') { break }
            if ($on) { $notes += $line }
        }
        $body = @{
            tag_name = $Tag
            name = "Wisetalk $version"
            body = ($notes -join "`n").Trim()
            prerelease = $version.Contains('-')
        } | ConvertTo-Json
        $release = Invoke-RestMethod -Method Post -Headers $headers -ContentType 'application/json' `
            -Body ([Text.Encoding]::UTF8.GetBytes($body)) "$api/releases"
    }
    foreach ($file in $files) {
        $name = Split-Path $file -Leaf
        foreach ($asset in @($release.assets | Where-Object { $_.name -eq $name })) {
            Invoke-RestMethod -Method Delete -Headers $headers "$api/releases/$($release.id)/assets/$($asset.id)" | Out-Null
        }
        $answer = Run {
            curl.exe -sS --fail-with-body -H "Authorization: token $token" `
                -F "attachment=@$file" "$api/releases/$($release.id)/assets?name=$name"
        }
        if ($LASTEXITCODE -ne 0) { throw "cannot attach ${name}: $answer" }
    }
}

$step++
$clock = [Diagnostics.Stopwatch]::StartNew()
Write-Host -NoNewline ("[{0}/{1}] Uploading to Forgejo..." -f $step, $steps)
try {
    Upload
} catch {
    Write-Host ''
    Fail "upload failed: $_"
}
Write-Host ("`r+ [{0}/{1}] Uploading to Forgejo  {2}" -f $step, $steps, (Clock $clock.Elapsed.TotalSeconds)) -ForegroundColor Green

Write-Host ''
Write-Host "Released in $(Clock $started.Elapsed.TotalSeconds):"
foreach ($file in $files) {
    $size = (Get-Item $file).Length / 1MB
    Write-Host ('  {0,-44} {1:N0} MB' -f (Split-Path $file -Leaf), $size)
}
Write-Host "$repo/releases/tag/$Tag"
