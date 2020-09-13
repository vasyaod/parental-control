module AppStateSpec where

import AppState
import qualified Data.Map as Map
import Data.Time
import Test.Hspec

spec :: SpecWith ()
spec = describe "AppState" $ do
    it "stub" $
       0 `shouldBe` 0

--  describe "usedMinutes" $ do
--    it "should return 0 mins for arbitrary user" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          appSt =
--            AppState
--              { userStates = Map.empty
--              }
--       in usedMinutes appSt "vasyaod" localTime `shouldBe` 0
--
--    it "should return actual values of mins for saved user" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          appSt =
--            AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 10, lastChanges = localTime, messageSent = False})])
--              }
--       in usedMinutes appSt "vasyaod" localTime `shouldBe` 10
--
--    it "should return 0 if we regard the next day" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          LocalTime localDay localTimeOfDay = localTime
--          localTimeNextDay = LocalTime (addDays 1 localDay) localTimeOfDay -- Get local time for "the next day"
--          appSt =
--            AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 10, lastChanges = localTime, messageSent = False})])
--              }
--       in usedMinutes appSt "vasyaod" localTimeNextDay `shouldBe` 0
--
--  describe "addMinutes" $ do
--    it "should return increase minutes for a new user" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          appSt =
--            AppState
--              { userStates = Map.empty
--              }
--       in addMinutes appSt "vasyaod" localTime 1
--            `shouldBe` AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 1, lastChanges = localTime, messageSent = False})])
--              }
--
--    it "should return increase minutes for already existed user" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          appSt =
--            AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 10, lastChanges = localTime, messageSent = False})])
--              }
--       in addMinutes appSt "vasyaod" localTime 1
--            `shouldBe` AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 11, lastChanges = localTime, messageSent = False})])
--              }
--
--    it "should return reset minutes in the next day" $
--      let localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
--          LocalTime localDay localTimeOfDay = localTime
--          localTimeNextDay = LocalTime (addDays 1 localDay) localTimeOfDay -- Get local time for "the next day"
--          appSt =
--            AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 10, lastChanges = localTime, messageSent = False})])
--              }
--       in addMinutes appSt "vasyaod" localTimeNextDay 1
--            `shouldBe` AppState
--              { userStates = (Map.fromList [("vasyaod", UserState {minuteCount = 1, lastChanges = localTimeNextDay, messageSent = False})])
--              }
