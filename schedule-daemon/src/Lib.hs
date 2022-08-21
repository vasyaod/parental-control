{-# LANGUAGE OverloadedStrings #-}
module Lib where

import UsersDispatcher
import UsersConfigDispatcher
import UsersConfig
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
import Data.Maybe (Maybe(Nothing))

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

  -- Run state logger in another thread
  forkIO $ stateLoggerLoop stateFile state
  
  -- If schedule in a separated file we'll run another dispatcher for to reloading of that
  let userDispatcherFactory = dispatchUsers config conn state  
  let refreshPeriod = usersConfigRefreshPeriod config
  case usersConfigPath config of 
    Just path  -> dispatchUsersConfig path refreshPeriod userDispatcherFactory Nothing Nothing
    Nothing    -> dispatchUsersConfig (optConfigFilePath opts) refreshPeriod userDispatcherFactory Nothing Nothing

