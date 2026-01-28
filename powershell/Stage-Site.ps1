# Directory Variables
$websiteImagesOriginPath = "/Users/bensmith/Documents/Tiika/Website Images/"
$everydaysPath = Join-Path $PSScriptRoot "../everydays/"
$everydaysSmallPath = Join-Path $PSScriptRoot "../everydays_small/"

# TKTKTK Create some kind of staging area for art pieces to be put and then renamed
# Then put in the appropriate folders

# Verify Folder Exists
New-Item -ItemType Directory -Path $everydaysPath -Force | Out-Null

# Copy everydays from Website Images to working directory (only if missing/changed)
Write-Host "Copying images over to the site generator"

# Get-ChildItem $websiteImagesOriginPath -File |
# Where-Object { $_.Extension -eq ".jpg" } |
# ForEach-Object {
#     $src = $_
#     $targetImage = Join-Path $everydaysPath $src.Name
#     $dst = Get-Item $targetImage -ErrorAction SilentlyContinue

#     if ($null -eq $dst -or $src.Length -ne $dst.Length -or $src.LastWriteTime -gt $dst.LastWriteTime) {
#         Copy-Item $src.FullName $targetImage -Force
#     }
# }

rsync -av --update `
  --include='*.jpg' `
  --exclude='*' `
  "$websiteImagesOriginPath/" `
  "$everydaysPath"

Pause

# Verify Folder Exists
New-Item -ItemType Directory -Path $everydaysSmallPath -Force | Out-Null

# Resize new images from everydays to everydays_small
Get-ChildItem -Path $everydaysPath -File |
Where-Object { $_.Extension -eq ".jpg" } |
ForEach-Object {
    $src = $_
    $targetImage = Join-Path $everydaysSmallPath $src.Name
    $dst = Get-Item $targetImage -ErrorAction SilentlyContinue

    if ($null -eq $dst -or $src.LastWriteTime -gt $dst.LastWriteTime) {
        sips -Z 300 $src.FullName --out $targetImage > $null 2>&1
    }
}

# Testing where this issue is with everyday syncing TKTKTK remove when resolved
Write-Host "$((Get-ChildItem $everydaysPath | Measure-Object).Count) Files in $everydaysPath"

# Create Everydays Artwork Gallery
. "$PSScriptRoot/Create-EverydayGallery.ps1"

# Create Art Pieces Dates JSON Structure
. "$PSScriptRoot/Create-ArtDateJSON.ps1"

# Merge Art Dates and Art Metadata JSON Objects into Art Info JSON
. "$PSScriptRoot/Merge-JSON.ps1"

# Create Everydays Individual Pages
# TKTKTK link back to gallery?
. "$PSScriptRoot/Create-EverydayIndividual.ps1"

# Create Every Article
Get-ChildItem -Path (Join-Path $PSScriptRoot "../markdown/") -Recurse -File -Filter *.md | 
ForEach-Object {
    . "$PSScriptRoot/Create-Articles.ps1" -FilePath $_.FullName
}

# Copy Over Images From Local to Site (only if missing or changed)

$articleImagesOriginPath      = Join-Path $PSScriptRoot "../images/"
$articleImagesDestinationPath = Join-Path $PSScriptRoot "../../tiika/images"

Write-Host "Copying article images to site output"

Get-ChildItem -Path $articleImagesOriginPath -Recurse -File |
Where-Object { $_.Extension -in @(".jpg", ".svg") } |
ForEach-Object {
    $src = $_

    # Compute relative path safely
    $relativePath = $src.FullName.Substring($articleImagesOriginPath.Length)
    $targetPath   = Join-Path $articleImagesDestinationPath $relativePath

    # Ensure destination directory exists
    $targetDir = Split-Path $targetPath -Parent
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    $dst = Get-Item $targetPath -ErrorAction SilentlyContinue

    if (
        $null -eq $dst -or
        $src.Length -ne $dst.Length -or
        $src.LastWriteTime -gt $dst.LastWriteTime
    ) {
        Copy-Item $src.FullName $targetPath -Force
        Write-Host "[Copied]" $relativePath
    }
}

# Generate Article JSON
. "$PSScriptRoot/Create-ArticleJSON.ps1"

# Create Archive Page 
# TKTKTK update to use above aritcle JSON
. "$PSScriptRoot/Create-Archive.ps1"


# Make Home Page
# TKTK Include links at the bottom to 'read more' and link to archive, everyday gallery etc.x`
. "$PSScriptRoot/Create-HomePage.ps1"

# Open site in safari for visual testing before publishing

# publish to github