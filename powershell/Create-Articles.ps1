param(
    $FilePath
)

. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder

# Add parts to it
[void]$html.AppendLine((Get-HeadHTML))
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
