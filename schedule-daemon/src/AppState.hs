{-# LANGUAGE DeriveGeneric #-}
module AppState where

import Control.Applicative
import qualified Data.Map as Map
import Data.Time.LocalTime
import GHC.Generics
import Data.Aeson

data UserState = UserState
  { minuteCount :: Int,
    lastChanges :: LocalTime,
    messageSent :: Bool
  }
  deriving (Generic, Eq, Show)

instance ToJSON UserState where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON UserState

data AppState = AppState
  { userStates :: Map.Map String UserState
  }
  deriving (Generic, Eq, Show)

instance ToJSON AppState where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON AppState

defaultUserState :: LocalTime -> UserState
defaultUserState localTime = UserState {minuteCount = 0, lastChanges = localTime, messageSent = False}

-- Retuns used minutes for a user depend on localtime
userStateOrDefault :: AppState -> String -> LocalTime-> UserState
userStateOrDefault state userName localTime =
  if localDay (lastChanges userState) == localDay localTime
    then userState
    else defaultUserStateWithTime
  where
    defaultUserStateWithTime = defaultUserState localTime
    userState = Map.findWithDefault defaultUserStateWithTime userName (userStates state)

-- Retuns used minutes for a user depend on localtime
usedMinutes :: UserState -> LocalTime -> Int
usedMinutes userState localTime =
  if localDay (lastChanges userState) == localDay localTime
    then minuteCount userState
    else 0

-- Increase minute time for user state
addMinutes :: LocalTime -> Int -> UserState -> UserState
addMinutes localTime delta userState =
  userState {minuteCount = um + delta, lastChanges = localTime}
  where
    um = usedMinutes userState localTime