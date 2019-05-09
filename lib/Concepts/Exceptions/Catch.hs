{-# LANGUAGE  FlexibleContexts, NoMonomorphismRestriction, ScopedTypeVariables #-}

module Concepts.Exceptions.Catch where 
  
import Control.Monad.Catch
import Control.Exception hiding (catch)
import Control.Monad.State

div' :: Int -> Int -> Int 
div' = div

divMaybe a 0  = Nothing
divMaybe a b =  Just $  div a b 

divP :: (MonadThrow m, MonadState Int m) => Int -> m Int
divP a = do
   i <- get
   when (i == 0) $ throwM $ ErrorCall "boran"
   return $ a `div` i
   
terror = divP 2 `catch` (\(e ::SomeException) -> lift $ return 2 )

terror2 :: Either SomeException (Int, Int) 
terror2 = flip runStateT 0 $ terror
