{-# LANGUAGE  FlexibleContexts, NoMonomorphismRestriction #-}
module Concepts.Exceptions.Except where 

import Control.Monad.Except

throwError' :: (MonadError e m)  => e -> m a
throwError' = throwError
catchError' :: (MonadError e m ) => m a -> (e -> m a) -> m a
catchError' = catchError

div' :: Int -> Int -> Int 
div' = div

divMaybe a 0  = Nothing
divMaybe a b =  Just $  div a b


divPoly :: (MonadError () m) => Int -> Int -> m Int
divPoly a 0 = throwError ()
divPoly a b = return $ a `div` b

tEither :: Either () Int
tEither = divPoly 6 3

tmaybe :: Maybe Int
tmaybe = divPoly 6 0

