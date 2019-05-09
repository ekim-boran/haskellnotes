{-# LANGUAGE RecordWildCards, OverloadedStrings,  GeneralizedNewtypeDeriving, TemplateHaskell, ConstraintKinds, FlexibleContexts  #-}
module Concepts.Tagless.Domain where 
import Data.Text  
import Control.Monad.Except
import Control.Monad.Reader
import Control.Lens
import Control.Lens.TH
import Control.Monad.Logger.CallStack

newtype Email = Email String deriving(Show)
newtype Password = Password String deriving(Show)
type UserId = Int
type SessionId = Int
type VerificationCode = Int

newtype UnverifiedUser = UnverifiedUser (UserId, VerificationCode) 
newtype VerifiedUser = VerifiedUser {userId :: UserId  }

data Auth = Auth {email :: Email, pass :: Password} deriving(Show)

 
data AuthResult = VU VerifiedUser | UU UnverifiedUser
class (Monad m) => AuthRepo m where 
   getAuth :: Auth -> m (Maybe AuthResult)
   addAuth :: Auth -> VerificationCode -> m (Either [Text] UnverifiedUser)
   verifyAuth :: UserId -> m ()

class (Monad m) => SessionRepo m where  
   addSession :: UserId -> m (SessionId)
   getSession :: SessionId -> m (Maybe UserId)

class (Monad m) => EmailRepo m where 
   sendEmail :: Email -> VerificationCode -> m ()

type AuhServ m = ( AuthRepo m, SessionRepo m, EmailRepo m, MonadLogger m)

register :: (AuhServ m) => (m VerificationCode) -> Auth -> m (Either [Text] UnverifiedUser)
register generateCode auth@(Auth {..} ) = runExceptT $ do 
    logInfo "boran"
    code  <- lift $ generateCode
    user  <- ExceptT $ addAuth auth code
    lift $ sendEmail email code
    return user where 

login :: (AuhServ m ) =>  Auth -> m (Either Text SessionId)
login auth@(Auth {..} ) = runExceptT $ do 
    r <- lift $ getAuth auth  
    case r of 
     Nothing -> throwError "no user"
     (Just  (VU (user))) -> lift (addSession (userId user))
     (Just (UU user)) -> throwError "not verified"
       
verify :: (AuhServ m) =>  Auth -> VerificationCode -> m (Either  Text  ())
verify auth@(Auth {..} ) code = runExceptT $ do 
 r <-  lift $ getAuth auth  
 case r of 
   Nothing -> throwError  "no user" 
   (Just  (VU user)) -> throwError "already verified" 
   (Just (UU (UnverifiedUser (id, code)))) -> throwError    "not verified" 
 