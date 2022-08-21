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

-- Periodically reload schedule from a file and 
dispatchUsersConfig :: String -> ([User] -> IO ()) -> Maybe UsersConfig -> Maybe ThreadId -> IO ()
dispatchUsersConfig usersConfigPath userDispatcherFactory oldUsersConfig oldThreadId = do
  usersConfig <- readUsersConfig usersConfigPath
  threadIdMaybe <-
    if oldUsersConfig == Just usersConfig then
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
  
  threadDelay (1 * 1000 * 1000)
  dispatchUsersConfig usersConfigPath userDispatcherFactory (Just usersConfig) threadIdMaybe
