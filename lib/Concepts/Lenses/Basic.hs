{-# LANGUAGE RankNTypes      #-}
{-# LANGUAGE TemplateHaskell, NoMonomorphismRestriction, KindSignatures, FlexibleContexts #-}

module Concepts.Lenses.Basic where

import           Control.Lens
import Data.Monoid
import qualified Data.Map as M 
import Control.Monad.State
data Point = Point
  { _x :: Double
  , _y :: Double
  } deriving (Show)

data Segment = Segment
  { _start :: Point
  , _end   :: Point
  , _samples :: [Point]
  } deriving (Show)
makeLenses ''Point
makeLenses ''Segment

segment = Segment (Point 1 2) (Point 3 4) [(Point 5 6), (Point 7 8)]

typex :: Functor f => (Double -> f Double) -> Point -> f Point
typex = x

typex' :: Lens' Point Double
typex' = x

typeview :: Lens' a b -> a -> b
typeview = view

typeview2 :: Getting b a b -> a -> b
typeview2 = view

 
lview = segment ^. (start . x)
lview2 = view (start . x) segment

lset = segment & (start . x) .~ 2
lset2 = set (start . x) 2 $ segment

lover = segment & (start . x) %~ (+3)
lover2 = over (start. x) (+2) $ segment


ltraverseview = segment ^.. (samples . traverse . x) 
ltraverseview2 = toListOf (samples . traverse . x) segment

-- add all x's
ltraversemonoid = segment ^. (samples . traverse . x . to Sum)  

-- add 2 to each x in samples
ltraverseover = segment & (samples . traverse . x) %~ (+2)

typetolistof = toListOf

lpreview :: Maybe Int
lpreview = preview (ix 2) [1,2]
lpreview2 = preview (samples . ix 1 . x) segment 
lpreview3  = preview (_Left) (Right 3)
lpreview4 = preview (_Just ) (Nothing) 
lpreview5 = [1,2] ^? (ix 1)

-- increase first element of sample x by 2
lix1 = segment & (samples . ix 1 . x) %~ ( +2)

lix3 = 123 & (digits . ix 2) .~ 2
digits :: Lens' Int [Int]
digits = lens ( reverse . h) (\_ l -> foldl (\i a -> (i) * 10 + a ) 0 l)

h 0 = []
h n = let (d, m) = n `divMod` 10 in
           m : (h d) 

-- folds 
lallof = segment & allOf (samples . traverse . x ) (> 2) 
lallof' = all (( > 2) . _x) (_samples segment)


lto = segment ^. (start . x . to show)
-- error
--lto2 = segment & (start . x . to show) .~ "12"

-- map at ix 

aslist = M.fromList [(1, "asd"), (2, "bsd")]

lat = aslist ^. (at 1)
lat2 = aslist ^. (at 3)

latnone = aslist ^. (at 1 . non "w")
latnone2 = aslist ^. (at 3 . non "w")

lixfailing = aslist ^. (failing (ix 3) (ix 1))
lixfailingset = aslist & (failing (ix 3) (ix 1)) .~ "asdd"


latix = aslist ^. (ix 1)
latix2 = aslist ^? (ix 1)


latix3 = aslist ^. (ix 3) -- returns mempty
latix4 = aslist ^? (ix 3) -- Nothing

latset = aslist & (at 3) .~  Just "asd" -- create if it is not there 
lixset = aslist & (ix 3) .~ "asd" -- no operation if it is not there


-- state 

stuse1 = use _1 `evalState` (1, 2)
stuse2 = flip evalState (1,2) $ do 
  t <- use _1
  return t
stuses = uses _1 (+5) `evalState` (1, 2) 

stpreuse = preuse (ix 1) `evalState` [1,2,3]

stset =  (ix 0 .= 2)  `execState` [1,2,3]
stzoom = zoom _1 (_2 .= 3) `execState` ((1,2),3)
stzoomN = (_1 . _2 .= 3) `execState` ((1,2),3)

sthelper = (1,2,3) & _1 .~ 3 & _2 .~ 4
sthelper2 = (1,2,3) &~ do _1.=2; _2.=3 