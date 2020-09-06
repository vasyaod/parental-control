# Parental control

Allows to control user login time and spent time time in Linux OS. Basically his app is advantaged version of this script

```
#!/bin/bash

# Add this script to Crone
# */1 0-7,10-17,19-23 * * * parental-control

USER=vasyaod
IS_USER_LOGINED=$(who | grep $USER)

if [ ! -z "$IS_USER_LOGINED" ]
then
  # echo "vasyaod is here"
  skill -KILL -u $USER
fi
```

but with more features

  * flexible schedule 
  * supporting multiple users 
  * time counter
  * daily limits
  
## Installation 

### Debian
    
  * Copy [zip file](https://github.com/vasyaod/parental-control/suites/1150813464/artifacts/16586770)
  * Extract the *.dep package
  * Install the packge by `dpkg -i parental-controll-1.0.0.deb` 

## Config

  * After installation the config file can be found `/etc/parental-control-config.yml` 
  * Example of the config file with parameter description is awailable in the repo [config.yml](./config.yml)

## Build

```
stack build --test --copy-bins
```

## Run as daemon

```
start-stop-daemon -S -b -u root --exec /root/parental-control -- -c /etc/parental-control-config.yml -s /var/log/parental-control-state
```

## Stop

```
start-stop-daemon -K --exec /root/parental-control
```

## License

MIT License

Copyright (c) 2020 Vasilii Vazhesov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.