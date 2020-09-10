module Checking where

--(forever)
--(threadDelay)

import AppState
import Config
import Control.Concurrent
import Control.Monad
import qualified Data.Map as Map
import Data.Maybe (fromJust, fromMaybe)
import Data.Time
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.LocalTime
import System.Console.GetOpt
import System.Environment
import System.Exit
import System.IO
import System.Process
import Text.Printf

getTimesForDayOfWeek :: DayOfWeek -> Schedule -> [Range]
getTimesForDayOfWeek Monday = mon
getTimesForDayOfWeek Tuesday = tue
getTimesForDayOfWeek Wednesday = wed
getTimesForDayOfWeek Thursday = thu
getTimesForDayOfWeek Friday = fri
getTimesForDayOfWeek Saturday = sat
getTimesForDayOfWeek Sunday = sun

checkTime :: LocalTime -> Range -> Bool
checkTime currentTime range = (localTimeOfDay currentTime) > (start range) && (localTimeOfDay currentTime) < (end range)

checkTimes :: LocalTime -> [Range] -> Bool
checkTimes currentTime ranges = foldl (||) False (map (checkTime currentTime) ranges)

checkSchedule :: Schedule -> LocalTime -> Bool
checkSchedule schedule localTime =
  let dayOfW = dayOfWeek $ localDay localTime
      ranges = (getTimesForDayOfWeek dayOfW) $ schedule
   in checkTimes localTime ranges

runKillCommand :: Commands -> String -> IO ()
runKillCommand commands userName = do
  let command = printf (kill commands) userName
  createProcess (shell command) {std_out = CreatePipe}
  putStrLn (printf "User %s has been killed" userName)
  return ()

runMessageCommand :: Commands -> String -> IO ()
runMessageCommand commands userName = do
  let command = printf (message commands) userName
  createProcess (shell command) {std_out = CreatePipe}
  putStrLn (printf "Message to user %s has been send" userName)
  return ()

-- | Return true if user in a system
runCheckCommand :: Commands -> String -> IO Bool
runCheckCommand commands userName = do
  let command = printf (check commands) userName
  (_, Just hout, _, processHandle) <- createProcess (shell command) {std_out = CreatePipe}
  exitCode <- waitForProcess processHandle
  case exitCode of
    ExitSuccess -> return True
    ExitFailure _ -> return False

checkUser :: LocalTime -> MVar AppState -> (String -> IO Bool) -> (String -> IO ()) -> (String -> IO ()) -> User -> IO ()
checkUser localTime state checkFn killFn messageFn userConfig = do
  let isScheduled = checkSchedule (schedule userConfig) localTime
      userName = login userConfig
      shiftedLocalTime = addLocalTime (secondsToNominalDiffTime 300) localTime
      isScheduledForShifted = checkSchedule (schedule userConfig) shiftedLocalTime

  inTheSystem <- checkFn userName
  st <- readMVar state
  let isAllMinutesUsed = (usedMinutes st userName localTime) > (timeLimit userConfig)
  putStrLn ("User " ++ show (userName, inTheSystem, isScheduled, isAllMinutesUsed, isScheduledForShifted))

  -- Kill logic implementation
  case (inTheSystem, isScheduled, isAllMinutesUsed) of
    (True, False, _) -> killFn userName
    (True, True, True) -> killFn userName
    _ -> return ()

  -- Sending message/user notification implementation
  case (inTheSystem, isScheduled, isAllMinutesUsed, isScheduledForShifted) of
    (True, True, False, False) -> messageFn userName
    _ -> return ()

  -- Time increasing
  let newState =
        case (inTheSystem, isScheduled, isAllMinutesUsed) of
          (True, True, False) -> addMinutes st userName localTime 1
          _ -> st
  swapMVar state newState
  return ()

checkingLoop :: MyConfig -> MVar AppState -> IO ()
checkingLoop config state = forever $ do
  now <- getCurrentTime
  timezone <- getCurrentTimeZone
  let localTime = utcToLocalTime timezone now
      killFn = runKillCommand (commands config)
      checkFn = runCheckCommand (commands config)
      messageFn = runMessageCommand (commands config)
  sequence (map (checkUser localTime state checkFn killFn messageFn) (users config))
  threadDelay (60 * 1000 * 1000)
