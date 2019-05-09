{-# LANGUAGE OverloadedStrings #-}

module Libraries.Web.Scotty where

import           Control.Monad.IO.Class
import           Data.Text.Lazy         as L
import           Web.Scotty.Trans



web :: IO ()
web = scottyT 3000 id routes

routes :: (MonadIO m) => ScottyT L.Text m ()
routes = get "/hello" $ text "Hello!"
