module FxForHasql.Connection
where

import FxForHasql.Prelude
import Hasql.Connection (Connection, ConnectionError)
import Hasql.Session (Session, QueryError)
import Hasql.Statement (Statement)
import Hasql.Transaction (Transaction)
import qualified Hasql.Session as Session
import qualified Hasql.Connection as Connection
import qualified Hasql.Statement as Statement
import qualified Hasql.Transaction as Transaction


-- * Providers
-------------------------

provider :: Connection.Settings -> Provider ConnectionError Connection
provider settings =
  acquireAndRelease
    (runPartialIO (const (Connection.acquire settings)))
    (runTotalIO Connection.release)


-- * Fx
-------------------------

{-|
Execute a session in Fx.
-}
runSession :: Session a -> Fx Connection QueryError a
runSession session = runPartialIO (Session.run session)

{-|
Execute a statement in Fx.
-}
runStatement :: Statement a b -> a -> Fx Connection QueryError b
runStatement stmt input = runSession (Session.statement input stmt)

{-|
Execute a multistatement SQL in Fx.
-}
runSql :: ByteString -> Fx Connection QueryError ()
runSql sql = runSession (Session.sql sql)

{-|
Execute a transaction in Fx.
-}
runTransaction :: Transaction a -> Fx Connection QueryError a
runTransaction tx = runSession (Transaction.transact tx)
