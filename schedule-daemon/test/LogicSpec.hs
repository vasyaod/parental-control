module LogicSpec where

import AppState
import Checking
import Config
import Control.Concurrent
import Control.Monad.State
import qualified Data.Map as Map
import Data.Time
import Test.Hspec

commonSchedule =
  Schedule
    { mon =
        [Range {start = start, end = end}],
      tue =
        [Range {start = start, end = end}],
      wed =
        [Range {start = start, end = end}],
      thu =
        [Range {start = start, end = end}],
      fri =
        [Range {start = start, end = end}],
      sat =
        [Range {start = start, end = end}],
      sun =
        [Range {start = start, end = end}]
    }
  where
    start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00"
    end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"

userConf =
  User
    { login = "vasyaod",
      timeLimit = 10,
      noticePeriod = 5,
      schedule = commonSchedule
    }

spec :: SpecWith ()
spec = describe "Primary logic" $ do
  describe "checkTime" $ do
    it "should return True if time fits for range" $
      let time = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30" -- Test time
          range =
            Range
              { start = parseTimeOrError True defaultTimeLocale "%H:%M" "10:00",
                end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
              }
       in checkTime time range `shouldBe` True

    it "should return False if time doesn't fit for range" $
      let time = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30" -- Test time
          range =
            Range
              { start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00",
                end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
              }
       in checkTime time range `shouldBe` False

  describe "checkTimes" $ do
    it "should return True if time fits for ranges" $
      let time = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30" -- Test time
          range =
            Range
              { start = parseTimeOrError True defaultTimeLocale "%H:%M" "10:00",
                end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
              }
       in checkTimes time [range] `shouldBe` True

    it "should return False if time doesn't fit for ranges" $
      let time = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30" -- Test time
          range =
            Range
              { start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00",
                end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
              }
       in checkTimes time [range] `shouldBe` False

  describe "checkUser" $ do
    it "should increase state if it happens in schedule" $
      do
        let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
            checkFn = \x -> return True
            killFn = \x -> return ()
            messageFn = \x -> return ()
            logFn = \x -> return ()
            defUserState = defaultUserState localTime
        newState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConf) defUserState
        return newState
        `shouldReturn` UserState
          { minuteCount = 1,
            lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15",
            messageSent = False
          }

    it "should not increase state if it  doesn't happen in schedule" $
      do
        let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:15" -- The time is no it the range
            checkFn = \x -> return True
            killFn = \x -> return ()
            messageFn = \x -> return ()
            logFn = \x -> return ()
            defUserState = defaultUserState localTime
        newState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConf) defUserState
        return newState
        `shouldReturn` UserState
          { minuteCount = 0,
            lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "10:15",
            messageSent = False
          }

    it "should not increase state if user is not in a system" $
      do
        let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15" -- The time is no it the range
            checkFn = \x -> return False -- User not in a system
            killFn = \x -> return ()
            messageFn = \x -> return ()
            logFn = \x -> return ()
            defUserState = defaultUserState localTime
        newState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConf) defUserState
        return newState
        `shouldReturn` UserState
          { minuteCount = 0,
            lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15",
            messageSent = False
          }

    it "should send message before 5 minutes of the schedule end" $
      do
        let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:26" -- Time which is closed to the end of schedule
            checkFn = \x -> return True
            killFn = \x -> return ()
            messageFn = \x -> return ()
            logFn = \x -> return ()
            defUserState = defaultUserState localTime
        newState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConf) defUserState
        return newState
        `shouldReturn` UserState
          { minuteCount = 1,
            lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "11:26",
            messageSent = True
          }

    it "should send message before 5 minutes of the end of time limit" $
      do
        let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:10"
            checkFn = \x -> return True
            killFn = \x -> return ()
            messageFn = \x -> return ()
            logFn = \x -> return ()
            defUserState = (defaultUserState localTime) {minuteCount = 6}
        newState <- execStateT (checkUser localTime checkFn killFn messageFn logFn userConf) defUserState
        return newState
        `shouldReturn` UserState
          { minuteCount = 7,
            lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "11:10",
            messageSent = True
          }
