module Main where

import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getEnv, setEnv)

main :: IO ()
main = do
  cwd <- getCurrentDirectory
  isNode <- doesPathExist $ cwd ++ "/package.json"
  path <- getEnv "PATH"
  if isNode
    then putStrLn $ "set -g fish_user_paths " ++ cwd ++ "/node_modules/.bin $fish_user_paths"
    else pure ()
