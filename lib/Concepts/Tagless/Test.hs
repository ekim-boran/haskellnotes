{-# LANGUAGE RecordWildCards, OverloadedStrings,  GeneralizedNewtypeDeriving, TemplateHaskell, ConstraintKinds #-}

module Concepts.Tagless.Test where 
 
import Data.Text  
import Control.Monad.Except
import Control.Monad.State
import Control.Lens
import Control.Lens.TH
import Concepts.Tagless.Domain
import Control.Monad.Logger.CallStack

newtype TestApp a = MyApp {unApp :: StateT TestState (WriterLoggingT Identity) a} deriving (Applicative, Functor, Monad, MonadState TestState, MonadLogger)
newtype InMemoryStore = InMemoryStore [(UserId, Auth, VerificationCode, Bool)] deriving (Show)

data TestState = TestState {_t :: InMemoryStore} deriving (Show)
makeLenses ''TestState
 
makeClassy ''InMemoryStore

instance HasInMemoryStore TestState where 
  inMemoryStore = t
 
type AuthConstraint r m = (HasInMemoryStore r, MonadState r m)

getAuth' :: (AuthConstraint r m ) => Auth -> m (Maybe AuthResult)
getAuth' auth = do 
    undefined


addAuth' :: (AuthConstraint r m ) => Auth -> VerificationCode -> m (Either [Text] UnverifiedUser)
addAuth' auth code = do 
  InMemoryStore a <- gets (view inMemoryStore) 
  modify  $ set inMemoryStore $ InMemoryStore ((2, Auth (Email "assd") (Password "asd"), 123, False): a)
  return $ Right $ UnverifiedUser (2,123)

verifyAuth' :: (AuthConstraint r m ) => UserId -> m ()
verifyAuth' = undefined 
addSession' :: (AuthConstraint r m ) => UserId -> m (SessionId)
addSession' = undefined 
getSession' :: (AuthConstraint r m ) => SessionId -> m (Maybe UserId)
getSession' = undefined 

sendEmail' :: (AuthConstraint r m ) => Email -> VerificationCode -> m ()
sendEmail' email code = return ()
 
instance AuthRepo TestApp where 
  getAuth = getAuth'
  addAuth = addAuth'
  verifyAuth = verifyAuth'
instance SessionRepo TestApp where 
  addSession  = addSession'
  getSession = getSession'
instance EmailRepo TestApp where 
  sendEmail = sendEmail'


generateCode = return 12

testApp :: TestApp ()
testApp = do 
  t <- register generateCode (Auth (Email "asd") (Password "asdasd"))
  return ()

testrunner  =  runWriterLoggingT . (flip runStateT (TestState (InMemoryStore []))) . unApp

testmain = testrunner testApp
