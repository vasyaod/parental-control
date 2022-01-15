module Config where

import Control.Applicative
import qualified Data.HashMap.Strict as HM
import Data.Maybe (fromMaybe, fromJust)
import Data.Text
import Data.Time
import Data.Yaml
import qualified Data.Yaml as Y

data MyConfig = MyConfig
  { statePath :: String,
    httpEnable :: Bool,
    httpPort :: Int,
    httpInterface :: String,
    httpStaticPath :: String,
    users :: [User]
  }
  deriving (Eq, Show)

instance FromJSON MyConfig where
  parseJSON (Y.Object m) =
    MyConfig
      <$> m .:? pack ("statePath") .!= "/var/lib/parental-control"
      <*> m .:? pack ("httpEnable") .!= True
      <*> m .:? pack ("httpPort") .!= 8090
      <*> m .:? pack ("httpInterface") .!= "127.0.0.1"
      <*> m .:? pack ("httpStaticPath") .!= "/usr/share/parental-control"
      <*> m .: pack ("users")
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
