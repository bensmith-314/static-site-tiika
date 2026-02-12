# Remove-Duplicates.ps1
# Removes macOS auto-renamed duplicate image files (e.g., "filename 2.jpg", "filename 3.jpg")

param(
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Resolve paths
$everydaysSmallPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../everydays_small/"))
$everydaysTiikaPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../tiika/everydays/"))
$everydaysPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../everydays/"))
$everydaysSmallTiikaPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../tiika/everydays_small/"))

$directories = @(
    $everydaysSmallPath,
    $everydaysTiikaPath,
    $everydaysSmallTiikaPath,
    $everydaysPath
)

$totalRemoved = 0

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "`nChecking: $dir" -ForegroundColor Cyan
        
        $duplicates = Get-ChildItem $dir -Filter "* ?.jpg"
        
        if ($duplicates.Count -eq 0) {
            Write-Host "  No duplicates found" -ForegroundColor Green
        } else {
            Write-Host "  Found $($duplicates.Count) duplicate(s)" -ForegroundColor Yellow
            
            if ($WhatIf) {
                Write-Host "  [WHATIF] Would remove:" -ForegroundColor Magenta
                $duplicates | ForEach-Object { Write-Host "    $($_.Name)" }
            } else {
                $duplicates | ForEach-Object {
                    if ($Verbose) {
                        Write-Host "  Removing: $($_.Name)" -ForegroundColor Red
                    }
                    Remove-Item $_.FullName -Force
                }
                Write-Host "  Removed $($duplicates.Count) file(s)" -ForegroundColor Green
            }
            
            $totalRemoved += $duplicates.Count
        }
    } else {
        Write-Host "`nSkipping (doesn't exist): $dir" -ForegroundColor DarkGray
    }
}

Write-Host "`nTotal duplicates found: $totalRemoved" -ForegroundColor $(if ($totalRemoved -eq 0) { "Green" } else { "Yellow" })

if ($WhatIf -and $totalRemoved -gt 0) {
    Write-Host "Run without -WhatIf to actually remove these files" -ForegroundColor Magenta
}