module ConfigSpec where

import Config
import Data.Time
import Test.Hspec

spec :: SpecWith ()
spec = describe "Config" $ do
    it "should be read from file" $
      do
        config <- readConfig "./config.yml"
        putStrLn $ show config
--        let (Just val) = config;
        let userConf = head (users config)
        return (login userConf)
        `shouldReturn` "dummy-user"