. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder
$homePath = Join-Path $PSScriptRoot "../../tiika/index.html"

# Add parts to it
[void]$html.AppendLine((
    Get-HeadHTML -Title "Tiika" `
                 -Description "Tiika is a collection of artwork and writings made by Ben Smith" `
                 -Keywords @("Tiika", "Human-made", "Homepage", "Ben Smith")
))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

# Get Articles and Item Counts in reverse chronological order
$artInfoPath = Join-Path $PSScriptRoot "../json/artInfo.json"
$artinfo = Get-Content $artInfoPath -Raw | ConvertFrom-Json
$artDayZero = [datetime]::ParseExact("March, 22, 2021", "MMMM, d, yyyy", $null)
$today = Get-Date

# Days since original art piece with an added day just in case
$daysSince = ($today - $artDayZero).Days + 1


$itemCount = 0
$maxItemCount = 100
# Load the JSON metadata file
$articleInfoPath = Join-Path $PSScriptRoot "../json/articleInfo.json"
$articleInfo = Get-Content $articleInfoPath -Raw | ConvertFrom-Json

# Combine into sortable list with DateTime
$articleList = foreach ($slug in $articleInfo.PSObject.Properties.Name) {
    $info = $articleInfo.$slug
    $dateTimeString = "$($info.date) $($info.time)"
    $dateTime = [datetime]::ParseExact($dateTimeString, "yyyy-MM-dd HH:mm", $null)

    [PSCustomObject]@{
        Slug        = $slug
        Title       = $info.title
        DateTime    = $dateTime
        Summary     = $info.summary
        Description = $info.description
        Draft       = $info.draft
    }
}

# Sort by datetime (oldest first)
$sortedArticles = $articleList | Sort-Object DateTime -Descending

# Check articles versus art pieces to create list
$currentArticleNumber = 0
while ($itemCount -le $maxItemCount) {
    # Checks that the day exists
    if ($artInfo.art_pieces.[string]$daysSince) {
        
        # Parse the art piece dates to be 11PM on their given days
        $daysSinceString = "$daysSince"
        $dateString = $artinfo.art_pieces.$daysSinceString.date
        $fullDateTimeString = "$dateString 23:00"
        $artDate = [datetime]::ParseExact($fullDateTimeString, "MMMM, d, yyyy HH:mm", $null)
        
        if ($artDate -gt $sortedArticles[$currentArticleNumber].DateTime) {
        # If the current art piece is newer
        # This renders out the image container with the title of the art piece and metadata
        # Then increase the number of items and make the current art piece one day earlier

            $currentArthtml = Get-Content (Join-Path $PSScriptRoot "../../tiika/i/$daysSince.html") -Raw

            if ($currentArthtml -match '<img[^>]*src="[^"]*everydays/([^"]+)"') {
                $artFileName = [System.IO.Path]::GetFileNameWithoutExtension($matches[1])
            }

            if ($currentArthtml -match '<h1[^>]*>(.*?)</h1>') {
                $artName = $matches[1]
            }

            [void]$html.AppendLine("<div class=`"home-page-art-container`">")
            [void]$html.AppendLine("<div class=`"home-page-art-image`">")
            [void]$html.AppendLine("<a href=`"/i/$daysSince`"><img src=`"/everydays/$artFileName.jpg`"></a></div>")
            [void]$html.AppendLine("<div class=`"home-page-art-text`">")
            [void]$html.AppendLine("<a href=`"/i/$daysSince`"><h2>$artName</h2></a>")

            # Date
            if (($null -ne $jsonData.art_pieces.$daysSince.date) -and ($null -ne $jsonData.art_pieces.$daysSince.application)) {
                [void]$html.AppendLine("<p>$($jsonData.art_pieces.$daysSince.date)</p>")
            }
            # Application
            if ($null -ne $jsonData.art_pieces.$daysSince.application) {
                [void]$html.AppendLine("<p>Created in: $($jsonData.art_pieces.$daysSince.application)</p>")
            }
            
            # AI Model
            if ($null -ne $jsonData.art_pieces.$daysSince.model) {
                [void]$html.AppendLine("<p>Created with assistance from $($jsonData.art_pieces.$daysSince.model)</p>")
            }
            # Stock
            if ($jsonData.art_pieces.$daysSince.stock) {
                [void]$html.AppendLine("<p>Created with assistance from one or more stock photos</p>")
            }

            [void]$html.AppendLine("</div></div>")
            $itemCount++
            $daysSince--
        } else {
        # Otherwise include the most recent article
        # Then increase the number of items and make the most recent article one older
            $articleDate = Get-Date $sortedArticles[$currentArticleNumber].DateTime

            $currentArticlehtml = Get-Content (Join-Path $PSScriptRoot "../../tiika/p/$($articleDate.Year)/$($articleDate.Month)/$($articleDate.Day)/$($sortedArticles[$currentArticleNumber].Slug).html") -Raw
            if ($currentArticlehtml -match '<h1[^>]*>(.*?)</h1>') {
                $articleName = $matches[1]
            }


            [void]$html.AppendLine("<div class=`"home-page-article-container`">")
            [void]$html.AppendLine("<a href=`"/p/$($articleDate.Year)/$($articleDate.Month)/$($articleDate.Day)/$($sortedArticles[$currentArticleNumber].Slug)`">")
            [void]$html.AppendLine("<h2>$articleName</h2></a>")
            [void]$html.AppendLine("<p>Ben Smith | $(Get-Date $sortedArticles[$currentArticleNumber].DateTime -Format "MMMM, dd, yyyy")</p>")
            [void]$html.AppendLine("<img src=`"/images/$($sortedArticles[$currentArticleNumber].Slug)/$($sortedArticles[$currentArticleNumber].Slug)-hero.jpg`">")
            [void]$html.AppendLine("<p>$($sortedArticles[$currentArticleNumber].Summary)</p>")
            [void]$html.AppendLine("<p><a href=`"/p/$($articleDate.Year)/$($articleDate.Month)/$($articleDate.Day)/$($sortedArticles[$currentArticleNumber].Slug)`">Read More</a></p>")
            [void]$html.AppendLine("</div>")


            $itemCount++
            $currentArticleNumber++
        }
    } else {
        Write-Host $daysSince
        $daysSince--
    }
}

# You've Reached the Bottom Section
[void]$html.AppendLine("<div class=`"home-page-art-container`">")
[void]$html.AppendLine("<div class=`"home-page-art-text`">")
[void]$html.AppendLine("<h2>It Looks Like You've Reached The End</h2>")
[void]$html.AppendLine("<p>The fact that you reached the end tells me one of two things, first that you scrolled to the bottom just to see what was there (I like you), or that you might enjoy what you are seeing. If the latter is the case, you should take a look at my artwork <a href=`"/p/everyday`">gallery</a> if you want to see more art.")
[void]$html.AppendLine("To see more of the articles, words, and random thoughts that I've had and written down, take a look at my article <a href=`"/p/archive`">archive</a>.")
[void]$html.AppendLine("Or, if you want the latest updates or if you want to see more send me a message, reach out to me on <a href=`"https://hachyderm.io/@bensmith`">Mastodon</a>. I check it far more often than I probably should.</p>")
[void]$html.AppendLine("</div></div>")

# Scripts
[void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")

# Foot
[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$html | Set-Content $homePath