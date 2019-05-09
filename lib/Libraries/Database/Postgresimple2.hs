{-# LANGUAGE OverloadedStrings, NoMonomorphismRestriction, FlexibleContexts #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}

module Libraries.Database.Postgresimple2 where 

import Database.PostgreSQL.Simple
import Data.ByteString
import Data.Pool
import Control.Monad.Trans.Control
import Control.Exception
import GHC.Int
import Data.Text
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToRow
import Database.PostgreSQL.Simple.ToField

import Database.PostgreSQL.Simple.Transaction
import Libraries.Database.Postgresimple


tablequery :: Query
tablequery = "   create table mynestedtable (                 \
          \  id bigserial primary key not null, \
          \  locx Int not null,         \
          \  locy Int not null unique  \ 
          \);"

nested = Nested 1 $ Location 2 3
create = withPool $ flip execute_ tablequery

nestedInsert = withPool $ \conn -> execute conn "insert into mynestedtable (id, locx, locy) values (?, ?, ?)" nested
nestedQuery :: IO [Nested]
nestedQuery = withPool $ \conn -> query_ conn "select * from mynestedtable"

data Nested = Nested {id :: Int, loc :: Location} deriving Show
data Location = Location {x::Int, y :: Int}deriving Show


instance FromRow Nested where 
  fromRow = Nested <$> field <*> (Location <$> field <*> field )
 
instance ToRow Nested where 
  toRow (Nested a (Location x y)) = [toField a, toField x, toField y]


-- to do streaming queries with fold
-- event notification



