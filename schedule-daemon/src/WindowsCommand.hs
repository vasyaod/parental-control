module WindowsCommand where

import System.Process
import System.Exit
import System.IO
import Text.Format
import Text.Printf

-- The next command returns list of autorized in the system
--  > query user $USER_NAME
--
-- the command returns
--   USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
--   dummy-user                                4  Active       7:29  12/31/2021 9:29 PM
--   yasha                 console             5  Active       7:29  12/31/2021 9:29 PM

-- The next command allows to log out a user
--  > logoff $SESSION_ID

-- The following command allows to send a message to user
--  > msg vasil /10 "Test"

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
          let sessionId = if (length (head filteredLines)) >= 8 then ((head filteredLines) !! 2) else (head filteredLines) !! 1
          loggg("User found in system with session ID " ++ sessionId)
          (errCode1, stdout1, stderr1) <- exec "logoff" [sessionId]
          return ()
          )
      else return ()

runMessageCommand :: Exec m => String -> m ()  
runMessageCommand userName = do
  (errCode1, stdout1, stderr1) <- exec "msg" [userName, "/10", "User will be killed in a few minutes"]
  loggg (printf "Message to user %s has been send" userName)
  return ()

runCheckCommand :: Exec m => String -> m Bool
runCheckCommand userName = do
  (errCode1, stdout1, stderr1) <- exec "query" ["user", userName]
  let _lines = map (\s -> words s) (lines stdout1)
  let filteredLines = filter (\line -> head line == userName) _lines
  return $ (length filteredLines) > 0
