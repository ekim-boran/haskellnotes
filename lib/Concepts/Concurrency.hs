module Concepts.Concurrency where 

import Control.Concurrent
import Control.Monad
import System.IO 

forkIO' :: IO () -> IO ThreadId
forkIO' = forkIO
newMVar' :: a -> IO (MVar a)
newMVar' = newMVar
newEmptyMVar' :: IO (MVar a)
newEmptyMVar' = newEmptyMVar
takeMVar' :: MVar a -> IO a
takeMVar' = takeMVar
putMVar' :: MVar a -> a -> IO ()
putMVar' = putMVar

 
c1 = do 
  hSetBuffering stdout NoBuffering
  forkIO (replicateM_ 100 (putChar 'a'))
  replicateM_ 100 (putChar 'b')

c2 = do 
  str <- getLine 
  when (str /= "e") $  do
      forkIO (remind 1000000 str) 
      c2
  where 
  remind t str = do 
    threadDelay t 
    putStrLn str


-- Exception: thread blocked indefinitely in an MVar operation 
c3 = do 
  m <- newEmptyMVar
  v <- takeMVar m
  putMVar m 3

c4 = do 
  m <- newEmptyMVar 
  forkIO (do putMVar m 3 )
  v <- takeMVar m
  print v

c5 = do 
  m <- newEmptyMVar 
  forkIO (do print "f"; putMVar m 3; print "s"; putMVar m 4 )
  v <- takeMVar m
  print v
  v2 <- takeMVar m
  print v2


newtype Logger a = Logger (MVar a)
data LogItem = Message String | Exit (MVar ())

createLogger :: IO ( Logger a)
createLogger = fmap Logger  newEmptyMVar 
  
startLogger :: Logger LogItem -> IO ThreadId
startLogger (Logger a) = 
    forkIO (start ) where 
    start  = do 
      v <- takeMVar a
      case v of 
        (Message str) -> putStrLn str >> start
        Exit (mvar) -> do 
          putMVar mvar ()
          return ()

log' :: LogItem -> Logger LogItem -> IO ()
log' i (Logger l ) = putMVar l i 

logMessage :: String -> Logger LogItem -> IO ()
logMessage str l = log' (Message str) l

exit :: Logger LogItem -> IO ()
exit l = do 
  mvar <- newEmptyMVar 
  log' (Exit mvar) l
  takeMVar mvar

testLogger = do 
  l <- createLogger
  startLogger l
  logMessage "boran" l
  exit l
  print "finished"




