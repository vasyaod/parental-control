import qualified AppStateSpec
import qualified ConfigSpec
import qualified LogicSpec
import Test.Hspec

main :: IO ()
main = hspec $ do
  LogicSpec.spec
  ConfigSpec.spec
  AppStateSpec.spec
