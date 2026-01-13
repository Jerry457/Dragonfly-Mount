# param (
#     [string]$type
# )

$postinitFolder = Join-Path $PSScriptRoot "postinit"
$postinitFiles = Get-ChildItem $postinitFolder -Recurse -Filter *.lua
$postinits = @()
foreach ($postinitFile in $postinitFiles) {
    $relativePath = $postinitFile.FullName.Substring($postinitFolder.Length + 1)
    $relativePath = $relativePath.Replace("\", "/")
    $postinits += "    `"postinit/$($relativePath)`""
}

$postinitString = "local files = {`n" + ($postinits -join ",`n") + "`n}`n"
$postinitString += "`nfor _, file in ipairs(files) do`n    modimport(file)`nend"
$postinitString | Out-String | ForEach-Object { [System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "main/postinit.lua"), $_, [System.Text.UTF8Encoding]::new($false)) }

$prefabFolder = Join-Path $PSScriptRoot "scripts/prefabs"
$prefabFiles = Get-ChildItem $prefabFolder -Recurse -Filter *.lua
$prefabs = @()
foreach ($prefabFile in $prefabFiles) {
    $relativePath = $prefabFile.FullName.Substring($prefabFolder.Length + 1)
    $relativePath = $relativePath.Replace("\", "/")
    $relativePath = $relativePath.Replace(".lua", "")
    $prefabs += "    `"$($relativePath)`""
    write-host $relativePath
}
$prefabString = "PrefabFiles = {`n" + ($prefabs -join ",`n") + "`n}"
$prefabString | Out-String | ForEach-Object { [System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "main/prefab_files.lua"), $_, [System.Text.UTF8Encoding]::new($false)) }

$animFolder = Join-Path $PSScriptRoot "anim"
$animFiles = Get-ChildItem $animFolder -Recurse -Filter *.zip
$anims = @()
foreach ($animFile in $animFiles) {
    $relativePath = $animFile.FullName.Substring($animFolder.Length + 1)
    $relativePath = $relativePath.Replace("\", "/")
    $anims += "    `Asset(`"ANIM`", `"anim/$($relativePath)`")"
}
$animString = "local assets = {`n" + ($anims -join ",`n") + "`n}`n"
$animString += "`nGLOBAL.JoinArrays(Assets, assets)"
$animString | Out-String | ForEach-Object { [System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "main/anim-assets.lua"), $_, [System.Text.UTF8Encoding]::new($false)) }
