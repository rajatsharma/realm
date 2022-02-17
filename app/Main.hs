module Main where

import Soothsayer ((***))
import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getArgs, getEnv, setEnv)

addToPath :: String -> String -> String
addToPath "fish" cwd = "set -g fish_user_paths {0}/node_modules/.bin $fish_user_paths" *** [cwd]
addToPath _ cwd = "path+={0}/node_modules/.bin" *** [cwd]

addInstallAbbr :: String -> String -> String
addInstallAbbr "fish" packageManager = "abbr -a -g ins {0} install" *** [packageManager]
addInstallAbbr _ _ = ""

main :: IO ()
main = do
  cwd <- getCurrentDirectory
  args <- getArgs
  isNode <- doesPathExist $ cwd ++ "/package.json"
  isYarn <- doesPathExist $ cwd ++ "/yarn.lock"
  isPnpm <- doesPathExist $ cwd ++ "/pnpm-lock.yaml"
  let packageManager
        | isYarn = "yarn"
        | isPnpm = "pnpm"
        | otherwise = "npm"
  path <- getEnv "PATH"
  let shell = head args
  if isNode then putStrLn $ unlines [addToPath shell cwd, addInstallAbbr shell packageManager] else pure ()
