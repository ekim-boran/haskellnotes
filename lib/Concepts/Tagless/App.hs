{-# LANGUAGE RecordWildCards, OverloadedStrings,  GeneralizedNewtypeDeriving, TemplateHaskell, ConstraintKinds #-}
module Concepts.Tagless.App where 
import Data.Text  
import Control.Monad.Except
import Control.Monad.Reader
import Control.Lens
import Control.Lens.TH
import Concepts.Tagless.IO
import Concepts.Tagless.Domain
import Control.Monad.Logger.CallStack

newtype MyApp a = MyApp {unApp :: ReaderT Config (LoggingT IO) a} deriving (Applicative, Functor, Monad, MonadReader Config, MonadIO, MonadLogger)

instance AuthRepo MyApp where 
  getAuth = getAuth'
  addAuth = addAuth'
  verifyAuth = verifyAuth'
instance SessionRepo MyApp where 
  addSession  = addSession'
  getSession = getSession'
instance EmailRepo MyApp where 
  sendEmail = sendEmail'

data Config = Config {t :: () }
 
 
generateCode = return 12

app :: MyApp ()
app = do 
  t <- register generateCode (Auth (Email "asd") (Password "asdasd"))
  return ()

runApp = runStderrLoggingT . flip runReaderT (Config ()) . unApp 

