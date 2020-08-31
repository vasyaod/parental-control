# parental-control

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

but with more flexible schedule and free time counter

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