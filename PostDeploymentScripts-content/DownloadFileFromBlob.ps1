$filecopyobject = $using:filecopyobject

$targetFileName = $filecopyobject.OriginalFileName
$targetPath = "C:\Temp\$targetFileName"

if (!(test-path "C:\Temp" -erroraction 0))
{
	new-item "C:\temp" -ItemType Directory | out-null
}

$sourceurl = $filecopyobject.ReturnUri

$webclient = New-Object System.Net.WebClient
$result = $webclient.DownloadFile($sourceurl,$targetpath)