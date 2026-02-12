# Sync and resize all images
$syncScript = Join-Path $PSScriptRoot "../shell/sync-and-resize-images.sh"
bash $syncScript

# Create Everydays Artwork Gallery
. "$PSScriptRoot/Create-EverydayGallery.ps1"

# Create Art Pieces Dates JSON Structure
. "$PSScriptRoot/Create-ArtDateJSON.ps1"

# Merge Art Dates and Art Metadata JSON Objects into Art Info JSON
. "$PSScriptRoot/Merge-JSON.ps1"

# Create Everydays Individual Pages
. "$PSScriptRoot/Create-EverydayIndividual.ps1"

# Create Every Article
Get-ChildItem -Path (Join-Path $PSScriptRoot "../markdown/") -Recurse -File -Filter *.md | 
ForEach-Object {
    . "$PSScriptRoot/Create-Articles.ps1" -FilePath $_.FullName
}

# Generate Article JSON
. "$PSScriptRoot/Create-ArticleJSON.ps1"

# Create Archive Page 
. "$PSScriptRoot/Create-Archive.ps1"

# Make Home Page
. "$PSScriptRoot/Create-HomePage.ps1"

# Update randomArt.js
