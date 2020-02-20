@echo off

cd %~dp0

REM Color function by mlocati - https://gist.github.com/mlocati/fdabcaeb8071d5c75a2d51712db24011#file-win10colors-cmd
setlocal
call :setESC

set githubdata=GithubData
set depotdownloader_archive=Archives\DepotDownloader
set oxidemod_archive=Archives\OxideMod
set depotdownloader_extracted=DepotDownloader
set references=References

IF NOT EXIST %githubdata%\ (
  echo %ESC%[93mCreating github data folder%ESC%[0m
  mkdir %githubdata%
)

echo %ESC%[96mGetting latest DepotDownloader Github release data%ESC%[0m
curl https://api.github.com/repos/SteamRE/DepotDownloader/releases/latest -o %githubdata%\DepotDownloader.latest
for /f tokens^=4^ delims^=^" %%a in ('findstr browser_download_url %githubdata%\DepotDownloader.latest') do set depotdownloader_link=%%a
for /f tokens^=4^ delims^=^" %%a in ('findstr name %githubdata%\DepotDownloader.latest') do set depotdownloader_name=%%a

IF NOT EXIST %depotdownloader_archive%\ (
  echo %ESC%[93mCreating DepotDownloader archive folder%ESC%[0m
  mkdir %depotdownloader_archive%
)

IF EXIST "%depotdownloader_archive%\%depotdownloader_name%" (
  echo %ESC%[92mLatest version already downloaded%ESC%[0m
) ELSE (
  echo %ESC%[96mDownloading latest DepotDownloader: %depotdownloader_name%%ESC%[0m
  curl -L %depotdownloader_link% -o %depotdownloader_archive%\%depotdownloader_name%
)

echo %ESC%[96mGetting latest OxideMod Github release data%ESC%[0m 
curl https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest -o %githubdata%\OxideMod.latest
for /f tokens^=4^ delims^=^" %%a in ('findstr tag_name %githubdata%\OxideMod.latest') do (
  set oxidemod_tagname=%%a
  set oxidemod_name=Oxide.Rust.%%a.zip
)

IF NOT EXIST %oxidemod_archive%\ (
  echo %ESC%[93mCreating OxideMod archive folder%ESC%[0m
  mkdir %oxidemod_archive%
)

IF EXIST "%oxidemod_archive%\%oxidemod_name%" (
  echo %ESC%[92mLatest version already downloaded%ESC%[0m
) ELSE (
  echo %ESC%[96mDownloading latest OxideMod: %oxidemod_tagname%%ESC%[0m
  curl -L https://github.com/OxideMod/Oxide.Rust/releases/download/%oxidemod_tagname%/Oxide.Rust.zip -o %oxidemod_archive%\%oxidemod_name%
)

IF NOT EXIST %depotdownloader_extracted%\ (
  echo %ESC%[93mCreating DepotDownloader folder%ESC%[0m
  mkdir %depotdownloader_extracted%
)

IF NOT EXIST %depotdownloader_extracted%\DepotDownloader.dll (
  echo %ESC%[95mExtracting latest version of DepotDownloader%ESC%[0m
  cd %depotdownloader_extracted%
  tar -xf ..\%depotdownloader_archive%\%depotdownloader_name%
  if errorlevel 1 (
    echo %ESC%[91mFailed to unzip DepotDownloader archive! %ESC%[0m
    exit /b %errorlevel%
  )
  cd ..
)

IF NOT EXIST %references%\ (
  echo %ESC%[93mCreating References folder%ESC%[0m
  mkdir %references%
)

echo %ESC%[95mDownloading latest version of server dll's %ESC%[0m
dotnet %depotdownloader_extracted%\DepotDownloader.dll -app 258550 -depot 258551 -dir %references% -filelist .references -validate

echo %ESC%[95mExtracting latest OxideMod version%ESC%[0m
cd %references%
tar -xf ..\%oxidemod_archive%\%oxidemod_name% *.dll
if errorlevel 1 (
  echo %ESC%[91mFailed to unzip OxideMod archive! %ESC%[0m
  exit /b %errorlevel%
)
  
:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
exit /B 0