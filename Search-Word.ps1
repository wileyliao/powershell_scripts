param(
    # Project root path, e.g. C:\Projects\my-python-app
    [string]$RootPath = ".",

    # Keyword to search, e.g. paddle
    [Parameter(Mandatory = $true)]
    [string]$Keyword,

    # File extensions to search
    [string[]]$Extensions = @("*.py", "*.md", "*.txt", "*.yml", "*.yaml", "*.json")
)

Write-Host "Root path : $RootPath"
Write-Host "Keyword   : $Keyword"
Write-Host "Extensions: $($Extensions -join ', ')"
Write-Host "----------------------------------------"

# Get all target files
$files = Get-ChildItem -Path $RootPath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "No files found with given extensions."
    exit
}

$anyFound = $false

foreach ($file in $files) {
    # Search keyword in file
    $matches = Select-String -Path $file.FullName -Pattern $Keyword -SimpleMatch -ErrorAction SilentlyContinue

    if ($matches) {
        $anyFound = $true
        Write-Host ""
        Write-Host "File: $($file.FullName)"

        foreach ($m in $matches) {
            Write-Host ("  Line {0}: {1}" -f $m.LineNumber, $m.Line.Trim())
        }
    }
}

if (-not $anyFound) {
    Write-Host ""
    Write-Host ("No matches found for '{0}'." -f $Keyword)
}
# .\Search-Word.ps1 -Keyword "word_you_want_to_find"