. "$PSScriptRoot/Get-Snippets.ps1"

$everydaysSmallPath = Join-Path $PSScriptRoot "../everydays_small/"
$everydaysSmallTiikaPath = Join-Path $PSScriptRoot "../../tiika/everydays_small/"
$everydayGalleryPath = Join-Path $PSScriptRoot "../../tiika/p/everyday.html"
$jsonPath = Join-Path $PSScriptRoot "../json/artInfo.json"

# Load JSON into Script
$jsonData = Get-Content $jsonPath -Raw | ConvertFrom-Json

Write-Host "In Create-EverydayGallery.ps1 $((Get-ChildItem $everydaysSmallTiikaPath | Measure-Object).Count) Files in $everydaysSmallTiikaPath"

# Sync everydays_small from static generator to tiika
Get-ChildItem $everydaysSmallPath | 
ForEach-Object {
    $sourceImage = $_.FullName # Source image in /Users/bensmith/Documents/Tiika/Website Images/ as defined above
    $targetImage = Join-Path $everydaysSmallTiikaPath $_.Name # Image in static-site-tiika/everydays

    # Check if the given source image exists, if not copy it over
    if (-not (Test-Path $targetImage)) { 
        Write-Host "[Copying]" -NoNewline -BackgroundColor Blue
        Write-Host " $($_.Name)" -NoNewline
        Copy-Item $sourceImage $targetImage
        Write-Host "`r[Copied]" -NoNewline -BackgroundColor Green
        Write-Host " $($_.Name)    "
    }
}

# rsync -av $everydaysSmallPath $everydaysSmallTiikaPath > $null 2>&1

Write-Host "In Create-EverydayGallery.ps1 $((Get-ChildItem $everydaysSmallTiikaPath | Measure-Object).Count) Files in $everydaysSmallTiikaPath"

# Create the StringBuilder for the HTML
$html = New-Object System.Text.StringBuilder

# Add parts to it
[void]$html.AppendLine((Get-HeadHTML))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

# Text above artwork
[void]$html.AppendLine((Convert-MarkdownToHtml (Join-Path $PSScriptRoot "../custom_markdown/everyday.md")))

# Artwork gallery
[void]$html.AppendLine("<div class=`"image-grid`">")

Get-ChildItem -Path $everydaysSmallPath | 
Sort-Object -Descending |
ForEach-Object {

    # 1. Remove the Extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    # 2. Split into number and title
    $numberPart, $titlePart = $baseName -split '-', 2

    # 3. Trim leading zeros from the number
    $number = [int]$numberPart  # This automatically removes leading zeros

    # 4. Replace hyphens with spaces in the title
    $title = $titlePart -replace '-', ' '

    # 5. Optional: Combine into final form
    $key = "$number"  # Convert number to string key

    if ($null -ne $jsonData.art_pieces.$key.special_name) {
        $displayName = "Day $number`: $($jsonData.art_pieces.$key.special_name)"   
    } else {
        $displayName = "Day $number`: $title"
    }

    $imageHTML = "<a href=`"/i/$number.html`" title = `"$displayName`">`n`t<img src=`"/../everydays_small/$($_.Name)`" alt=`"$displayName`">`n</a>"

    [void]$html.AppendLine($imageHTML)
}
[void]$html.AppendLine("</div><script src=`"/js/menu.js`"></script></main>")

[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$html | Set-Content $everydayGalleryPath
