{-# LANGUAGE OverloadedStrings #-}

module WindowsHomeCommand where

import Config
import Exec

import System.Process
import System.Exit
import System.IO
import Text.Format
import Text.Printf
import Hledger.Utils.String
import Data.List

-- Thanks to https://github.com/brummbrum
-- and PR https://github.com/vasyaod/parental-control/issues/4
--
-- The next command returns list of authorized in the system
--  > wmic COMPUTERSYSTEM GET USERNAME
--
-- the command returns
--   UserName
--   nellie-book\yasha

-- The next command allows to log out a user
--  > shutdown /l

-- The following command allows to send a message to user
--  > msg vasil :10 "Test"

runKillCommand :: Exec m => Commands -> String -> m ()
runKillCommand commands userName = do
  let command = format (kill commands) [userName]
  let args = words' command
  (errCode1, stdout1, stderr1) <- exec (head args) (tail args)

  loggg (printf "User %s has been killed" userName)
  return ()

runMessageCommand :: Exec m => Commands -> String -> m ()
runMessageCommand commands userName = do
  let command = format (message commands) [userName]
  let args = words' command
  (errCode1, stdout1, stderr1) <- exec (head args) (tail args)
  loggg (printf "Message command for user %s has been executed" userName)
  return ()

runCheckCommand :: Exec m => String -> m Bool
runCheckCommand userName = do
  (errCode1, stdout1, stderr1) <- exec "wmic" ["COMPUTERSYSTEM", "GET", "USERNAME"]
  let filteredLines = filter (\line -> isInfixOf userName line) (lines stdout1)
  return $ (length filteredLines) > 0
