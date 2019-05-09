{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_my_project (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\bin"
libdir     = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\lib\\x86_64-windows-ghc-8.2.2\\my-project-0.1.0.0-GK7tMR4fyPm6cMetXkZMs2-my-project"
dynlibdir  = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\lib\\x86_64-windows-ghc-8.2.2"
datadir    = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\share\\x86_64-windows-ghc-8.2.2\\my-project-0.1.0.0"
libexecdir = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\libexec\\x86_64-windows-ghc-8.2.2\\my-project-0.1.0.0"
sysconfdir = "C:\\Users\\hori\\Desktop\\haskell\\web\\my-project\\.stack-work\\install\\c1f464f3\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "my_project_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "my_project_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "my_project_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "my_project_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "my_project_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "my_project_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
