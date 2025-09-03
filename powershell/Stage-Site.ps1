# Directory Variables
$websiteImagesOriginPath = "/Users/bensmith/Documents/Tiika/Website Images/"
$everydaysPath = Join-Path $PSScriptRoot "../everydays/"
$everydaysSmallPath = Join-Path $PSScriptRoot "../everydays_small/"

# TKTKTK Create some kind of staging area for art pieces to be put and then renamed
# Then put in the appropriate folders

# Copy everydays from Website images to this working directory
Write-Host "Copying images over to the site generator"

# Testing where this issue is with everyday syncing TKTKTK remove when resolved
Write-Host "$((Get-ChildItem $websiteImagesOriginPath | Measure-Object).Count) Files in $websiteImagesOriginPath"
Write-Host "$((Get-ChildItem $everydaysPath | Measure-Object).Count) Files in $everydaysPath"

Get-ChildItem $websiteImagesOriginPath | 
ForEach-Object {
    $sourceImage = $_.FullName # Source image in /Users/bensmith/Documents/Tiika/Website Images/ as defined above
    $targetImage = Join-Path $everydaysPath $_.Name # Image in static-site-tiika/everydays

    # Check if the given source image exists, if not copy it over
    if (-not (Test-Path $targetImage)) { 
        Write-Host "[Copying]" -NoNewline -BackgroundColor Blue
        Write-Host " $($_.Name)" -NoNewline
        Copy-Item $sourceImage $targetImage
        Write-Host "`r[Copied]" -NoNewline -BackgroundColor Green
        Write-Host " $($_.Name)    "
    }
}

# Write-Host " $($_.Name)" -NoNewline
# rsync -av $websiteImagesOriginPath $everydaysPath > $null 2>&1
# Write-Host "`r[Synced Everyday Images]" -NoNewline -BackgroundColor Green -ForegroundColor White
# Write-Host " $($_.Name)"

# Testing where this issue is with everyday syncing TKTKTK remove when resolved
Write-Host "$((Get-ChildItem $websiteImagesOriginPath | Measure-Object).Count) Files in $websiteImagesOriginPath"
Write-Host "$((Get-ChildItem $everydaysPath | Measure-Object).Count) Files in $everydaysPath"

# Resize new images from everydays to everydays_small
# TKTKTK there is something wrong here or with the rysnc above
# Issue might be in the transfer of images over to the tiika folders from the static folders
# I need to check for other rsyncs, I think the static-site-tiika side is good, but the tiika side needs fixing

Get-ChildItem -Path $everydaysPath | ForEach-Object {
    $sourceImage = $_.FullName
    $targetImage = Join-Path $everydaysSmallPath $_.Name

    if ((-not (Test-Path $targetImage)) -or ((Get-Item $sourceImage).LastWriteTime -gt (Get-Item $targetImage).LastWriteTime)) {
        Write-Host "[Resizing]" -NoNewline -BackgroundColor Blue -ForegroundColor White
        Write-Host " $($_.Name)" -NoNewline

        sips -Z 300 "$sourceImage" --out "$targetImage" > $null 2>&1

        Write-Host "`r[Resized]" -NoNewline -BackgroundColor Green -ForegroundColor White
        Write-Host " $($_.Name) "
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

# Copy Over Images From Local to Site
# TKTKTK: I think this is good now. Check back later, 
# was having an issue of duplicating article images
$articleImagesOriginPath = Join-Path $PSScriptRoot "../images/"
$articleImagesDestinationPath = Join-Path $PSScriptRoot "../../tiika/images"

Get-ChildItem -Path $articleImagesOriginPath -Recurse -File |
ForEach-Object {
    $subfile = $_.FullName.Substring($articleImagesOriginPath.Length - 14)
    $subfolder = $subfile.Split("/")
    if (($subfile.Substring($subfile.Length - 4) -eq ".jpg") -or ($subfile.Substring($subfile.Length - 4) -eq ".svg")) {
        
        New-Item -ItemType Directory (Join-Path $articleImagesDestinationPath $subfolder[0]) -Force
        if (-not (Test-Path ((Join-Path $articleImagesDestinationPath $subfile)))) {
            Copy-Item $_ (Join-Path $articleImagesDestinationPath $subfile)
        }
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