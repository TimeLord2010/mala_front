flutter build windows --release

source_folder="./build/windows/x64/runner/Release"
# source_folder="./build/windows/runner/Release"
output_zipfile="./bash/Mala.zip"
powershell.exe -Command "Compress-Archive -Force -Path './build/windows/x64/runner/Release' -DestinationPath './bash/Mala.zip'"