echo %homedrive%%homepath%

copy "..\config-windows.yml" config.yml
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control.exe parental-control.exe
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control-web.exe parental-control-web.exe
copy windows\parental-control-starter.exe parental-control-starter.exe
copy windows\parental-control-starter.xml parental-control-starter.xml
