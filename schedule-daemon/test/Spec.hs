import qualified AppStateSpec
import qualified ConfigSpec
import qualified UsersConfigSpec
import qualified UsersConfigDispatcherSpec
import qualified UsersDispatcherSpec
import qualified DbLogSpec
import qualified StateLoggerSpec
import qualified WindowsProCommandSpec
import qualified WindowsHomeCommandSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
  UsersDispatcherSpec.spec
  ConfigSpec.spec
  UsersConfigSpec.spec
  UsersConfigDispatcherSpec.spec
  AppStateSpec.spec
  DbLogSpec.spec
  StateLoggerSpec.spec
  WindowsHomeCommandSpec.spec
  WindowsProCommandSpec.spec
