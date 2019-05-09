{-# LANGUAGE RecordWildCards, OverloadedStrings,  GeneralizedNewtypeDeriving, TemplateHaskell, ConstraintKinds #-}

module Concepts.Tagless.IO where 
import Data.Text  
import Control.Monad.Except
import Control.Monad.Reader
import Control.Lens
import Control.Lens.TH
import Concepts.Tagless.Domain


type AuthConstraint r m = ( MonadReader r m)

 
getAuth' :: (AuthConstraint r m ) => Auth -> m (Maybe AuthResult)
getAuth' auth = do 
    undefined

addAuth' :: (AuthConstraint r m ) => Auth -> VerificationCode -> m (Either [Text] UnverifiedUser)
addAuth' auth code = undefined

verifyAuth' :: (AuthConstraint r m ) => UserId -> m ()
verifyAuth' = undefined 
addSession' :: (AuthConstraint r m ) => UserId -> m (SessionId)
addSession' = undefined 
getSession' :: (AuthConstraint r m ) => SessionId -> m (Maybe UserId)
getSession' = undefined 

sendEmail' :: (AuthConstraint r m ) => Email -> VerificationCode -> m ()
sendEmail' email code = undefined
