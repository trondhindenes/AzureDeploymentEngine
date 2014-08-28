$thismodulepath = $psscriptroot
$verboselevel = 2

add-type -Path "$psscriptroot\Dlls\newtonsoft.json.dll"
add-type -Path "$psscriptroot\Dlls\AzureDeploymentEngine.dll"
gci $psscriptroot\Nikolic-AzureHelpers\*.ps1 | % { . $_.FullName }
gci $psscriptroot\Credentials\*.ps1 | % { . $_.FullName }
gci $psscriptroot\PostDeploymentScripts\*.ps1 | % { . $_.FullName }
gci $psscriptroot\ObjectFunctions\*.ps1 | % { . $_.FullName }
gci $psscriptroot\Invoke-Azdeproject.ps1 | % { . $_.FullName }
gci $psscriptroot\Get-AzdeIntResultingSetting.ps1 | % { . $_.FullName }
gci $psscriptroot\Enable-AzdeAzureSubscription.ps1 | % { . $_.FullName }
gci $psscriptroot\iaas\*.ps1 | % { . $_.FullName }
gci $psscriptroot\helperfunctions\*.ps1 | % { . $_.FullName }
gci $psscriptroot\AssertFunctions\*.ps1 | % { . $_.FullName }
gci $psscriptroot\AzureBlobFunctions\*.ps1 | % { . $_.FullName }

#Read ModuleSettings
$modulesettingsJson = get-content "$psscriptroot\ModuleSettings.json" -raw
$modulesettings = $modulesettingsJson | ConvertFrom-Json
$ArtifactPath = $modulesettings.artifactPath

$ArtifactPath = $ArtifactPath.replace("MyDocuments",(get-specialfolder "MyDocuments"))
Write-Verbose "ArtifactPath set to $artifactpath"
