echo %homedrive%%homepath%

copy config-windows.yml config.yml
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control.exe parental-control.exe
copy %homedrive%%homepath%\AppData\Roaming\local\bin\parental-control-web.exe parental-control-web.exe
copy windows\parental-control-service.exe parental-control-service.exe
copy windows\parental-control-service.xml parental-control-service.xml
copy windows\parental-control-web-service.exe parental-control-web-service.exe
copy windows\parental-control-web-service.xml parental-control-web-service.xml
copy web-ui\bundle.js bundle.js
copy web-ui\index.html index.html 
