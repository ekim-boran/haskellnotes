{-# LANGUAGE OverloadedStrings #-}

module Libraries.Web.Servant where

--import           Network.HTTP.Types
--import           Web.Spock
--import           Web.Spock.Config
--
--spck :: IO ()
--spck = do
--  cfg <- defaultSpockCfg () PCNoDatabase ()
--  runSpock 3000 (spock cfg app)
--
--app :: SpockM () () () ()
--app = do
--  get "about" $
--    html $
--    mconcat
--      ["<html><body>", "  <h1>Hello Practical Haskell!</h1>", "</body></html>"]
--  hookAnyAll $ \_route -> do
--    setStatus notFound404
--    html "<h1>Not found :(</h1>"
