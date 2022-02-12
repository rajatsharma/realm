module Main where

import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getArgs, getEnv, setEnv)

addToPath :: String -> String -> IO ()
addToPath "fish" cwd = putStrLn $ "set -g fish_user_paths " ++ cwd ++ "/node_modules/.bin $fish_user_paths"
addToPath _ cwd = putStrLn $ "path+=" ++ cwd ++ "/node_modules/.bin"

main :: IO ()
main = do
  cwd <- getCurrentDirectory
  args <- getArgs
  isNode <- doesPathExist $ cwd ++ "/package.json"
  path <- getEnv "PATH"
  let shell = head args
  if isNode then addToPath shell cwd else pure ()
