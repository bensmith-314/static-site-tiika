param(
    $FilePath
)

. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder

# Get Article Title and Description
$markdownContent = Get-Content $FilePath -Raw
if ($markdownContent -match "(?s)^---\s*(.*?)\s*---") {
    $yamlText = $matches[1]
    
    # Convert YAML to PowerShell object
    $yamlObject = $yamlText | ConvertFrom-Yaml

    # Access fields
    $title       = $yamlObject.title
    $description = $yamlObject.description
}

# Add parts to it
[void]$html.AppendLine((
    Get-HeadHTML -Title $title `
                 -Description $description `
                 -Keywords @("Tiika", "Human-made", "Article", "Ben Smith") `
))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

[void]$html.AppendLine((Convert-MarkdownToHtml $filePath))

# Scripts
[void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")

# Foot
[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$outputPath = $FilePath.Replace("static-site-tiika/markdown", "tiika/p")
$outputPath = $outputPath.Replace(".md", ".html")

# Ensure output directory exists
$outputDir = Split-Path $outputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Write content
$html | Set-Content $outputPath
