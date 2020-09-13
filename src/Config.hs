module Config where

import Control.Applicative
import Data.Text
import Data.Time
import Data.Yaml
import qualified Data.Yaml as Y

data MyConfig = MyConfig
  { commands :: Commands,
    stateFilePath :: String,
    users :: [User]
  }
  deriving (Eq, Show)

instance FromJSON MyConfig where
  parseJSON (Y.Object m) =
    MyConfig
      <$> m .: pack ("commands")
      <*> m .: pack ("stateFilePath")
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
      <$> m .: pack ("check")
      <*> m .: pack ("message")
      <*> m .: pack ("kill")
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
      <*> m .: pack ("timeLimit")
      <*> m .: pack ("noticePeriod")
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
