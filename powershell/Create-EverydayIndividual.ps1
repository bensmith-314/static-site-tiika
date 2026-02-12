. "$PSScriptRoot/Get-Snippets.ps1"

# Resolve to absolute paths (without ..)
$everydaysPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../everydays/"))
$everydaysTiikaPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../tiika/everydays/"))
$jsonPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../json/artInfo.json"))

# Ensure trailing slashes for rsync
if (-not $everydaysPath.EndsWith('/')) { $everydaysPath += '/' }
if (-not $everydaysTiikaPath.EndsWith('/')) { $everydaysTiikaPath += '/' }

$totalFiles = (Get-ChildItem $everydaysPath).Count

# Load JSON into Script
$jsonData = Get-Content $jsonPath -Raw | ConvertFrom-Json

Get-ChildItem -Path $everydaysTiikaPath -Filter "*.jpg" |  
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

    $currentImagePath = Join-Path $PSScriptRoot "../../tiika/i/$number.html"

    # 6. Build Custom Description
    $description = "Day $number of the Everyday Artwork Project by Ben Smith, which explores distraction, abstraction, obsession, discipline, and joy."

    # Create the StringBuilder for the HTML
    $html = New-Object System.Text.StringBuilder

    [void]$html.AppendLine((
        Get-HeadHTML -Title $title `
                    -Description $description `
                    -Keywords @("Tiika", "Human-made", "Artwork", "Everyday", "Daily", "Ben Smith") `
                    -PageURL "https://tiika.co/i/$number" `
                    -ImageURL "https://tiika.co/everydays/$($_.Name)" `
                    -ImageDescription "$title - Day $number of the Everyday Artwork Project by Ben Smith"
                    
    ))
    [void]$html.AppendLine("<body><main>")
    [void]$html.AppendLine((Get-NavHTML))

    # h1, hr, and iamge
    [void]$html.AppendLine("<h1>$displayName</h1>")
    [void]$html.AppendLine("<hr>")
    [void]$html.AppendLine("<div class=`"everyday-image-container`">")
    [void]$html.AppendLine("<img src=`"/everydays/$($_.Name)`" class=`"everyday-image`">")
    
    # Image Navigation Section
    [void]$html.AppendLine("<div class=`"image-navigation`"><ul>")

    if ($number -ne 1) {
        [void]$html.AppendLine("<li><a href=`"$($number - 1)`">Previous</a></li>")
    }
    
    [void]$html.AppendLine("<li><a href=`"#`" id=`"randomArtPiece`">Random</a></li>")

    if ($number -lt $totalFiles) {
        [void]$html.AppendLine("<li><a href=`"$($number + 1)`">Next</a></li>")
    }

    [void]$html.AppendLine("</ul></div>")

    # Art Piece Info
    [void]$html.AppendLine("<div class=`"art-info-container`"><ul>")
    [void]$html.AppendLine("<li>Information About This Piece:</li>")
        # Date
    if ($null -ne $jsonData.art_pieces.$key.date) {
        [void]$html.AppendLine("<li>$($jsonData.art_pieces.$key.date)</li>")
    }
        # Application
    if ($null -ne $jsonData.art_pieces.$key.application) {
        [void]$html.AppendLine("<li>Created in: $($jsonData.art_pieces.$key.application)</li>")
    }
        # AI Model
    if ($null -ne $jsonData.art_pieces.$key.model) {
        [void]$html.AppendLine("<li>Created with assistance from $($jsonData.art_pieces.$key.model)</li>")
    }
        # Stock
    if ($jsonData.art_pieces.$key.stock) {
        [void]$html.AppendLine("<li>Created with assistance from one or more stock photos</li>")
    }
    

    [void]$html.AppendLine("</ul></div>")
    
    
    # Scripts
    [void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")
    
    # Foot
    [void]$html.AppendLine((Get-FootHTML))
    [void]$html.AppendLine("</body></html>")


    $html | Set-Content $currentImagePath
}