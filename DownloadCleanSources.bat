@echo off
cd %~dp0

set oxidemod_archive=Archives\OxideMod
set depotdownloader_extracted=DepotDownloader
set clearSources=ClearSources
set managed=RustDedicated_Data\Managed

for /f %%i in ('dir %oxidemod_archive% /b/a-d/o-d/t:c') do (
	set LatestOxide=%%i
	goto OxideFound
)

echo Oxide not found, download references first.
goto End

:OxideFound
echo Last known oxide version is %LatestOxide%

echo Downloading latest game sources
dotnet %depotdownloader_extracted%\DepotDownloader.dll -app 258550 -depot 258551 -dir %clearSources% -filelist .references -validate

echo Extracting latest known oxide core dlls
cd %clearSources% 
tar -xf ..\%oxidemod_archive%\%LatestOxide% RustDedicated_Data/Managed/Oxide*
if errorlevel 1 (
  echo Failed to unzip OxideMod archive! 
  goto End
)

cd ..
IF EXIST "%clearSources%\%managed%\OxidePatcher.exe" (
  echo OxidePatcher already downloaded
) ELSE (
  echo getting latest version of OxidePatcher
  curl -L https://github.com/OxideMod/OxidePatcher/releases/download/latest/OxidePatcher.exe -o %clearSources%\%managed%\OxidePatcher.exe
)

echo Getting latest version of Rust.obj
curl -L https://raw.githubusercontent.com/OxideMod/Oxide.Rust/develop/resources/Rust.opj -o%clearSources%\%managed%\Rust.opj 

echo Done.

:End
pause