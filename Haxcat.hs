-- -*- coding: utf-8 -*-

--   Copyright (c) 2010-2014, MIT Probabilistic Computing Project
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.

{-# LANGUAGE TupleSections #-}

module Haxcat where

import Control.Monad.State.Lazy
import qualified Data.Map as M

import Data.Random.RVar

import Types
import RowSweep
import ColumnSweep

modifyT :: (Monad m) => (a -> m a) -> StateT a m ()
modifyT f = StateT $ liftM ((),) . f

infer :: M.Map ColID (ColumnData a) -> StateT (Crosscat a) RVar ()
infer ds = do
  modifyT (col_sweep ds)
  modifyT (row_sweep2 ds)

train :: M.Map ColID (ColumnData Double) -> Int -> RVar (Crosscat Double)
train ds k = cc_initialize ds >>= execStateT (replicateM k (infer ds)) where
