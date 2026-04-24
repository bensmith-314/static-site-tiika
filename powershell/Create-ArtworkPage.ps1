. "$PSScriptRoot/Get-Snippets.ps1"

$html = New-Object System.Text.StringBuilder
$pagePath = Join-Path $PSScriptRoot "../../tiika/artwork.html"

[void]$html.AppendLine((
    Get-HeadHTML -Title "Artwork Homepage" `
                 -Description "A central location for all my artwork and the information about it" `
                 -Keywords @("Tiika", "Artwork", "Art", "Human-made", "Everyday", "Ben Smith") `
                 -PageURL "https://tiika.co/artwork"
))
[void]$html.AppendLine("<body><main>")
[void]$html.AppendLine((Get-NavHTML))

[void]$html.Append("<h1>Artwork</h1>")
[void]$html.Append("<p>A complete collection of my artwork, art projects, and other visually creative endeavors.</p>")
[void]$html.Append("<h2>The Everyday Project</h2>")
[void]$html.Append("<p>Quick Links:</p>")
[void]$html.Append("<ul><li><a href=`"/everyday`">Everyday Gallery</a></li>")
[void]$html.Append("<li><a href=`"/art-squares`">Art Squares</a></li></ul>")
[void]$html.Append("<p>This is by far my biggest on going project and the one I am most proud of. I started this on March 22, 2021 and have created a piece of digital artwork everyday since. There is a <a href=`"/everyday`">Gallery</a> of every piece I've made for this project. If you only look at one thing on this site, I would recommend checking this out.</p>")
[void]$html.Append("<p>I have also published two articles about this project. The first is on the <a href=`"p/2025/7/4/about-everydays`">origins</a> of the project and what initially inspired it and the second is about my <a href=`"/p/2025/7/23/art-tagging`">philosophy on tagging</a> my artwork in the age of AI.</p>")
[void]$html.Append("<p>As a way of commemorating the ongoing progress in this project, I create a collage of all the daily art pieces I have made every time I hit a square day. Like the gallery, the <a href=`"/art-squares`">Art Squares</a> are a fun way to see everything I have created all in one place.</p>")

# Scripts
[void]$html.AppendLine("<script src=`"/js/menu.js`"></script><script src=`"/js/randomArt.js`"></script></main>")

# Foot
[void]$html.AppendLine((Get-FootHTML))
[void]$html.AppendLine("</body></html>")

$html | Set-Content $pagePath