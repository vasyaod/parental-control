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
import Data.Time.Calendar
import GHC.Generics
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.Types.SourceT (source)
import System.Directory
import System.Environment
import Prelude

type UserAPI1 =
  "state" :> Get '[JSON] AppState
    :<|> Raw

server1 :: MyConfig -> Server UserAPI1
server1 config = state :<|> static
  where
    state = do
      contentMaybe <- liftIO $ decodeFileStrict ((statePath config) ++ "/state")
      case contentMaybe of
        Nothing -> return AppState {userStates = Map.empty}
        Just x -> return x
    static = serveDirectoryFileServer (httpStaticPath config)

userAPI :: Proxy UserAPI1
userAPI = Proxy

-- 'serve' comes from servant and hands you a WAI Application,
-- which you can think of as an "abstract" web application,
-- not yet a webserver.
app :: MyConfig -> Application
app config = serve userAPI (server1 config)

main :: IO ()
main = do
  args <- getArgs
  (opts, _) <- compilerOpts (args)
  config <- readConfig $ optConfigFilePath opts
  let settings = setPort (httpPort config) $ setHost "127.0.0.1" defaultSettings
  runSettings settings (app config)
