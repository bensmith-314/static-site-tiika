. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder
$htmlPath = Join-Path $PSScriptRoot "../../tiika/art-squares.html"
$imagesPath = Join-Path $PSScriptRoot "../../tiika/images/squares"

# Get Count of art squares to pick link sharing ImageURL
$totalImages = (Get-ChildItem $imagesPath).Count
$currentSquare = $totalImages * $totalImages

# Add parts to it
[void]$html.AppendLine((
    Get-HeadHTML -Title "Art Squares" `
                 -Description "A collection of collages of my daily artwork arranged into increasingly large collages with one for each square day (1, 4, 9, 16 etc.)." `
                 -Keywords @("Tiika", "Art", "Art Collection", "Everyday", "Human-made", "Article", "Ben Smith") `
                 -PageURL "https://tiika.co/art-squares" `
                 -ImageURL "https://tiika.co/images/squares/day-$currentSquare-square.jpg" `
                 -ImageDescription "Art Square collage of daily art pieces from Day 1 through Day $currentSquare"
))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

[void]$html.AppendLine((Convert-MarkdownToHtml (Join-Path $PSScriptRoot "../custom_markdown/art-squares.md")))

# Scripts
[void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")

# Foot
[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$html | Set-Content $htmlPath