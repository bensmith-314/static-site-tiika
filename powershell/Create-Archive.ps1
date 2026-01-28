. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder
$archivePath = Join-Path $PSScriptRoot "../../tiika/p/archive.html"

# Add parts to it
[void]$html.AppendLine((
    Get-HeadHTML -Title "Article Archive" `
                 -Description "An archive of all the articles and words I have written" `
                 -Keywords @("Tiika", "Archive", "Human-made", "Article", "Ben Smith") `
                 -PageURL "https://tiika.co/archive"
))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

# Intro to archive text
[void]$html.AppendLine((Convert-MarkdownToHtml (Join-Path $PSScriptRoot "../custom_markdown/archive.md")))

$currentYear = "1000"
$currentMonth = "0"
Get-ChildItem -Path (Join-Path $PSScriptRoot "../markdown/") -Recurse -File -Filter *.md | 
Sort-Object -Descending |
ForEach-Object {
    if ($_ -match "/(\d{4}\/.*)$") {
        $relativePath = $matches[1]
        $parts = $relativePath -split "/"

        # Get Date and Slug
        $year = $parts[0]
        $month = $parts[1].PadLeft(2, '0')
        $day = $parts[2].PadLeft(2, '0')
        $slug = [System.IO.Path]::GetFileNameWithoutExtension($parts[3])

        # Parse Date and Get Link To Article
        $date = Get-Date -Year $year -Month $month -Day $day -Format "MMMM, dd, yyyy"
        $link = "p/$year/$([int]$month)/$([int]$day)/$slug.html"

        $lines = Get-Content $_.FullName
        $title = $lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1
        $title = $title.Replace("# ", "")


        if ($year -eq "1000") {
            [void]$html.AppendLine("<h2>How did you write something in this year?</h2>")
        } elseif ($currentYear -eq "1000"){ # For First Article
            [void]$html.AppendLine("<h2>$year</h2><h3>$(Get-Date $date -Format "MMMM")</h3><ul>")    
        } elseif($currentYear -eq $year) { # Still the same year
            if ($currentMonth -ne $month) { # Same year different month
                [void]$html.AppendLine("</ul><h3>$(Get-Date $date -Format "MMMM")</h3>")
            }
        } else { # New Year
            [void]$html.AppendLine("</ul><h2>$year</h2><h3>$(Get-Date $date -Format "MMMM")</h3><ul>")
        }

        $currentMonth = $month
        $currentYear = $year

        # Put in line for Article Title
        [void]$html.AppendLine("<li><a href=`"/$link`">$title</a> - $date</li>")
    }
}
# Close out final <ul>
[void]$html.AppendLine("</ul>")

# Scripts
[void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")

# Foot
[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$html | Set-Content $archivePath