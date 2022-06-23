{-# LANGUAGE OverloadedStrings #-}

module Realm where

import Data.Aeson
import Data.Aeson.Key (toString)
import Data.Aeson.KeyMap (KeyMap, empty, keys)
import Data.Aeson.Types (Parser, parseMaybe)
import Data.Maybe (fromMaybe)
import Data.String (IsString (fromString))
import Data.Text (Text)
import Soothsayer ((***))
import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getArgs, getEnv, setEnv)

scriptParser :: Value -> Parser (KeyMap Value)
scriptParser = withObject "Package" $ \obj -> do
  obj .: "scripts"

addToPath :: String -> String -> String
addToPath "fish" cwd = "set -g fish_user_paths {0}/node_modules/.bin $fish_user_paths" *** [cwd]
addToPath _ cwd = "path+={0}/node_modules/.bin" *** [cwd]

addInstallAbbr :: String -> String -> String
addInstallAbbr "fish" packageManager = "abbr -a -g ins {0} install" *** [packageManager]
addInstallAbbr _ _ = ""

addScriptAbbr :: String -> String -> Key -> String
addScriptAbbr "fish" packageManager script = "abbr -a -g {0} {1} run {2}" *** [scriptKey, packageManager, scriptKey]
  where
    scriptKey = toString script
addScriptAbbr _ _ _ = ""

getScriptKeys :: Maybe (KeyMap Value) -> [Key]
getScriptKeys scripts = keys $ fromMaybe empty scripts

readPackageJson :: String -> String -> IO [String]
readPackageJson shell packageManager = do
  cwd <- getCurrentDirectory
  packageJsonFileContents <- readFile $ cwd ++ "/package.json"
  let contents = decode $ fromString packageJsonFileContents :: Maybe Value
  let scripts = contents >>= parseMaybe scriptParser
  pure $ addScriptAbbr shell packageManager `fmap` getScriptKeys scripts
