module StateLogger where

--(forever)
--(threadDelay)

import AppState
import Control.Applicative
import Control.Concurrent
import Control.Monad
import Control.Exception
import Control.Monad.IO.Class (MonadIO, liftIO)
--import System.IO
import qualified Data.Map as Map
import Data.Aeson
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy as B
import Data.Text
import Data.Time

--loadState :: String -> IO (AppState)
--loadState stateFile = do
--  x <- try (liftIO (eitherDecodeFileStrict stateFile >>= either fail return))
--  fromRight (return AppState {userStates = Map.empty}) x
--  x1 <- case x of
--    Left e ->
--      return AppState {userStates = Map.empty}
--    Right state ->
--      return state
--  return x1

loadState :: String -> IO (AppState)
loadState stateFile = do
  x <- try (liftIO (eitherDecodeFileStrict stateFile >>= either fail return)) :: IO (Either IOException AppState)
  case x of
    Left _ ->
      return $ AppState {userStates = Map.empty}
    Right state ->
      return state

stateLoggerLoop :: String -> MVar AppState -> IO ()
stateLoggerLoop stateFile state = forever $ do
  st <- readMVar state
  --  let str = Map.foldlWithKey (\acc k a -> acc ++ (k ++ ":" ++(show (minuteCount a)) ++ "\n")) "" (userStates st)
  B.writeFile stateFile (encodePretty st)
  threadDelay (1 * 1000 * 1000)
