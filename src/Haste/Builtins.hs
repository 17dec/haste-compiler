{-# LANGUAGE OverloadedStrings #-}
-- | Various functions generated as builtins
module Haste.Builtins (toBuiltin) where
import GhcPlugins as GHC
import Haste.AST as AST
import Control.Applicative

-- TODO: proxy# (and probably void#, realWorld# and coercionToken# as well)
--       should really just go away in the final code.

toBuiltin :: GHC.Var -> Maybe AST.Var
toBuiltin v =
  case (modname, varname) of
    (Just "GHC.Prim", "coercionToken#") ->
      Just $ foreignVar "_"
    (Just "GHC.Prim", "realWorld#") ->
      Just $ foreignVar "_"
    (Just "GHC.Prim", "void#") ->
      Just $ foreignVar "_"
    (Just "GHC.Prim", "proxy#") ->
      Just $ foreignVar "_"
    (Just "GHC.Err", "error") ->
      Just $ foreignVar "err"

    -- Everything to do with unpacking had better be built in for compactness,
    -- efficiency and space reasons.
    (Just "GHC.CString", "unpackCString#") ->
      Just $ foreignVar "unCStr"
    (Just "GHC.CString", "unpackCStringUtf8#") ->
      Just $ foreignVar "unCStr"
    (Just "GHC.CString", "unpackAppendCString#") ->
      Just $ foreignVar "unAppCStr"
    (Just "GHC.CString", "unpackFoldrCString#") ->
      Just $ foreignVar "unFoldrCStr"

    -- Primitive needs of the Haste standard library
    (Just "Haste.Prim", "jsRound") ->
      Just $ foreignVar "Math.round"
    (Just "Haste.Prim", "jsCeiling") ->
      Just $ foreignVar "Math.ceil"
    (Just "Haste.Prim", "jsFloor") ->
      Just $ foreignVar "Math.floor"
    _ | otherwise ->
      Nothing
  where
    modname = moduleNameString . moduleName <$> nameModule_maybe (varName v)
    varname = occNameString $ nameOccName $ varName v
