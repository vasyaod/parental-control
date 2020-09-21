{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import AppState
import CliOpts
import Config
import Control.Monad.Except
import Control.Monad.Reader
import Data.Aeson
import qualified Data.Aeson.Parser
import Data.Aeson.Types
import Data.ByteString (ByteString)
import Data.List
import qualified Data.Map as Map
import Data.Maybe
import Data.Time
import Data.Time.Calendar
import Database.SQLite.Simple
import DbLog
import GHC.Generics
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.Types.SourceT (source)
import System.Directory
import System.Environment

type UserAPI1 =
  "state" :> Get '[JSON] AppState
    :<|> "stats" :> Get '[JSON] [LogRaw]
    :<|> Raw

server1 :: Connection -> MyConfig -> Server UserAPI1
server1 dbConn config = state :<|> stats :<|> static
  where
    state = do
      contentMaybe <- liftIO $ decodeFileStrict ((statePath config) ++ "/state")
      case contentMaybe of
        Nothing -> return AppState {userStates = Map.empty}
        Just x -> return x

    stats = do
      now <- liftIO $ getCurrentTime
      timezone <- liftIO $ getCurrentTimeZone
      let localTime = utcToLocalTime timezone now
      liftIO $ statForYearForAllUsers dbConn localTime

    static = serveDirectoryFileServer (httpStaticPath config)

userAPI :: Proxy UserAPI1
userAPI = Proxy

-- 'serve' comes from servant and hands you a WAI Application,
-- which you can think of as an "abstract" web application,
-- not yet a webserver.
app :: Connection -> MyConfig -> Application
app dbConn config = serve userAPI (server1 dbConn config)

main :: IO ()
main = do
  args <- getArgs
  (opts, _) <- compilerOpts (args)
  config <- readConfig $ optConfigFilePath opts
  dbConn <- open ((statePath config) ++ "/log.db")
  execute_ dbConn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
  let settings = setPort (httpPort config) $ setHost "127.0.0.1" defaultSettings
  runSettings settings (app dbConn config)
