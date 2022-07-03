{-# LANGUAGE FlexibleInstances #-}

module WindowsProCommandSpec where

--import StateLogger
import Exec
import Config

import Data.Time
import Test.Hspec
import WindowsProCommand
import System.Exit
import Control.Monad.State.Lazy

get3rd (_,_,x) = x
get2sd (_,x,_) = x
get1sd (x,_,_) = x

-- We need a stub for Exec class as 
instance Exec (State ([(ExitCode, String, String)], [String], [String])) where
  exec command args = state $ \s -> (head (get1sd s), (tail (get1sd s), (get2sd s) ++ [unwords ([command] ++ args)], (get3rd s)))
  loggg str = state $ \s -> ((), ((get1sd s), (get2sd s), (get3rd s) ++ [str]))

x = " USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME \n\
    \ dummy-user                                4  Active       7:29  12/31/2021 9:29 PM  \n\
    \ yasha                 console             5  Active       7:29  12/31/2021 9:29 PM  "

spec :: SpecWith ()
spec = describe "WindowsProCommand" $ do
    let command = Commands  {
      message = "msg {0} /11 \"User will be killed in a few minutes\"",
      kill = "logoff {0}"
    }

    it "should kill user by name" $
      (execState (WindowsProCommand.runKillCommand command "yasha") ([(ExitSuccess, x, ""), (ExitSuccess, "", "")], [""], [""]))
        `shouldBe` ([],["", "query user yasha", "logoff 5"],["", "User found in system with session ID 5", "User yasha has been killed"])


    it "should kill user by name, part2" $
      (execState (WindowsProCommand.runKillCommand command "dummy-user") ([(ExitSuccess, x, ""), (ExitSuccess, "", "")], [""], [""]))
        `shouldBe` ([],["", "query user dummy-user", "logoff 4"],["", "User found in system with session ID 4", "User dummy-user has been killed"])

    it "should not do any thing if user is not found" $
      (execState (WindowsProCommand.runKillCommand command "yasha1") ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` ([],["", "query user yasha1"],[""])

    it "should check existing of user by name" $
      (runState (WindowsProCommand.runCheckCommand("yasha")) ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` (True, ([],["", "query user yasha"],[""]))

    it "should check existing of user by name (for wrong user)" $
      (runState (WindowsProCommand.runCheckCommand("yasha1")) ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` (False, ([],["", "query user yasha1"],[""]))

    it "should send warning messages to a user" $
      (runState (WindowsProCommand.runMessageCommand command "yasha") ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` ((), ([],["", "msg yasha /11 User will be killed in a few minutes"],["", "Message command for user yasha has been executed"]))