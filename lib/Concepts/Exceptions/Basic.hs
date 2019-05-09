{-# LANGUAGE GADTs, ExistentialQuantification, ScopedTypeVariables, NoMonomorphismRestriction, RankNTypes  #-}

module Concepts.Exceptions.Basic where 

import Control.Exception
import Data.Typeable
import Control.Concurrent


data SomeException' where 
    SomeException' :: Exception' e  => e -> SomeException'

data SomeException'' = forall e. Exception e => SomeException'' e

class (Typeable e, Show e) => Exception' e where 
  toException' :: e -> SomeException'
  toException'   = SomeException'
  fromException' :: SomeException' -> Maybe e
  fromException'(SomeException' e) = cast e   
                      
instance Exception' ArithException
instance Exception' AsyncException

--can use different exceptions because of existensial type
exceptions :: [SomeException']
exceptions = [SomeException' DivideByZero, SomeException' Overflow ]

processException :: SomeException' -> String
processException e = case fromException' e of 
                    (Just (ae :: ArithException) ) -> show ae
                    Nothing -> "boran"

ex1 = fmap processException exceptions

 
ex2 = throw DivideByZero `catch` handler where 
      handler (SomeException e) = undefined



-- catch
throw' :: Exception e => e -> a
throw' = throw
catch' :: (Exception e) => IO a -> (e -> IO a) -> IO a 
catch' = catch

handle' :: Exception e => (e -> IO a)-> IO a -> IO a 
handle' = flip catch

try' :: Exception e => IO a -> IO (Either e a)
try' io = (fmap Right io) `catch` (\(e :: e) -> return $ Left e)

throwTo' :: (Exception e) => ThreadId -> e -> IO ()
throwTo' = throwTo

mask' :: (forall a. (IO a -> IO a ) -> IO b) -> IO b
mask' = mask

-- resouce cleaning
onException' :: IO a -> IO b -> IO a
onException' io h = mask$ \unmask -> unmask io `catch` (\(e :: SomeException) -> h >> throwIO e )

bracket' :: IO a -> (a -> IO b) -> (a -> IO c) -> IO c
bracket' init close io = mask $ \unmask -> do 
     i <- init 
     d <- unmask (io i) `onException` close i
     close i 
     return d
 
finally' :: IO a -> IO b -> IO a
finally' io what = mask $ \unmask -> do 
      d <- (unmask io) `onException` what
      what 
      return d

 


