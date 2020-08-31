# Parental control

This app is advantaged version of this script

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

## Config 

```
isDebug: true
users:
  - login: vasyaod
    timeLimit: 180           # Limit time (minutes) per day 
    schedule:
      mon:
        - start: 10:20
          end: 11:20
      tue:
        - start: 10:20
          end: 11:20
      wed:
        - start: 10:20
          end: 11:20
      thu:
        - start: 10:20
          end: 11:20
      fri:
        - start: 10:20
          end: 11:20
      sat:
        - start: 10:20
          end: 11:20
      sun:
        - start: 10:20
          end: 11:20
```

## Build

```
stack build --test --copy-bins
```

## Run as daemon

```
start-stop-daemon -S -b -u root --exec /root/parental-control -- -c /etc/parental-control-config.yml -s /var/log/parental-control-state
```

## License

MIT License

Copyright (c) 2019 Vasilii Vazhesov

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