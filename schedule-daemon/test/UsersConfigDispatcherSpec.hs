module UsersConfigDispatcherSpec where

import UsersConfig
import Config
import UsersConfigDispatcher
import Test.Hspec

spec :: SpecWith ()
spec = describe "UsersConfigDispatcher" $ do
  it "should be able to load config from local file" $
    do
      Right config <- readUsersConfig "file://./users-config.yml"
      let userConf = head (users config)
      return (login userConf)
      `shouldReturn` "dummy-user"

  it "should throw error if URL schema is not correct " $
    do
      Left config <- readUsersConfig "file1://./users-config.yml"
      return ()
      `shouldReturn` ()