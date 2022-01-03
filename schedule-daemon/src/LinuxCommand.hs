{-# LANGUAGE OverloadedStrings #-}

module LinuxCommand where

import System.Process
import System.Exit
import System.IO
import Text.Format
import Text.Printf

-- # Command checks user in a system.
-- # The requirement is that the command should return 0 exit code if a user is in a system otherwise
-- # return any another code.
-- check: "who | grep {0} | [ $(wc -c) -ne 0 ]"

-- # Can be used following command
-- # notify-send 'Hello world!' 'This is an example notification.' --icon=dialog-information
-- # Taken from here https://wiki.archlinux.org/index.php/Desktop_notifications
-- #
-- # Example
-- #   message: "notify-send 'Your time is mostly up' 'You have only 5 minutes before logout.' --icon=dialog-information"
-- # or if to install "mpg321" command by "sudo apt install mpg321" any sound can be played
-- #   message: "mpg321 /usr/share/parental-control/alien-siren.mp3"
-- # or if to install "play" command by "sudo apt install sox" any sound can be played
-- #   message: "play /usr/share/parental-control/alien-siren.mp3"
-- #
-- # Template params
-- #   {0} is user name/login
-- #
-- message: "notify-send 'Your time is mostly up' 'You have only 3 minutes before logout.' --icon=dialog-information"

-- # Command which should kill/logout a user
-- kill: "skill -KILL -u {0}"

runKillCommand :: String -> IO ()
runKillCommand userName = do
  (errCode, stdout', stderr') <- readProcessWithExitCode "skill" ["-KILL", (format "-u {0}" [userName])] ""
  putStrLn (printf "User %s has been killed" userName)
  return ()

runMessageCommand :: String -> IO ()  
runMessageCommand userName = do
  let command = format "echo {0}" [userName]
  createProcess (shell command) {std_out = CreatePipe}
  putStrLn (printf "Message to user %s has been send" userName)
  return ()

-- | Returns true if user in a system
runCheckCommand :: String -> IO Bool
runCheckCommand userName = do
  let command = format "who | grep {0} | [ $(wc -c) -ne 0 ]" [userName]
  (_, Just hout, _, processHandle) <- createProcess (shell command) {std_out = CreatePipe}
  exitCode <- waitForProcess processHandle
  case exitCode of
    ExitSuccess -> return True
    ExitFailure _ -> return False
