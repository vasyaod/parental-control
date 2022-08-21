{-# LANGUAGE DeriveGeneric #-}
module UsersConfig where

import Control.Applicative
import qualified Data.Map as Map
import Data.Time.LocalTime
import GHC.Generics
import Data.Aeson
import Data.Yaml

import Config

data UsersConfig = UsersConfig
  { users :: [User]
  }
  deriving (Generic, Eq, Show)

instance FromJSON UsersConfig

readUsersConfig :: String -> IO (UsersConfig)
readUsersConfig = decodeFileThrow

