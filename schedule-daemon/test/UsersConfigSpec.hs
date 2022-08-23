module UsersConfigSpec where

import UsersConfig
import Config
import Test.Hspec

spec :: SpecWith ()
spec = describe "UsersConfig" $ do
    it "should be read from file" $
      do
        config <- readUsersConfig' "./users-config.yml"
        let userConf = head (users config)
        return (login userConf)
        `shouldReturn` "dummy-user"