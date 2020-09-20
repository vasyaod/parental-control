{-# LANGUAGE OverloadedStrings #-}

module Checking where

--(forever)
--(threadDelay)

import AppState
import Config
import Control.Concurrent
import Control.Monad
import Control.Monad.State
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
import Text.Format
import Database.SQLite.Simple

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
  let command = format (kill commands) [userName]
  createProcess (shell command) {std_out = CreatePipe}
  putStrLn (printf "User %s has been killed" userName)
  return ()

runMessageCommand :: Commands -> String -> IO ()
runMessageCommand commands userName = do
  let command = format (message commands) [userName]
  createProcess (shell command) {std_out = CreatePipe}
  putStrLn (printf "Message to user %s has been send" userName)
  return ()

-- | Returns true if user in a system
runCheckCommand :: Commands -> String -> IO Bool
runCheckCommand commands userName = do
  let command = format (check commands) [userName]
  (_, Just hout, _, processHandle) <- createProcess (shell command) {std_out = CreatePipe}
  exitCode <- waitForProcess processHandle
  case exitCode of
    ExitSuccess -> return True
    ExitFailure _ -> return False

-- | writes a row in DB log
logToDb :: Connection -> TimeZone -> LocalTime -> String-> IO ()
logToDb conn timeZone localTime userName = do
  let tm = localTimeToUTC timeZone localTime
  execute conn "INSERT INTO log (tm, user) VALUES (?, ?)" (tm, userName)

checkUser :: LocalTime -> (String -> IO Bool) -> (String -> IO ()) -> (String -> IO ()) -> (String -> IO ()) -> User -> StateT UserState IO ()
checkUser localTime checkFn killFn messageFn logFn userConfig = do
  let isScheduled = checkSchedule (schedule userConfig) localTime
      noticePeriodVal = noticePeriod userConfig
      userName = login userConfig
      shiftedLocalTime = addLocalTime (secondsToNominalDiffTime (fromInteger (toInteger noticePeriodVal) * 60)) localTime
      isScheduledForShifted = checkSchedule (schedule userConfig) shiftedLocalTime

  inTheSystem <- liftIO $ checkFn userName
  st <- get

  let isAllMinutesUsed = (usedMinutes st localTime) > (timeLimit userConfig) -- true if user time is up
      isAlmostAllMinutesUsed = ((usedMinutes st localTime) /= 0)  && ((usedMinutes st localTime) + noticePeriodVal > (timeLimit userConfig))  -- The flag is true if user time is mostly up

  liftIO $ putStrLn ("User " ++ show (userName, inTheSystem, isScheduled, isAllMinutesUsed, isAlmostAllMinutesUsed, isScheduledForShifted))

  -- Kill logic implementation
  case (inTheSystem, isScheduled, isAllMinutesUsed) of
    (True, False, _) -> liftIO $ killFn userName
    (True, True, True) -> liftIO $ killFn userName
    _ -> return ()

  -- Sending message/user notification implementation
  case (inTheSystem, isScheduled, isAllMinutesUsed, isAlmostAllMinutesUsed, isScheduledForShifted, messageSent st) of
    (True, True, False, _, False, False) -> do
      liftIO $ messageFn userName
      modify $ \st -> st {messageSent = True}
    (True, True, False, True, _, False) -> do
      liftIO $ messageFn userName
      modify $ \st -> st {messageSent = True}
    (False, _, _, _, _, True) -> do
      modify $ \st -> st {messageSent = False}
    _ -> return ()

  case (inTheSystem, isScheduled, isAllMinutesUsed) of
    (True, True, False) -> do
      liftIO $ logFn userName
      modify $ addMinutes localTime 1
    _ -> return ()

  return ()

checkingLoop :: MyConfig -> Connection-> MVar AppState -> IO ()
checkingLoop config conn state = forever $ do
  now <- getCurrentTime
  timezone <- getCurrentTimeZone
  let localTime = utcToLocalTime timezone now
      killFn = runKillCommand (commands config)
      checkFn = runCheckCommand (commands config)
      messageFn = runMessageCommand (commands config)
      logFn = logToDb conn timezone localTime

  appState <- readMVar state
  userStates <-
    sequence
      ( map
          ( \userConfig -> do
              userState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConfig) (userStateOrDefault appState (login userConfig) localTime)
              return ((login userConfig), userState)
          )
          (users config)
      )
  swapMVar state (AppState {userStates = Map.fromList userStates})
  threadDelay (60 * 1000 * 1000)
