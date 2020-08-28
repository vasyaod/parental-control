module AppStateSpec where

import AppState
import qualified Data.Map as Map
import Test.Hspec
import Data.Time

spec :: SpecWith ()
spec =
  describe "usedMinutes" $ do
    it "should return 0 mins for arbitrary user" $
      usedMinutes appSt "vasyaod" localTime `shouldBe` 0
  where
    localTime = parseTimeOrError True defaultTimeLocale "%H:%M" "10:30"
    appSt =
      AppState
        { userStates = Map.empty
        }
