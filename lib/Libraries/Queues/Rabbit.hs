{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Libraries.Queues.Rabbit where

import           Control.Concurrent
import           Network.AMQP

import           Control.Exception
import           Control.Monad.IO.Class
import qualified Data.ByteString.Lazy    as BL
import           Data.Text.Lazy
import           Data.Text.Lazy.Encoding
import qualified Control.Monad.Catch as E
import           Data.Aeson
import qualified Data.Text               as T

withConn f = bracket (initConn) (destroyConn) action
  where
    initConn = do
      conn <- openConnection "localhost" "/" "user" "pass"
      chan <- openChannel conn
      return (conn, chan)
    destroyConn (c, _) = closeConnection c
    action (conn, han) = f han

initQueues queueName exchangeName keyName chan = do
  declareQueue chan newQueue {queueName = queueName}
  declareExchange
    chan
    newExchange {exchangeName = exchangeName, exchangeType = "direct"}
  bindQueue chan queueName exchangeName keyName

subscribe :: T.Text -> Channel -> (Message -> IO ()) -> IO ()
subscribe queueName chan handler =
  void $ consumeMsgs chan queueName Ack myCallback
  where
    myCallback :: (Message, Envelope) -> IO ()
    myCallback (msg, env) =
      void $ do
        ret <- try (handler msg)
        case ret of
          Left (a :: SomeException) -> rejectEnv env False
          Right _                   -> ackEnv env
    void = (>> return ())


publisMessage ::
     (ToJSON a, MonadIO m) => T.Text -> T.Text -> Channel -> a -> m (Maybe Int)
publisMessage exchangeName keyName chan payload =
  liftIO $
  publishMsg
    chan
    exchangeName
    keyName
    newMsg {msgBody = (encode payload), msgDeliveryMode = Just Persistent}

testpublish =
  withConn $ \c -> publisMessage e k c ([("asd" :: Text, "asd" :: Text)])

q = "myQueue"

e = "myExchange"

k = "myKey"

testRabbit = do
  withConn $ \chan -> do
    initQueues q e k chan
    subscribe
      q
      chan
      (\msg ->  putStrLn $ unpack $ "received message:" <> (decodeUtf8 $ msgBody msg))
  --threadDelay 2000000
  -- putStrLn "connection closed"
--docker run -d --hostname my-rabbit --name some-rabbit2 -p 5672:5672  -p 8080:15672 rabbitmq:3-management
--docker run -d --hostname my-rabbit --name some-rabbit1 -p 5672:5672  -p 8080:15672  -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=pass rabbitmq:3-management
