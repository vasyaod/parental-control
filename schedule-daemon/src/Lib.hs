module Lib where

import AppState
import Checking
import CliOpts
import Config
import Control.Concurrent
import Control.Monad
import qualified Data.Map as Map
import StateLogger
import System.Directory
import System.Environment
import System.FilePath
import System.IO
import System.Process

someFunc :: IO ()
someFunc = do
  args <- getArgs
  (opts, _) <- compilerOpts (args)
  config <- readConfig $ optConfigFilePath opts
  state <- newMVar AppState {userStates = Map.empty}
  -- putStrLn $ optStateFile opts
  -- let (Just val) = config
  createDirectoryIfMissing True (takeDirectory (stateFilePath config))
  forkIO $ stateLoggerLoop (stateFilePath config) state
  checkingLoop config state
