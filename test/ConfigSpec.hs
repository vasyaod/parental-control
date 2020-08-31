module ConfigSpec where

import Config
import Data.Time
import Test.Hspec

spec :: SpecWith ()
spec = describe "Config" $ do
    it "should be read from file" $
      do
        config <- readConfig "./config.yml"
        -- let (Just val) = config;
        return (isDebug config)
        `shouldReturn` True