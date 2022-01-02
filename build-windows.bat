mkdir dist
cd dist

echo %homepath%

copy "..\config-windows.yml" config.yml
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control.exe parental-control.exe
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control-web.exe parental-control-web.exe