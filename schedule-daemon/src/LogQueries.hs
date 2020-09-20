module LogQueries where

--(forever)
--(threadDelay)

import Control.Applicative
import Control.Concurrent
import Control.Monad
--import System.IO
import Data.Text
import Data.Time
import Database.SQLite.Simple

-- | writes a row in DB log
--logToDb :: Connection -> TimeZone -> LocalTime -> String-> IO ()
--logToDb conn timeZone localTime userName = do
--  let tm = localTimeToUTC timeZone localTime
--  execute conn "INSERT INTO test (str) VALUES (?)" (Only ("test string 2" :: String))
--  execute conn "INSERT INTO log (tm, user) VALUES (?, ?)" (tm, userName)
  --r <- query_ conn "SELECT * from log" :: IO [TestField]