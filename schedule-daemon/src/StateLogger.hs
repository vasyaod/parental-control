module StateLogger where

--(forever)
--(threadDelay)

import AppState
import Control.Applicative
import Control.Concurrent
import Control.Monad
--import System.IO
import Data.Aeson
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy as B
import Data.Text
import Data.Time

stateLoggerLoop :: String -> MVar AppState -> IO ()
stateLoggerLoop statePath state = forever $ do
  st <- readMVar state
  --  let str = Map.foldlWithKey (\acc k a -> acc ++ (k ++ ":" ++(show (minuteCount a)) ++ "\n")) "" (userStates st)
  B.writeFile (statePath ++ "/state") (encodePretty st)
  threadDelay (1 * 1000 * 1000)
