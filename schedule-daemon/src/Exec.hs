module Exec where

import System.Process
import System.Exit
import System.IO

class Monad m => Exec m where
  exec :: FilePath -> [String] -> m (ExitCode, String, String)
  loggg :: String -> m ()

