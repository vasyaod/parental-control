{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

--(forever)
--(threadDelay)

module Main where

import AppState
import CliOpts
import Config
import Control.Concurrent
import Control.Monad
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
import Data.String

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
  if (httpEnable config) == True then do
    dbConn <- open ((statePath config) ++ "/log.db")
  --  execute_ dbConn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"     we can not create a table here because user is NOBODY and the user doesn't have access to db file
    let settings = setPort (httpPort config) $ setHost (fromString (httpInterface config)) defaultSettings
    runSettings settings (app dbConn config)
  else do
    putStrLn "Http interface is disabled"
    forever $ threadDelay (60 * 1000 * 1000)