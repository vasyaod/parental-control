module StateLogger where

--(forever)
--(threadDelay)

import AppState
import Control.Applicative
import Control.Monad
import Data.Text
import Data.Time
import Control.Concurrent
--import System.IO
import Data.Aeson
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy as B

stateLoggerLoop :: String -> MVar AppState -> IO ()
stateLoggerLoop stateFilePath state = forever $ do
  st <- readMVar state
--  let str = Map.foldlWithKey (\acc k a -> acc ++ (k ++ ":" ++(show (minuteCount a)) ++ "\n")) "" (userStates st)
  B.writeFile stateFilePath (encodePretty st)
  threadDelay (1 * 1000 * 1000)
