{-# LANGUAGE ScopedTypeVariables #-}

module Concepts.Files where
import System.IO
import Control.Monad
import System.Random


withF path mode f = do 
  handle <- openFile path mode
  f handle 
  hClose handle


f2 = withF "boran.txt" ReadMode process where 
  process handle = do 
    eof <- (hIsEOF handle) 
    when (not eof) $  do  line <-  hGetLine handle
                          hPutStrLn stdout line
                          process handle

fi = do clients <- fmap lines $ readFile "clients.db"
        is <- forM clients (\c -> do (winner :: Bool) <- randomIO
                                     (year   :: Int ) <- randomRIO (0, 3000)
                                     return (c, winner, year))
                                   
        writeFile "clientsWinners.db" $ concatMap show is