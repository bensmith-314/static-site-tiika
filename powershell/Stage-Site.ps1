# Directory Variables
$websiteImagesOriginPath = "/Users/bensmith/Documents/Tiika/Website Images/"
$everydaysPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../everydays/"))
$everydaysSmallPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../everydays_small/"))

# Ensure trailing slashes for rsync
if (-not $everydaysPath.EndsWith('/')) { $everydaysPath += '/' }
if (-not $everydaysSmallPath.EndsWith('/')) { $everydaysSmallPath += '/' }

# Verify Folder Exists
New-Item -ItemType Directory -Path $everydaysPath -Force | Out-Null

# Copy everydays from Website Images to working directory (only if missing/changed)
Write-Host "Copying images over to the site generator"

rsync -av --update `
  --include='*.jpg' `
  --exclude='*' `
  "$websiteImagesOriginPath/" `
  "$everydaysPath" > $null 2>&1

# Verify Folder Exists
New-Item -ItemType Directory -Path $everydaysSmallPath -Force | Out-Null

# Resize only images that don't yet exist in everydays_small
Get-ChildItem -Path $everydaysPath -File -Filter "*.jpg" |
ForEach-Object {
    $target = Join-Path $everydaysSmallPath $_.Name
    if (-not (Test-Path $target)) {
        sips -Z 300 $_.FullName --out $target > $null 2>&1
    }
}

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

# Copy Over Images From Local to Site (only if missing or changed)

$articleImagesOriginPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../images/"))
$articleImagesDestinationPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../tiika/images/"))

# Ensure trailing slashes for rsync
if (-not $articleImagesOriginPath.EndsWith('/')) { $articleImagesOriginPath += '/' }
if (-not $articleImagesDestinationPath.EndsWith('/')) { $articleImagesDestinationPath += '/' }

Write-Host "Copying article images to site output"

rsync -av --update `
  --include='*.jpg' `
  --include='*.svg' `
  --exclude='*' `
  "$articleImagesOriginPath" `
  "$articleImagesDestinationPath"# Copy Over Images From Local to Site (only if missing or changed)

$articleImagesOriginPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../images/"))
$articleImagesDestinationPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../tiika/images/"))

# Ensure trailing slashes for rsync
if (-not $articleImagesOriginPath.EndsWith('/')) { $articleImagesOriginPath += '/' }
if (-not $articleImagesDestinationPath.EndsWith('/')) { $articleImagesDestinationPath += '/' }

Write-Host "Copying article images to site output"

rsync -av --update `
  --include='*.jpg' `
  --include='*.svg' `
  --exclude='*' `
  "$articleImagesOriginPath" `
  "$articleImagesDestinationPath"

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