module FxForHasql.Pool
where

import FxForHasql.Prelude
import Hasql.Connection (Connection, ConnectionError)
import Hasql.Session (Session, QueryError)
import Hasql.Statement (Statement)
import Hasql.Transaction (Transaction)
import qualified FxForHasql.Connection as Connection
import qualified Hasql.Connection as Connection


type Pool = Provider QueryError Connection

-- * Providers
-------------------------

provider :: Int -> Connection.Settings -> Provider ConnectionError Pool
provider poolSize connectionSettings = pool poolSize (Connection.provider connectionSettings)


-- * Fx
-------------------------

onConnection :: Fx Connection QueryError a -> Fx Pool QueryError a
onConnection cont = do
  provider <- exposeEnv
  provideAndUse provider cont

{-|
Execute a session in Fx.
-}
runSession :: Session a -> Fx Pool QueryError a
runSession session = onConnection (Connection.runSession session)

{-|
Execute a statement in Fx.
-}
runStatement :: Statement a b -> a -> Fx Pool QueryError b
runStatement stmt input = onConnection (Connection.runStatement stmt input)

{-|
Execute a multistatement SQL in Fx.
-}
runSql :: ByteString -> Fx Pool QueryError ()
runSql sql = onConnection (Connection.runSql sql)

{-|
Execute a transaction in Fx.
-}
runTransaction :: Transaction a -> Fx Pool QueryError a
runTransaction tx = onConnection (Connection.runTransaction tx)
