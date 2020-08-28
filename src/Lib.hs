module Lib (someFunc, checkTime, checkTimes, checkSchedule) where

--(forever)
--(threadDelay)

import AppState
import Config
import Control.Concurrent
import Control.Monad
import qualified Data.Map as Map
import Data.Maybe (fromJust)
import Data.Time
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.LocalTime
import System.Environment
import System.IO
import System.Process
import Text.Printf

someFunc :: IO ()
someFunc = do
  config <- readConfig
  state <- newMVar AppState {userStates = Map.empty}
  putStrLn $ show config
  --  let (Just val) = config
  loop config state

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

kill :: String -> IO ()
kill userName = do
  createProcess (shell ("skill -KILL -u " ++ userName)) {std_out = CreatePipe}
  return ()

fakeKill :: String -> IO ()
fakeKill userName =
  putStrLn (printf "User %s has been killed" userName)

-- | Return true if user in a system
check :: String -> IO Bool
check userName = do
  (_, Just hout, _, _) <- createProcess (shell ("who | grep " ++ userName)) {std_out = CreatePipe}
  isEOF <- hIsEOF (hout)
  return $ not isEOF

checkUser :: LocalTime -> MVar AppState -> (String -> IO ()) -> User -> IO ()
checkUser localTime state killFn userConfig = do
  let isScheduled = checkSchedule (schedule userConfig) localTime
      userName = login userConfig
  inTheSystem <- check userName
  st <- takeMVar state
  if (isScheduled == False && inTheSystem == True) then killFn userName else return ()

--    return ()

loop :: MyConfig -> MVar AppState -> IO ()
loop config state = forever $ do
  now <- getCurrentTime
  timezone <- getCurrentTimeZone
  let localTime = utcToLocalTime timezone now
  let killFn = if isDebug config then fakeKill else kill -- if we are in debug mode then some stub is used
  sequence (map (checkUser localTime state killFn) (users config))
  threadDelay (1 * 1000 * 1000)
