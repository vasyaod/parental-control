module Lib where

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
import System.IO
import System.Process
import Text.Printf

data Options = Options
  { optConfigFile :: String,
    optStateFile :: String
  }
  deriving (Show)

defaultOptions =
  Options
    { optConfigFile = "./config.yml",
      optStateFile = "./state.yml"
    }

options :: [OptDescr (Options -> Options)]
options =
  [ Option ['c'] ["config"] (ReqArg (\f opts -> opts {optConfigFile = f}) "config") "config file",
    Option ['s'] ["state"] (ReqArg (\f opts -> opts {optStateFile = f}) "state") "state file"
  ]

compilerOpts :: [String] -> IO (Options, [String])
compilerOpts argv =
  case getOpt Permute options argv of
    (o, n, []) -> return (foldl (flip id) defaultOptions o, n)
    (_, _, errs) -> ioError (userError (concat errs ++ usageInfo header options))
  where
    header = "Usage: ic [OPTION...] files..."

someFunc :: IO ()
someFunc = do
  args <- getArgs
  (opts, _) <- compilerOpts (args)
  config <- readConfig optConfigFile opts
  state <- newMVar AppState {userStates = Map.empty}
  -- putStrLn $ optStateFile opts
  -- let (Just val) = config
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

checkUser :: LocalTime -> MVar AppState -> (String -> IO Bool) -> (String -> IO ()) -> User -> IO ()
checkUser localTime state checkFn killFn userConfig = do
  let isScheduled = checkSchedule (schedule userConfig) localTime
      userName = login userConfig
  inTheSystem <- checkFn userName
  st <- takeMVar state
  let isAllMinutesUsed = (usedMinutes st userName localTime) > (timeLimit userConfig)
  case (inTheSystem, isScheduled, isAllMinutesUsed) of
    (True, False, _) -> killFn userName
    (True, True, True) -> killFn userName
    _ -> return ()
  let newState = if inTheSystem == True && isScheduled == True && isAllMinutesUsed == False then addMinutes st userName localTime 1 else st
  putMVar state newState

loop :: MyConfig -> MVar AppState -> IO ()
loop config state = forever $ do
  now <- getCurrentTime
  timezone <- getCurrentTimeZone
  let localTime = utcToLocalTime timezone now
      killFn = if isDebug config then fakeKill else kill -- if we are in debug mode then some stub is used
      checkFn = check
  sequence (map (checkUser localTime state checkFn killFn) (users config))
  threadDelay (1 * 1000 * 1000)
