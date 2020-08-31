module LogicSpec where

import AppState
import Config
import Checking
import Control.Concurrent
import qualified Data.Map as Map
import Data.Time
import Test.Hspec

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

  --  describe "checkSchedule" $ do
  --    it "should return True if time fits for schedule" $
  --      do
  --        config <- readConfig
  --        let time = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30" -- Test time
  --        return $ checkSchedule config time
  --        `shouldReturn` True
  --
  --    it "should return False if time fits for schedule" $
  --      do
  --        config <- readConfig
  --        let time = parseTimeOrError True defaultTimeLocale "%H:%M" "18:30" -- Test time
  --        return $ checkSchedule config time
  --        `shouldReturn` False

  --    it "returns a positive number when given a negative input" $
  --      -1 `shouldBe` -1
  describe "checkUser" $ do
    it "should increase state if it happens in schedule" $
      do
        let start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00"
            end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
            schedule =
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
            userConf = User {login = "vasyaod", timeLimit = 10, schedule = schedule}
            localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"
            checkFn = \x -> return True
            killFn = \x -> return ()
        --    appSt = AppState {userStates = Map.empty}
        state <- newMVar AppState {userStates = Map.empty}
        checkUser localTime state checkFn killFn userConf
        newState <- readMVar state
        return newState
        `shouldReturn` AppState {userStates = Map.fromList [("vasyaod",UserState {minuteCount = 1, lastChanges = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"})]}

    it "should not increase state if it  doesn't happen in schedule" $
      do
        let start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00"
            end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
            schedule =
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
            userConf = User {login = "vasyaod", timeLimit = 10, schedule = schedule}
            localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:15"      -- The time is no it the range
            checkFn = \x -> return True
            killFn = \x -> return ()
        --    appSt = AppState {userStates = Map.empty}
        state <- newMVar AppState {userStates = Map.empty}
        checkUser localTime state checkFn killFn userConf
        newState <- readMVar state
        return newState
        `shouldReturn` AppState {userStates = Map.empty}

    it "should not increase state if user is not in a system" $
      do
        let start = parseTimeOrError True defaultTimeLocale "%H:%M" "11:00"
            end = parseTimeOrError True defaultTimeLocale "%H:%M" "11:30"
            schedule =
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
            userConf = User {login = "vasyaod", timeLimit = 10, schedule = schedule}
            localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "11:15"      -- The time is no it the range
            checkFn = \x -> return False                                             -- User not in a system
            killFn = \x -> return ()
        --    appSt = AppState {userStates = Map.empty}
        state <- newMVar AppState {userStates = Map.empty}
        checkUser localTime state checkFn killFn userConf
        newState <- readMVar state
        return newState
        `shouldReturn` AppState {userStates = Map.empty}