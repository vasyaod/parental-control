import qualified AppStateSpec
import Config
import Data.Time
import Lib
import Test.Hspec

main :: IO ()
main = hspec $ do
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

  describe "config" $ do
    it "should be read from file" $
      do
        config <- readConfig
        -- let (Just val) = config;
        return (isDebug config)
        `shouldReturn` True

  describe "AppState" AppStateSpec.spec

--      do x <- readConfig `shouldReturn` ()

--    it "returns zero when given zero" $
--      absolute 0 `shouldBe` 0
