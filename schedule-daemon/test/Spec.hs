import qualified AppStateSpec
import qualified ConfigSpec
import qualified LogicSpec
import qualified DbLogSpec
import qualified StateLoggerSpec
import qualified WindowsCommandSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
  LogicSpec.spec
  ConfigSpec.spec
  AppStateSpec.spec
  DbLogSpec.spec
  StateLoggerSpec.spec
  WindowsCommandSpec.spec
