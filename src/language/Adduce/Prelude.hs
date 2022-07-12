
-- | Language builtins and prelude file
module Adduce.Prelude where

import Control.Exception (throw)
import Data.Map as Map (fromList)
import Data.Maybe (fromMaybe)

import Adduce.Types
import Adduce.Interpreter
import qualified Adduce.Builtins as B
import Utils

import Paths_adduce

-- | Load the prelude file and return its environment.
loadPrelude = do
  prelude <- readFile =<< getDataFileName "src/language/prelude.adc"
  prelude <- exec prelude =<< extendScope =<< defaultState
  return $ fromMaybe (error "Failed to load prelude") prelude

-- | Default program environment.
--   This is seperate from the external prelude file, which will be loaded into it later.
defaultState = newState >>= \s -> return $
  withErrorH (\e st -> return $ throw $ AdduceError e) $
  foldr (\(k,v) s -> setBinding k v s) s bindings
  where
    bindings = [
      ("True",  VBool True),
      ("False", VBool False),

      ("Print", VIOFn B.print),
      ("Do",    VIOFn B.doo),
      ("If",    VFunc B.iff),
      ("List",  VIOFn B.list),
      ("While", VIOFn B.while),

      ("==", VFunc B.eq),
      ("&&", VFunc B.and),
      ("||", VFunc B.or),
      ("!",  VFunc B.not),
      ("<=", VFunc B.le),

      ("+", VFunc B.add),
      ("-", VFunc B.sub),
      ("*", VFunc B.mul),
      ("/", VFunc B.div),
      ("%", VFunc B.mod),
      ("^", VFunc B.pow),

      ("Length",      VFunc B.length),
      ("Get",         VFunc B.get),
      ("Head",        VFunc B.head),
      ("Tail",        VFunc B.tail),
      ("Concatenate", VFunc B.concat),

      ("ToString", VFunc B.toString),

      ("Raise", VFunc B.raise),
      ("Catch", VIOFn B.catch)
      ]

