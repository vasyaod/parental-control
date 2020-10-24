{-# LANGUAGE OverloadedStrings #-}
module Lib where

import Checking
import CliOpts
import Config
import Control.Concurrent
import Control.Monad
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
  let stateFile = (statePath config) ++ "/state"
  s <- loadState stateFile
  state <- newMVar s
  -- putStrLn $ optStateFile opts
  -- let (Just val) = config
  createDirectoryIfMissing True (statePath config)
  conn <- open ((statePath config) ++ "/log.db")               -- Open data base file
  execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
  forkIO $ stateLoggerLoop stateFile state
  checkingLoop config conn state
