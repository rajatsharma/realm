module Main where

import Realm
import Soothsayer ((***))
import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getArgs, getEnv, setEnv)

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
  packageScripts <- if isNode then readPackageJson shell packageManager else pure []
  if isNode then putStrLn $ unlines [addToPath shell cwd, addInstallAbbr shell packageManager, unlines packageScripts] else pure ()
