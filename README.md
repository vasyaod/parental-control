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

### Debian/Ubuntu
    
  * Download [zip file](https://github.com/vasyaod/parental-control/suites/1184600776/artifacts/17364801)
  * Extract the *.dep package
  * Install the package by `dpkg -i parental-control-1.0.0.deb` 

### CentOS/Redhat/Fedora
  
_The OS was not tested_
    
  * Download [zip file](https://github.com/vasyaod/parental-control/suites/1184600776/artifacts/17364801)
  * Extract the *.rpm package
  * Install the package by `rpm –i parental-control-1.0.0.rpm` 

## Config

  * After installation the config file can be found `/etc/parental-control-config.yml` 
  * Example of the config file with parameter description is awailable in the repo [config.yml](./config.yml)

Weakly schedule for multiple users looks like:

```yaml
commands:
  # Command checks user in a system.
  # The requirement is that the command should return 0 exit code if a user is in a system otherwise
  # return any another code.
  check: "who | grep {0} | [ $(wc -c) -ne 0 ]"

  # Can be used following command
  # notify-send 'Hello world!' 'This is an example notification.' --icon=dialog-information
  # Taken from here https://wiki.archlinux.org/index.php/Desktop_notifications
  # Example
  # message: "notify-send 'Your time is mostly up' 'You have only 5 minutes before logout.' --icon=dialog-information"
  message: "echo 'This is stub which is not sent a message anywhere'"

  # Command which should kill/logout a user
  kill: "skill -KILL -u {0}"

# This app keep all state in memory but periodically can unload some information to file.
# Basically it is one of ways to et information about users
stateFilePath: /var/run/parental-control/state

# The param works if parental-control-web is set up 
httpPort: 8080

users:
  - login: yasha
    timeLimit: 150             # Daily time limit (minutes)
    noticePeriod: 5            # Notice period is the time period between the sending message and the killing of a user (minutes)
    schedule:
      mon:
        - start: 07:00
          end: 08:00
        - start: 14:00
          end: 20:00
      tue:
        - start: 07:00
          end: 08:00
        - start: 14:00
          end: 21:00
      wed:
        - start: 07:00
          end: 08:00
        - start: 14:00
          end: 21:00
      thu:
        - start: 07:00
          end: 08:00
        - start: 14:00
          end: 21:00
      fri:
        - start: 07:00
          end: 08:00
        - start: 14:00
          end: 21:00
      sat:
        - start: 07:00
          end: 21:00
      sun:
        - start: 07:00
          end: 21:00

  - login: sunny
    timeLimit: 18000           # Minutes
    noticePeriod: 5            # Notice period is the time period between the sending message and the killing of a user (minutes)
    schedule:
      mon:
        - start: 05:00
          end: 22:00
      tue:
        - start: 05:00
          end: 22:00
      wed:
        - start: 05:00
          end: 22:00
      thu:
        - start: 05:00
          end: 22:00
      fri:
        - start: 05:00
          end: 22:00
      sat:
        - start: 05:00
          end: 22:00
      sun:
        - start: 05:00
          end: 22:00
```

## Maintenance 

### Build

```
stack build --test --copy-bins
```

### Run as daemon

```
start-stop-daemon -S -b -u root --exec /root/parental-control -- -c /etc/parental-control-config.yml -s /var/log/parental-control-state
```

### Stop daemon

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