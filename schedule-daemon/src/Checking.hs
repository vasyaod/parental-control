{-# LANGUAGE OverloadedStrings #-}

module Checking where

--(forever)
--(threadDelay)

import AppState
import Config
import DbLog
import LinuxCommand
import WindowsCommand
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
import System.Info (os)
import Database.SQLite.Simple
import System.Process

instance Exec IO where
  exec command args = readProcessWithExitCode command args ""
  loggg = Prelude.putStrLn

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
      logFn = logToDb conn localTime
      killFn = case os of 
        "linux" -> LinuxCommand.runKillCommand
        "mingw32" -> WindowsCommand.runKillCommand
        _ -> WindowsCommand.runKillCommand
      messageFn = case os of 
        "linux" -> LinuxCommand.runMessageCommand
        "mingw32" -> WindowsCommand.runMessageCommand
        _ -> WindowsCommand.runKillCommand
      checkFn = case os of 
        "linux" -> LinuxCommand.runCheckCommand
        "mingw32" -> WindowsCommand.runCheckCommand
        _ -> WindowsCommand.runCheckCommand
  
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
