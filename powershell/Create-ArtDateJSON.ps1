$json = New-Object System.Text.StringBuilder

[void]$json.AppendLine("{`n`"art_pieces`": {")
$j = 0

$everydaysPath = Join-Path $PSScriptRoot "../everydays/"
$jsonPath = Join-Path $PSScriptRoot "../json/artDates.json"

$totalArtPieces = (Get-ChildItem $everydaysPath).Count
$startDay = Get-Date "March 22, 2021"

for ($i = 1; $i -lt $totalArtPieces + 1; $i++) {
    $day = $startDay.AddDays($j).ToString("MMMM, d, yyyy")
    if ($i -lt $totalArtPieces) {
        [void]$json.AppendLine("`"$i`": {`n`t`"date`": `"$day`",`n`t`"application`": `"Adobe Illustrator`"`n},")
    } else {
        [void]$json.AppendLine("`"$i`": {`n`t`"date`": `"$day`",`n`t`"application`": `"Adobe Illustrator`"`n}")
    }
    
    $j++
}

[void]$json.AppendLine("`t}`n}")

$json | Set-Content $jsonPath