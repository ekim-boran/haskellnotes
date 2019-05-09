{-# LANGUAGE      NoMonomorphismRestriction   #-}

module Concepts.Monads.Basic where 

newtype Reader r a = Reader { runReader :: r -> a}
instance Functor (Reader r) where 
  fmap f = Reader . (f .) . runReader
instance Applicative (Reader r) where 
  pure = Reader . const  
  f <*> a = Reader $ \r -> runReader f r (runReader a r)
instance Monad (Reader r) where 
  return = pure
  a >>= f = Reader $ \r -> runReader (f (runReader a r)) r

reader f = Reader f

run = flip runReader
ex = reader id
r1 = flip runReader 2 $ fmap (+2) ex
r2 = run 2 $ reader (+) <*> ex 
 

  
