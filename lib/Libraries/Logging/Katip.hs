{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes        #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE NoMonomorphismRestriction   #-}

module Libraries.Logging.Katip where

--import           Control.Exception
--import           Katip
--import           System.IO
--
--
--action :: (KatipContext m) => m ()
--action = do
--  $(logTM) InfoS "Hello Katip"
--  katipAddNamespace "additional_namespace" $
--    katipAddContext (sl "some_context" True) $ do
--      $(logTM) WarningS "Now we're getting fancy"
--  katipNoLogging $ do $(logTM) DebugS "You will never see this!"
--  
--ttk :: KatipContextT IO b -> IO b
--ttk a = do
--  handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem InfoS) V2
--  handleScribe2 <- mkHandleScribe ColorIfTerminal stdout (permitItem DebugS) V2
--
--  let makeLogEnv = initLogEnv "MyApp" "production" >>=  registerScribe "stdout" handleScribe defaultScribeSettings  >>=  registerScribe "stdout" handleScribe2 defaultScribeSettings 
--        
--  bracket makeLogEnv closeScribes $ \le -> runKatipContextT le () "main" a
