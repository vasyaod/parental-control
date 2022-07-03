{-# LANGUAGE FlexibleInstances #-}

module WindowsHomeCommandSpec where

--import StateLogger
import Exec
import Config

import Data.Time
import Test.Hspec
import WindowsHomeCommand
import System.Exit
import Control.Monad.State.Lazy

get3rd (_,_,x) = x
get2sd (_,x,_) = x
get1sd (x,_,_) = x

-- We need a stub for Exec class as 
instance Exec (State ([(ExitCode, String, String)], [String], [String])) where
  exec command args = state $ \s -> (head (get1sd s), (tail (get1sd s), (get2sd s) ++ [unwords ([command] ++ args)], (get3rd s)))
  loggg str = state $ \s -> ((), ((get1sd s), (get2sd s), (get3rd s) ++ [str]))

x = "UserName \n\
    \ nellie-book\\yasha \n"

spec :: SpecWith ()
spec = describe "WindowsHomeCommand" $ do
    let command = Commands  {
      message = "PowerShell -Command \"Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('User will be killed in a few minutes')\"",
      kill = "shutdown /s /t 60 /c \"Time is Up!\""
    }

    it "should kill user by name" $
      (execState (WindowsHomeCommand.runKillCommand command "yasha") ([(ExitSuccess, x, ""), (ExitSuccess, "", "")], [""], [""]))
--        `shouldBe` ([],["", "query user yasha", "logoff 5"],["", "User found in system with session ID 5"])
        `shouldBe` ([(ExitSuccess,"","")],["","shutdown /s /t 60 /c Time is Up!"],["", "User yasha has been killed"])

    it "should check existing of user by name" $
      (runState (WindowsHomeCommand.runCheckCommand("yasha")) ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` (True, ([],["", "wmic COMPUTERSYSTEM GET USERNAME"],[""]))

    it "should check existing of user by name (for wrong user)" $
      (runState (WindowsHomeCommand.runCheckCommand("yasha1")) ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` (False, ([],["", "wmic COMPUTERSYSTEM GET USERNAME"],[""]))

    it "should send warning messages to a user" $
      (runState (WindowsHomeCommand.runMessageCommand command "yasha") ([(ExitSuccess, x, "")], [""], [""]))
        `shouldBe` ((), ([],["", "PowerShell -Command Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('User will be killed in a few minutes')"],["", "Message command for user yasha has been executed"]))