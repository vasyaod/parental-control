{-# LANGUAGE PatternGuards #-}
{-# LANGUAGE OverloadedStrings #-}

module UsersConfigDispatcher where

--(forever)
--(threadDelay)

import Config
import UsersConfig

import Control.Applicative
import Control.Concurrent
import Control.Monad
import Control.Exception
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Yaml
import Data.Maybe (Maybe(Nothing))
import Data.List
import Network.Wreq
import Control.Lens

import qualified Data.ByteString.Lazy as LazyByteString

-- Read users configuration from local yaml file.
readYamlUsersConfigFile :: String -> IO (Either IOException UsersConfig)
readYamlUsersConfigFile path = do 
  r <- decodeFileEither path
  case r of
    Left err -> return (Left (userError (show err)))
    Right conf -> return (Right conf)

-- Read users configuration by http protocol.
readUsersConfigFromHttp :: String -> IO (Either IOException UsersConfig)
readUsersConfigFromHttp url = do
  r <- get url
  case decodeEither' (LazyByteString.toStrict (r ^. responseBody)) of
    Left err -> return (Left (userError (show err)))
    Right conf -> return (Right conf)

readUsersConfig :: String -> IO (Either IOException UsersConfig)
readUsersConfig uri | Just path <- stripPrefix "file://" uri = readYamlUsersConfigFile(path)
readUsersConfig uri | Just path <- stripPrefix "http://" uri = readUsersConfigFromHttp(path)
readUsersConfig uri | Just path <- stripPrefix "https://" uri = readUsersConfigFromHttp(path)
readUsersConfig uri = return $ Left $ userError "Unknown schema for the parameter 'usersConfigPath', it should be one of file://, http:// or https://"

-- Periodically reload schedule from a file and 
dispatchUsersConfig :: String -> Int-> ([User] -> IO ()) -> Maybe UsersConfig -> Maybe ThreadId -> IO ()
dispatchUsersConfig usersConfigPath refreshPeriod userDispatcherFactory oldUsersConfig oldThreadId = do
  -- get users config source
  usersConfigEither <- readUsersConfig usersConfigPath
  
  -- catch errors if they exist
  usersConfigMaybe <- case usersConfigEither of
    Right conf -> return $ Just conf
    Left error -> do
      putStrLn $ "Error during reading configuration file: " ++ (show error)
      return oldUsersConfig

  threadIdMaybe <-
    case usersConfigMaybe of
      Just usersConfig ->
        if oldUsersConfig == usersConfigMaybe then
          return oldThreadId
        else
          do 
            -- Kill previous dispatcher of users 
            case oldThreadId of
              Just tId -> killThread tId
              Nothing -> return ()
            -- And run a new dispatcher
            threadId <- forkIO $ userDispatcherFactory (UsersConfig.users usersConfig)
            putStrLn "New configuration has been loaded"
            return $ Just threadId
      Nothing -> return oldThreadId
  
  threadDelay (refreshPeriod * 1000 * 1000)
  dispatchUsersConfig usersConfigPath refreshPeriod userDispatcherFactory usersConfigMaybe threadIdMaybe
