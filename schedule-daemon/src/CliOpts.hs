module CliOpts where

import AppState
import Checking
import Config
import Control.Concurrent
import Control.Monad
import qualified Data.Map as Map
import Data.Maybe (fromJust, fromMaybe)
import StateLogger
import System.Console.GetOpt
import System.Environment
import System.IO
import System.Process
import System.Directory
import System.FilePath

data Options = Options
  { optConfigFilePath :: String
  }
  deriving (Show)

defaultOptions =
  Options
    { optConfigFilePath = "./config.yml"
    }

options :: [OptDescr (Options -> Options)]
options =
  [ Option ['c'] ["config"] (ReqArg (\f opts -> opts {optConfigFilePath = f}) "config") "config file"
  ]

compilerOpts :: [String] -> IO (Options, [String])
compilerOpts argv =
  case getOpt Permute options argv of
    (o, n, []) -> return (foldl (flip id) defaultOptions o, n)
    (_, _, errs) -> ioError (userError (concat errs ++ usageInfo header options))
  where
    header = "Usage: ic [OPTION...] files..."
