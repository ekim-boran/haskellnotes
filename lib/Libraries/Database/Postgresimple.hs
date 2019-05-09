{-# LANGUAGE OverloadedStrings, NoMonomorphismRestriction, FlexibleContexts #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}

module Libraries.Database.Postgresimple where 

import Database.PostgreSQL.Simple
import Data.ByteString
import Data.Pool
import Control.Monad.Trans.Control
import Control.Exception
import GHC.Int
import Data.Text
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.Transaction
initdb :: Query
initdb = "   create table pgtest (                 \
          \  dbUserId bigserial primary key not null, \
          \  dbPassword text not null,         \
          \  dbEmail text not null unique,   \
          \  dbVerificationCode text not null, \
          \  dbVerified boolean not null       \
          \);"


connStr = "host=localhost dbname=analysis user=postgres password=pass"
stripeCount = 2
idleConnTimeout = 2
maxConnPerStripe = 3

data User = User {dbUserId :: Integer, dbPassword :: Text, dbEmail :: Text, dbVerificationCode :: Text, dbVerified :: Bool} deriving (Generic, ToRow,  Show)

instance FromRow (User) where 
  fromRow  = User <$> field <*> field <*> field <*> field <*> field


createtable = do 
  conn <- connectPostgreSQL connStr
  t <- execute_  conn initdb
  close conn  

droptable = do 
  conn <- connectPostgreSQL connStr
  t <- execute_  conn "drop table pgtest"
  close conn

-- Only used for one element tuple
pgnoop = do
  conn <- connectPostgreSQL connStr
  [Only i] <- query_ conn "select 2 + 2"
  close conn  
  return i




-- resource Pool functions

createPool' = createPool
destroyAllResources' :: Pool Connection -> IO ()
destroyAllResources' = destroyAllResources 
withResource' :: Pool Connection -> (Connection -> IO c) -> IO c
withResource' = withResource

initPool :: IO (Pool Connection)
initPool = createPool openConn closeConn
            (stripeCount)
            (idleConnTimeout)
            (maxConnPerStripe) where 
            openConn = connectPostgreSQL (connStr)
            closeConn = close

withPool :: (Connection -> IO a) -> IO a
withPool action = bracket initPool destroyAllResources (\pool -> withResource pool  action)   
   
emptyQuery :: IO [(Int, Int)]
emptyQuery = withPool $ \conn -> query_ conn "select (2 + 2), ( 4 + 4)"

insertWithPool :: IO ()
insertWithPool = withPool $ \conn -> execute conn q item >> return () where 
    q :: Query
    q = "insert into pgtest (dbPassword, dbEmail, dbVerificationCode, dbVerified) values (?, ?, ?, ? ) "
    item :: (Text, Text, Text, Bool)
    item = ("asd", "asd", "asd", False)


queryAll :: IO [User]
queryAll =  withPool $ \conn -> query_ conn "select * from pgtest"   
 
queryInList :: IO [User]
queryInList = withPool $ \conn -> query conn "select * from pgtest where dbEmail in ? " (Only $ In ["asd1", "asd2":: Text] ) 


queryWithPool :: IO [User]
queryWithPool = withPool $ \conn -> query conn q item  where 
    -- all fields must exist
    q :: Query
    q = "select dbUserId, dbPassword, cast(dbEmail as text), dbVerificationCode, dbVerified from pgtest where dbPassword = ? "
    item :: Only Text
    item = Only "asd"


transaction = withPool $ \c -> withTransactionMode (TransactionMode ReadCommitted ReadWrite) c $ do 
          executeMany c q1 [("asd1" :: Text, "asd1" :: Text, "asd1" :: Text, False), ("asd2", "asd2", "asd2", False)]
          execute c q2 ("asdasd2":: Text, "asd1":: Text, "asd1" :: Text)
          where 
          q1 = "insert into pgtest (dbPassword, dbEmail, dbVerificationCode, dbVerified) values (?, ?, ?, ? ) "
          q2 = "update pgtest set  dbEmail = ? where  dbPassword= ? and dbEmail = ?  "



-- no parameters return result
query_' :: FromRow r => Connection -> Query -> IO [r]
query_' = query_
execute_' :: Connection -> Query -> IO  Int64
execute_' = execute_


 