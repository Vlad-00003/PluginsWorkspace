@echo off

cd %~dp0

set githubdata=GithubData
set depotdownloader_archive=Archives\DepotDownloader
set oxidemod_archive=Archives\OxideMod
set depotdownloader_extracted=DepotDownloader
set references=References

IF NOT EXIST %githubdata%\ (
  echo Creating github data folder
  mkdir %githubdata%
)

echo Getting latest DepotDownloader Github release data
curl https://api.github.com/repos/SteamRE/DepotDownloader/releases/latest -o %githubdata%\DepotDownloader.latest
for /f tokens^=4^ delims^=^" %%a in ('findstr browser_download_url %githubdata%\DepotDownloader.latest') do set depotdownloader_link=%%a
for /f tokens^=4^ delims^=^" %%a in ('findstr name %githubdata%\DepotDownloader.latest') do set depotdownloader_name=%%a

IF NOT EXIST %depotdownloader_archive%\ (
  echo Creating DepotDownloader archive folder
  mkdir %depotdownloader_archive%
)

IF EXIST "%depotdownloader_archive%\%depotdownloader_name%" (
  echo Latest version already downloaded
) ELSE (
  echo Downloading latest DepotDownloader: %depotdownloader_name%
  curl -L %depotdownloader_link% -o %depotdownloader_archive%\%depotdownloader_name%
)

IF NOT EXIST %depotdownloader_extracted%\ (
  echo Creating DepotDownloader folder
  mkdir %depotdownloader_extracted%
)

IF NOT EXIST %depotdownloader_extracted%\DepotDownloader.dll (
  echo Extracting latest version of DepotDownloader
  cd %depotdownloader_extracted%
  tar -xf ..\%depotdownloader_archive%\%depotdownloader_name%
  if errorlevel 1 (
    echo Failed to unzip DepotDownloader archive! 
    exit /b %errorlevel%
  )
  cd ..
)

IF NOT EXIST %references%\ (
  echo Creating References folder
  mkdir %references%
)

echo Downloading latest version of server dll's 
dotnet %depotdownloader_extracted%\DepotDownloader.dll -app 258550 -depot 258551 -dir %references% -filelist .references -validate

echo Extracting latest OxideMod version
OxideDownloader.exe -extract %references%
if errorlevel 1 (
  echo Failed to unzip OxideMod archive! 
  exit /b %errorlevel%
)