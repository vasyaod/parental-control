module StateLoggerSpec where

import StateLogger
import AppState
import Data.Time
import Test.Hspec

spec :: SpecWith ()
spec = describe "StateLogger" $ do
    it "should load previous state of app" $
      do
        state <- loadState "./state.json"
        return $ length (userStates state)
        `shouldReturn` 2
    it "should load empty state if file is not found" $
      do
        state <- loadState "./state1111111.json"
        return $ length (userStates state)
        `shouldReturn` 0