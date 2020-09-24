module Config where

import Control.Applicative
import qualified Data.HashMap.Strict as HM
import Data.Maybe (fromMaybe, fromJust)
import Data.Text
import Data.Time
import Data.Yaml
import qualified Data.Yaml as Y

data MyConfig = MyConfig
  { commands :: Commands,
    statePath :: String,
    httpPort :: Int,
    httpStaticPath :: String,
    users :: [User]
  }
  deriving (Eq, Show)

instance FromJSON MyConfig where
  parseJSON (Y.Object m) =
    MyConfig
      <$> m .:? pack ("commands") .!= fromJust (parseMaybe (\m -> parseJSON ((Object HM.empty) :: Value)) ())
      <*> m .:? pack ("statePath") .!= "/var/lib/parental-control"
      <*> m .:? pack ("httpPort") .!= 8090
      <*> m .:? pack ("httpStaticPath") .!= "/usr/share/parental-control"
      <*> m .: pack ("users")
  parseJSON x = fail ("not an object: " ++ show x)

data Commands = Commands
  { check :: String,
    message :: String,
    kill :: String
  }
  deriving (Eq, Show)

instance FromJSON Commands where
  parseJSON (Y.Object m) =
    Commands
      <$> m .:? pack ("check") .!= "who | grep {0} | [ $(wc -c) -ne 0 ]"
      <*> m .:? pack ("message") .!= "echo 'This is stub which is not sent a message anywhere'"
      <*> m .:? pack ("kill")  .!= "skill -KILL -u {0}"
  parseJSON x = fail ("not an object: " ++ show x)

data User = User
  { login :: String,
    timeLimit :: Int,
    noticePeriod :: Int,
    schedule :: Schedule
  }
  deriving (Eq, Show)

instance FromJSON User where
  parseJSON (Y.Object m) =
    User
      <$> m .: pack ("login")
      <*> m .:? pack ("timeLimit") .!= 1500
      <*> m .:? pack ("noticePeriod") .!= 5
      <*> m .: pack ("schedule")
  parseJSON x = fail ("not an object: " ++ show x)

data Schedule = Schedule
  { mon :: [Range],
    tue :: [Range],
    wed :: [Range],
    thu :: [Range],
    fri :: [Range],
    sat :: [Range],
    sun :: [Range]
  }
  deriving (Eq, Show)

instance FromJSON Schedule where
  parseJSON (Y.Object m) =
    Schedule
      <$> m .: pack ("mon")
      <*> m .: pack ("tue")
      <*> m .: pack ("wed")
      <*> m .: pack ("thu")
      <*> m .: pack ("fri")
      <*> m .: pack ("sat")
      <*> m .: pack ("sun")
  parseJSON x = fail ("not an object: " ++ show x)

data Range = Range
  { start :: TimeOfDay,
    end :: TimeOfDay
  }
  deriving (Eq, Show)

instance FromJSON Range where
  parseJSON (Y.Object m) =
    Range
      <$> m .: pack ("start")
      <*> m .: pack ("end")
  parseJSON x = fail ("not an object: " ++ show x)

readConfig :: String -> IO (MyConfig)
readConfig configFileName = decodeFileThrow configFileName
