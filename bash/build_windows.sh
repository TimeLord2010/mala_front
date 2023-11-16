flutter build windows --release

source_folder="./build/windows/runner/Release"
output_zipfile="./bash/Mala.zip"
# Compress-Archive -Path $source_folder -DestinationPath $output_zipfile
powershell.exe -Command "Compress-Archive -Path './build/windows/runner/Release' -DestinationPath './bash/Mala.zip'"