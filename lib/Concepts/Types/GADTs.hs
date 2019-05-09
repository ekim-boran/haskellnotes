{-# LANGUAGE GADTs #-}


module Concepts.Types.GADTs where 
  

-- Phantom Types
data T a = T1 Int | T2 Bool

t1 :: Int -> T Int
t1 = T1 

t2 :: Bool -> T Bool
t2 = T2


plus' :: T Int -> T Int -> T Int
plus' (T1 i) (T1 s) = T1 (i + s)
plus' _ _ = error "undefined"

and' :: T Bool -> T Bool -> T Bool
and' = undefined



