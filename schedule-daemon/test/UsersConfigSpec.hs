module UsersConfigSpec where

import UsersConfig
import Config
import Data.Time
import Test.Hspec

spec :: SpecWith ()
spec = describe "UsersConfig" $ do
    it "should be read from file" $
      do
        config <- readUsersConfig "./users-config.yml"
        putStrLn $ show config
        let userConf = head (users config)
        return (login userConf)
        `shouldReturn` "dummy-user"