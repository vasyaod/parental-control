module AppState where

import Control.Applicative
import qualified Data.Map as Map
import Data.Time.LocalTime

data UserState = UserState
  { minuteCount :: Int,
    lastChanges :: LocalTime
  }
  deriving (Eq, Show)

data AppState = AppState
  { userStates :: Map.Map String UserState
  }
  deriving (Eq, Show)

-- Retuns used minutes for a user depend on localtime
usedMinutes :: AppState -> String -> LocalTime -> Int
usedMinutes state userName localTime =
  minuteCount
    ( if localDay (lastChanges userState) == localDay localTime
        then userState
        else defaultUserState
    )
  where
    defaultUserState = UserState {minuteCount = 0, lastChanges = localTime}
    userState = Map.findWithDefault defaultUserState userName (userStates state)

-- Increase minute time for user state
addMinutes :: AppState -> String -> LocalTime -> Int -> AppState
addMinutes state userName localTime delta =
  state {userStates = Map.insert userName newUserState (userStates state)}
  where
    defaultUserState = UserState {minuteCount = 0, lastChanges = localTime}
    userState = Map.findWithDefault defaultUserState userName (userStates state)
    newUserState =
      if localDay (lastChanges userState) == localDay localTime
        then UserState {minuteCount = (minuteCount userState) + delta, lastChanges = localTime}
        else UserState {minuteCount = delta, lastChanges = localTime}
