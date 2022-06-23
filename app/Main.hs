module Main where

import Control.Monad (foldM)
import Control.Monad.Trans.Maybe ()
import Realm (addInstallAbbr, addToPath, readPackageJson)
import Soothsayer ((***))
import System.Directory (doesPathExist, getCurrentDirectory)
import System.Environment (getArgs, getEnv, setEnv)
import System.FilePath (takeDirectory)

searchPath :: FilePath -> [FilePath]
searchPath path = if length path == 1 then ["/"] else path : searchPath (takeDirectory path)

type PackageType = String

nonNpmDir :: PackageType
nonNpmDir = ""

getPackageType :: FilePath -> PackageType -> IO PackageType
getPackageType path foundPackageType = do
  found <- doesPathExist $ path ++ "/package.json"
  isYarn <- doesPathExist $ path ++ "/yarn.lock"
  isPnpm <- doesPathExist $ path ++ "/pnpm-lock.yaml"
  let npmPackage
        | found && isYarn = "yarn" :: PackageType
        | found && isPnpm = "pnpm" :: PackageType
        | otherwise = nonNpmDir
  pure $ if foundPackageType == nonNpmDir then npmPackage else foundPackageType

main :: IO ()
main = do
  cwd <- getCurrentDirectory
  args <- getArgs
  let searchPaths = searchPath cwd
  packageType <- foldM (flip getPackageType) nonNpmDir searchPaths
  path <- getEnv "PATH"
  let shell = head args
  let isNode = packageType /= nonNpmDir
  packageScripts <- if isNode then readPackageJson shell packageType else pure []
  if isNode then putStrLn $ unlines [addToPath shell cwd, addInstallAbbr shell packageType, unlines packageScripts] else pure ()
