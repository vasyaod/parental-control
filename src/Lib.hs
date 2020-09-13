module Lib where

import AppState
import Checking
import Config
import Control.Concurrent
import Control.Monad
import qualified Data.Map as Map
import Data.Maybe (fromJust, fromMaybe)
import StateLogger
import System.Console.GetOpt
import System.Environment
import System.IO
import System.Process

data Options = Options
  { optConfigFilePath :: String
  }
  deriving (Show)

defaultOptions =
  Options
    { optConfigFilePath = "./config.yml"
    }

options :: [OptDescr (Options -> Options)]
options =
  [ Option ['c'] ["config"] (ReqArg (\f opts -> opts {optConfigFilePath = f}) "config") "config file"
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
  config <- readConfig $ optConfigFilePath opts
  state <- newMVar AppState {userStates = Map.empty}
  -- putStrLn $ optStateFile opts
  -- let (Just val) = config
  forkIO $ stateLoggerLoop (stateFilePath config) state
  checkingLoop config state
