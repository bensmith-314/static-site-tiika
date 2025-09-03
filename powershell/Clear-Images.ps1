# Static everyday
Get-ChildItem (Join-Path $PSScriptRoot "../everydays") -Recurse -Force | Remove-Item -Recurse -Force

# Static everyday_small
Get-ChildItem (Join-Path $PSScriptRoot "../everydays_small") -Recurse -Force | Remove-Item -Recurse -Force

# tiika everyday
Get-ChildItem (Join-Path $PSScriptRoot "../../tiika/everydays") -Recurse -Force | Remove-Item -Recurse -Force

# tiika everyday_small
Get-ChildItem (Join-Path $PSScriptRoot "../../tiika/everydays_small") -Recurse -Force | Remove-Item -Recurse -Force