Get-ChildItem -Path (Join-Path $PSScriptRoot "../markdown/") -Recurse -File -Filter *.md | 
Sort-Object -Descending |
ForEach-Object {
    $markdownFilePath = $_.FullName
    $markdownContent = Get-Content $markdownFilePath -Raw

    ConvertFrom-Yaml

    # Extract YAML front matter
    if ($markdownContent -match "(?s)^---\s*(.*?)\s*---") {
        $yamlText = $matches[1]
        
        # Convert YAML to PowerShell object
        $yamlObject = $yamlText | ConvertFrom-Yaml

        # Access fields
        $slug = $yamlObject.slug
        $articleInfo = [ordered]@{
            title   = $yamlObject.title
            date    = $yamlObject.date
            time    = $yamlObject.time
            summary = $yamlObject.summary
            draft   = $yamlObject.draft
        }

        # Initialize dictionary if it doesn't exist
        if (-not $allArticles) {
            $allArticles = @{}
        }

        # Add or update the article metadata
        $allArticles[$slug] = $articleInfo

        $allArticles | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $PSScriptRoot "../json/articleInfo.json") -Force

    } else {
        Write-Host "Error: No YAML front matter found for $($_.FullName)" -ForegroundColor Red
    }
}