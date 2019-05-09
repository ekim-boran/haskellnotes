{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE ScopedTypeVariables       #-}
{-# LANGUAGE TypeFamilies              #-}

module Concepts.Exceptions.Control where

import           Control.Exception.Safe
import           Control.Monad.Reader
import           Control.Monad.Trans.Control
import           System.IO

withFile' ::
     (Handle -> IO a) -- callback to lift
  -> IO a
withFile' = withFile "src/Concepts/Exceptions/deneme.txt" ReadWriteMode

withFileLifted :: (MonadBaseControl IO m, StM m a ~ a) => (Handle -> m a) -> m a
withFileLifted action =
  control $ \runInIO -> withFile' (\h -> runInIO (action h))

withFileLifted2 path mode action =
  let lifted = liftBaseWith $ \runInIO -> withFile' (\h -> runInIO (action h))
  in lifted >>= restoreM

withFileLiftedReader :: (Handle -> ReaderT String IO ()) -> ReaderT String IO ()
withFileLiftedReader f = ReaderT $ \r -> withFile' (($r) . runReaderT . f)

testhandler :: (Handle -> ReaderT String IO ())
testhandler h = do
  s <- ask
  liftIO $ hPutStrLn h s
  return ()

testcontrol = flip runReaderT "borrano" $ withFileLiftedReader testhandler

testcontrol2 = flip runReaderT "borranoasd" $ withFileLifted testhandler

catch' :: (MonadCatch m, Exception e) => m a -> (e -> m a) -> m a
catch' = catch

catchLifted ::
     (MonadBaseControl IO m, Exception e, StM m a ~ a)
  => m a
  -> (e -> m a)
  -> m a
catchLifted action handler =
  control $ \runInIO -> (runInIO action) `catch` (\e -> runInIO (handler e))
