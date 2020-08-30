module StateLogger where

--(forever)
--(threadDelay)

import AppState
import Config
import Control.Applicative
import Control.Monad
import qualified Data.Map as Map
import Data.Text
import Data.Time
import Control.Concurrent
import System.IO

stateLoggerLoop :: String -> MVar AppState -> IO ()
stateLoggerLoop stateFilePath state = forever $ do
  st <- readMVar state
  let str = Map.foldlWithKey (\acc k a -> acc ++ (k ++ ":" ++(show (minuteCount a)) ++ "\n")) "" (userStates st)
  writeFile stateFilePath str
  threadDelay (1 * 1000 * 1000)
