module Test where

import DPMM
import Data.RVar (sampleRVar)
import Data.Random
import Data.Random.RVar
import Data.Random.Distribution.Bernoulli
import Data.Random.Distribution.Normal
import Control.Monad

yellow :: [Double]
yellow = [-2.8564300066900277,-4.188490584983449,-2.4034375652902247,-1.310045694324143,-2.46509266606692,
 -2.523639652719158,-3.1340541818133594,-1.7146047541678722,-2.638106491456618,-2.482541230368748,
 3.336614758654546,4.001815591824947,2.4128018382717356,3.6998469370221234,4.484083557531247,
 3.0387851838175988,1.7278929048936067,3.685078528164184,2.6630425105163362,2.812163129558648]

type Sampler = RVar Double
type LogDensity = Double -> Double
type Dist = (Sampler, LogDensity)

type DataGen = Int -> RVar [Double]

-- This is a mixture of two Gaussians (-3/1 and 3/1), implemented by
-- deterministically making half the data points from one and half
-- from the other.
-- Representation: Pass in a count and it generates a list of samples
-- of that length.
two_modes :: Dist
two_modes = (sample, logd) where
    sample = do
      pos_mode <- bernoulli (0.5 :: Double)
      if pos_mode then
          normal 3 1
      else
          normal (-3) 1
    logd x = logsumexp [logPdf (Normal 3 1) x, logPdf (Normal (-3) 1) x] - log 2

gendata :: DataGen
gendata ndata = liftM2 (++) (replicateM (ndata `div` 2) $ normal (-3) 1) (replicateM (ndata `div` 2) $ normal 3 1)


certainty_test :: DataGen -> (DPMM -> a) -> Int -> Int -> RVar a
certainty_test gen k data_ct iter_ct = do
  input <- gen data_ct
  output <- train_dpmm input iter_ct
  return $ k output

sampleIO :: RVar a -> IO a
sampleIO = sampleRVar

-- e.g. sampleIO (certainty_test gendata components 300 300)
