module WindowsCommand where

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

class Monad m => Exec m where
  exec :: FilePath -> [String] -> m (ExitCode, String, String)
  loggg :: String -> m ()

runKillCommand :: Exec m => String -> m ()
runKillCommand userName = do
  (errCode1, stdout1, stderr1) <- exec "query" ["user", userName]
  let _lines = map (\s -> words s) (lines stdout1)
  let filteredLines = filter (\line -> head line == userName) _lines
  if (length filteredLines) > 0
      then (do
          let sessionId = (show ((head filteredLines) !! 2))
          loggg("User found in system with session ID " ++ sessionId)
          (errCode1, stdout1, stderr1) <- exec "logoff" [sessionId]
          return ()
          )
      else return ()

 -- return ()

runMessageCommand :: Exec m => String -> m ()  
runMessageCommand userName = do
  loggg (printf "Message to user %s has been send" userName)
  return ()

-- | Returns true if user in a system
runCheckCommand :: Exec m => String -> m Bool
runCheckCommand userName = do
  (errCode1, stdout1, stderr1) <- exec "query" ["user", userName]
  let _lines = map (\s -> words s) (lines stdout1)
  let filteredLines = filter (\line -> head line == userName) _lines
  return $ (length filteredLines) > 0
