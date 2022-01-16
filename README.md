# Parental control

Allows to control user login time and calculate consumed time in Windows and Linux. Basically this app is advantaged version of this script

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
  * web UI (installation of the UI is not obligatory) which allows to see
    * state of consumed time for current date
    * statistics of consumed time
  
## Installation 

### Windows

  * Download [parental-control-setup.exe](../windows-assets/parental-control-setup.exe?raw=true)
  * Run parental-control-setup.exe

### Debian/Ubuntu
    
  * Download [parental-control-all-1.0.0.deb](../linux-assets/parental-control-all-1.0.0.deb?raw=true)
  * Install the package by `dpkg -i parental-control-all-1.0.0.deb` 
  * Also there is a way set up only the schedule daemon without a web interface by `dpkg -i parental-control-1.0.0.deb`

### CentOS/Redhat/Fedora
  
_The OS was not tested_
    
  * Download [parental-control-all-1.0-1.x86_64.rpm](../linux-assets/parental-control-all-1.0-1.x86_64.rpm?raw=true)
  * Install the package by `rpm –i parental-control-all-1.0-1.x86_64.rpm` 
  * Also there is a way set up only the schedule daemon without a web interface by `rpm –i parental-control-1.0-1.x86_64.rpm`

## Config

  * After installation the config file can be found `/etc/parental-control.yml` (or `C:\Program Files\parental-control` for Windows)
  * Example of the config file with parameter description is awailable in the repo [config.yml](./schedule-daemon/config.yml)

Weakly schedule for multiple users looks like:

```yaml
# This app keep all state in memory but periodically can unload some information to file.
# Basically it is one of ways to et information about users
statePath: /var/lib/parental-control

# The param allows to use http interface getting reports The param works if parental-control-web is set up
httpEnable: true

# The param could also has the next values
#  * means HostAny
#  *4 means HostIPv4
#  !4 means HostIPv4Only
#  *6 means HostIPv6
#  !6 means HostIPv6Only
#
# The param works if parental-control-web is set up
httpInterface: 127.0.0.1

# The param works if parental-control-web is set up 
httpPort: 8090

# PAth to http static content, like html pages and JS scripts
httpStaticPath: /usr/share/parental-control

users:
  - login: yasha
    timeLimit: 150             # Daily time limit (minutes)
    noticePeriod: 3            # Notice period is the time period between the sending message and the killing of a user (minutes)
    # Format of time should be HH:mm (2 digits per hour and minute fields), like
    #  07:01
    #  13:06
    #  17:38
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
    noticePeriod: 3            # Notice period is the time period between the sending message and the killing of a user (minutes)
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

## HTTP interface

By default HTTP interface is available on http://localhost:8090 where following things can be find
  
  * consumed time per each user

![Screenshot](/docs/screenshot-2.png)

![Screenshot](/docs/screenshot-3.png)

## HTTP API

  * http://localhost:8090/state returns state of the app as JSON in the next format
    
    ```json
    {
        "userStates": {
            "sunny": {
                "messageSent": false,
                "minuteCount": 0,
                "lastChanges": "2020-09-14T04:32:47.391878169"
            },
            "yasha": {
                "messageSent": false,
                "minuteCount": 0,
                "lastChanges": "2020-09-14T04:32:47.391878169"
            }
        }
    }
    ``` 
  * http://localhost:8090/stats returns aggregated logs for one year and all users
    
    ```json
    [
        { "user": "yasha", "date": "2020-09-14", "minutes": 60 },
        { "user": "sunny", "date": "2020-09-14", "minutes": 87 },
        { "user": "yasha", "date": "2020-09-15", "minutes": 10 }
        ...
    ]
    ```

## Maintenance 

### Build of schedule and web daemons

```
cd schedule-daemon
stack build --test --copy-bins
```

Output files:
  * windows: 
    * $HOME\AppData\Roaming\local\bin\parental-control.exe
    * $HOME\AppData\Roaming\local\bin\parental-control-web.exe
  * linux: 
    * $HOME/.local/bin/parental-control
    * $HOME/.local/bin/parental-control-web


### Build of web UI

```
cd web-ui
npm install
npm rub build
```

## Linux 

### Run as daemon

```
start-stop-daemon -S -b -u root --exec /root/parental-control -- -c /etc/parental-control.yml
```

### Stop daemon

```
start-stop-daemon -K --exec /root/parental-control
```

# Windows

Windows Service Wrapper https://github.com/winsw/winsw

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