{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module DbLog where

import Control.Applicative
import Control.Concurrent
import Control.Monad
import Data.Time
import Database.SQLite.Simple
import GHC.Generics
import Data.Aeson

data LogRaw = LogRaw
  { date :: String,
    user :: String,
    minutes :: Int
  }
  deriving (Generic, Eq, Show)

instance ToJSON LogRaw where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON LogRaw

-- | writes a row in DB log
logToDb :: Connection -> LocalTime -> String-> IO ()
logToDb conn localTime userName = do
  let tm = localTimeToUTC utc localTime
  execute conn "INSERT INTO log (tm, user) VALUES (?, ?)" (tm, userName)

-- | reads and agregate logs for one year per a specified user from SQLite databese
statForYearByUser :: Connection -> LocalTime -> String-> IO [LogRaw]
statForYearByUser conn localTime userName = do
  let LocalTime localDay localTimeOfDay = localTime
      localTimeNextDay = LocalTime (addDays (0 - 365) localDay) localTimeOfDay -- Get local time for "the next day"
      tm = localTimeToUTC utc localTimeNextDay
  res <- query conn "SELECT date(tm) AS d, user, COUNT(*) as minutes FROM log WHERE user = ? and tm > ? GROUP BY d" (userName, tm) :: IO [(String, String, Int)]
  let x = map (\(d, u, c) -> LogRaw d u c) res
  return x

-- | reads and agregate logs for one year for all user from SQLite databese
statForYearForAllUsers :: Connection -> LocalTime -> IO [LogRaw]
statForYearForAllUsers conn localTime = do
  let LocalTime localDay localTimeOfDay = localTime
      localTimeNextDay = LocalTime (addDays (0 - 365) localDay) localTimeOfDay -- Get local time for "the next day"
      tm = localTimeToUTC utc localTimeNextDay
  res <- query conn "SELECT date(tm) AS d, user, COUNT(*) as minutes FROM log WHERE tm > ? GROUP BY d, user ORDER BY user" (Only tm) :: IO [(String, String, Int)]
  let x = map (\(d, u, c) -> LogRaw d u c) res
  return x

