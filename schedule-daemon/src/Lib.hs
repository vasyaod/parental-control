{-# LANGUAGE OverloadedStrings #-}
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
import Database.SQLite.Simple

someFunc :: IO ()
someFunc = do
  args <- getArgs
  (opts, _) <- compilerOpts (args)
  config <- readConfig $ optConfigFilePath opts
  state <- newMVar AppState {userStates = Map.empty}
  -- putStrLn $ optStateFile opts
  -- let (Just val) = config
  createDirectoryIfMissing True (statePath config)
  conn <- open ((statePath config) ++ "/log.db")               -- Open data base file
  execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
  forkIO $ stateLoggerLoop (statePath config) state
  checkingLoop config conn state
