{-# LANGUAGE OverloadedStrings #-}

module Concepts.Strings.Strict where

import qualified Data.ByteString       as B
import qualified Data.ByteString.Char8 as B8

import qualified Data.ByteString.Lazy.Char8 as BZ8
import qualified Data.ByteString.Lazy as BZ


import qualified Data.Text             as T
import qualified Data.Text.IO          as TIO

import qualified Data.Text.Lazy             as TZ
import qualified Data.Text.Lazy.IO          as TZIO


import qualified Data.Text.Encoding    as TE
import qualified Data.Text.Lazy.Encoding    as TZE

import           GHC.Word
import           System.IO

bs :: B8.ByteString
bs = "boran"

te :: T.Text
te = "boran"

str :: String
str = "boran"

b8pack :: String -> B8.ByteString
b8pack = B8.pack

b8unpack :: B8.ByteString -> String
b8unpack = B8.unpack

bpack :: [Word8] -> B.ByteString
bpack = B.pack



-- Text uses UTF16
-- lines -> newline
-- words -> space tab newline
-- (["asd\tasd ","asdas"],["asd","asd","asdas"])
tpack :: String -> T.Text
tpack = T.pack

t = "asd\tasd \nasdas"

ts = ["asdas", "asdasd", "asdasd"]

tlines :: [T.Text]
tlines = T.lines t

twords :: [T.Text]
twords = T.words t

-- unwords, unlines
tunlines = T.unlines ts

-- ["","a","a","a",""]
tsplit = T.splitOn " " t
tintercalate :: T.Text
tintercalate = T.intercalate " " ts

--replaces a to b
treplace = T.replace "a" "b" "asdasd"

thead :: Char
thead = T.head "asdasd"

-- o(n) operation, copies all 
tcons :: Char -> T.Text -> T.Text
tcons = T.cons

-- takes n characters
ttake :: Int -> T.Text -> T.Text
ttake = T.take 

ttaket = T.take 2 "boran"



-- text append
tconcat = mconcat ["asd", "asd", "asd"]

tappend = "asd" <> "asd"

tio = TIO.putStrLn (T.unlines ts)

tio2 = TIO.putStrLn ("asdas\nasdasd\nasdasd\n")

tio3 = TIO.putStrLn t


-- conversions

tlazy :: TZ.Text -> T.Text
tlazy = TZ.toStrict


btt :: B.ByteString -> T.Text
btt =  TE.decodeUtf8

ttb :: T.Text -> B.ByteString
ttb =  TE.encodeUtf8
 