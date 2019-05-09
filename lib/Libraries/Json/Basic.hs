{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}

module Libraries.Json.Basic where

import           Data.Aeson
import    qualified       Data.ByteString.Lazy as B
import     qualified      Data.Text            as T
import           GHC.Generics
import qualified Data.HashMap.Strict as M
import qualified Data.Map as Map
import Language.Haskell.TH.Syntax  
import Data.Aeson.TH
import Data.Char
data Book = Book
  { title  :: T.Text
  , author :: T.Text
  , year   :: Int
  , t      :: Maybe Int
  } deriving (Show, Generic)

instance FromJSON Book

instance ToJSON Book

decode' :: FromJSON a => B.ByteString -> Maybe a
decode' = decode

eitherDecode' :: FromJSON a => B.ByteString -> Either String a
eitherDecode' = eitherDecode

encode' :: ToJSON a => a -> B.ByteString
encode' = encode

book = Book "asd" "asds" 1981 Nothing

aencode :: B.ByteString
aencode = encode book

adecode :: Maybe Book
adecode = decode "{\"year\":1981,\"author\":\"asds\",\"title\":\"asd\"}"

-- extra fields are okay
-- non empty fields
adecode2 :: Either String Book
adecode2 =
  eitherDecode
    "{\"year\":1981,\"author\":\"asds\",\"title\":\"asd\",\"year2\":1981}"

data ErrorMessage = ErrorMessage
  { message :: T.Text
  , error   :: Int
  } deriving (Show)

instance FromJSON ErrorMessage where
  parseJSON (Object a) = ErrorMessage <$> a .: "message" <*> a .: "errorCode"
  -- Value ->  Parser ErrorMessage

instance ToJSON ErrorMessage where
  toJSON (ErrorMessage message errorCode) =
    object ["message" .= message, "errorCode" .= errorCode]


errorMessage = encode $ ErrorMessage "asd" 2

--data Value' = Object' Object
--           | Array'  Array
--           | String' Text
--           | Number' Scientific
--           | Bool'   Bool
--           | Null'
--
data Animal = Animal {legs :: Int}
instance ToJSON Animal where 
  toJSON (Animal l) = object ["legs" .= Number ( fromIntegral $ l)]
data Zoo = Zoo { animals :: [Animal]}

instance ToJSON Zoo where
  toJSON (Zoo animals) =
    object ["animals" .= animals]

aesonlist = encode $ Zoo $ [Animal 2, Animal 3]


fromValue :: Value -> Maybe Book 
fromValue (Object o) = do 
      (String t) <- M.lookup "title" o
      (String a) <- M.lookup "author" o
      (Number i) <- M.lookup "year" o
      return $ Book t a (floor i) Nothing
    
aesonmap = fromValue (toJSON book)

data OrT = A {f ::String, s:: String}  | B Int String deriving (Show, Generic)
instance ToJSON OrT
data Z = AZ {asdasd ::String }| BZ String deriving (Show, Generic)
 
testeither :: Either String String -> B.ByteString
testeither = encode  

testortype = encode $ A "boran" "boran"


aesonFromMap :: Result (Map.Map String Int)
aesonFromMap =  fromJSON $ toJSON $ Map.fromList [("asd" :: T.Text, 1 :: Int), ("bsa", 2)]

$(let structName = nameBase ''Z
      lowercaseFirst (x:xs) = [toLower x] <> xs
      lowercaseFirst xs = xs
      options = defaultOptions
                  { fieldLabelModifier = lowercaseFirst . drop (length structName)
                  }
  in  deriveJSON options ''Z)

testz = encode  $ AZ "asd"
testz2 = encode  $ BZ "asd"
