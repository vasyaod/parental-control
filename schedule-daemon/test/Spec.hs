import qualified AppStateSpec
import qualified ConfigSpec
import qualified UsersConfigSpec
import qualified LogicSpec
import qualified DbLogSpec
import qualified StateLoggerSpec
import qualified WindowsProCommandSpec
import qualified WindowsHomeCommandSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
  LogicSpec.spec
  ConfigSpec.spec
  UsersConfigSpec.spec
  AppStateSpec.spec
  DbLogSpec.spec
  StateLoggerSpec.spec
  WindowsHomeCommandSpec.spec
  WindowsProCommandSpec.spec
