{-# LANGUAGE OverloadedStrings #-}

module DbLogSpec where

import Checking
import Data.Time
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.LocalTime
import Database.SQLite.Simple
import DbLog
import Test.Hspec

spec :: SpecWith ()
spec = describe "Db log" $ do
  it "should increase and return time activity" $
    do
      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime "vasyaod"
      res <- statForYearByUser conn localTime "vasyaod"
      return res
        `shouldReturn` [LogRaw {date = "1970-01-01", user = "vasyaod", minutes = 1}]

  it "should increase and return time activity, test for two events" $
    do
      let localTime1 = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
          localTime2 = parseTimeOrError True defaultTimeLocale "%H:%M" "11:18"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime1 "vasyaod"
      logToDb conn localTime2 "vasyaod"
      res <- statForYearByUser conn localTime1 "vasyaod"
      return res
        `shouldReturn` [LogRaw {date = "1970-01-01", user = "vasyaod", minutes = 2}]

  it "should increase and return time activity, test for two events in two different days" $
    do
      let localTime1 = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
          LocalTime localDay localTimeOfDay = localTime1
          localTime2 = LocalTime (addDays 1 localDay) localTimeOfDay -- Get local time for "the next day"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime1 "vasyaod"
      logToDb conn localTime2 "vasyaod"
      res <- statForYearByUser conn localTime1 "vasyaod"
      return res
        `shouldReturn` [ LogRaw {date = "1970-01-01", user = "vasyaod", minutes = 1},
                         LogRaw {date = "1970-01-02", user = "vasyaod", minutes = 1}
                       ]

  it "should increase and return time activity, test for two events in two different users, 1" $
    do
      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime "vasyaod"
      logToDb conn localTime "sunny"
      res <- statForYearByUser conn localTime "vasyaod"
      return res
        `shouldReturn` [LogRaw {date = "1970-01-01", user = "vasyaod", minutes = 1}]

  it "should increase and return time activity, test for two events in two different users, 2" $
    do
      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime "vasyaod"
      logToDb conn localTime "sunny"
      logToDb conn localTime "sunny"
      res <- statForYearByUser conn localTime "sunny"
      return res
        `shouldReturn` [LogRaw {date = "1970-01-01", user = "sunny", minutes = 2}]

  it "should increase and return time activity, test for two events in two different users, 3" $
    do
      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
      conn <- open ":memory:"
      execute_ conn "CREATE TABLE IF NOT EXISTS log (tm TIMESTAMP, user TEXT)"
      logToDb conn localTime "vasyaod"
      logToDb conn localTime "sunny"
      logToDb conn localTime "sunny"
      res <- statForYearForAllUsers conn localTime
      return res
        `shouldReturn` [ LogRaw {date = "1970-01-01", user = "sunny", minutes = 2},
                         LogRaw {date = "1970-01-01", user = "vasyaod", minutes = 1}
                       ]
