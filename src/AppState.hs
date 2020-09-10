module AppState where

import Control.Applicative
import qualified Data.Map as Map
import Data.Time.LocalTime

data UserState = UserState
  { minuteCount :: Int,
    lastChanges :: LocalTime,
    messageSent :: Bool
  }
  deriving (Eq, Show)

data AppState = AppState
  { userStates :: Map.Map String UserState
  }
  deriving (Eq, Show)

defaultUserState :: LocalTime -> UserState
defaultUserState localTime = UserState {minuteCount = 0, lastChanges = localTime, messageSent = False}

-- Retuns used minutes for a user depend on localtime
usedMinutes :: AppState -> String -> LocalTime -> Int
usedMinutes state userName localTime =
  if localDay (lastChanges userState) == localDay localTime
    then minuteCount userState
    else 0
  where
    defaultUserStateWithTime = defaultUserState localTime
    userState = Map.findWithDefault defaultUserStateWithTime userName (userStates state)

-- Increase minute time for user state
addMinutes :: AppState -> String -> LocalTime -> Int -> AppState
addMinutes state userName localTime delta =
  state {userStates = Map.insert userName newUserState (userStates state)}
  where
    defaultUserStateWithTime = defaultUserState localTime
    userState = Map.findWithDefault defaultUserStateWithTime userName (userStates state)
    um = usedMinutes state userName localTime
    newUserState = userState {minuteCount = um + delta, lastChanges = localTime, messageSent = False}
