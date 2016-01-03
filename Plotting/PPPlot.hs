module Plotting.PPPlot where

import Data.List (sort)
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Gtk
import Graphics.Rendering.Chart.Backend.Cairo

-- Points suitable for the scatter plot portion of a two-sample P-P plot.
newtype PPScatter = PPScatter [(Double, Double)]
    deriving Show

compute_points :: (Ord a) => [a] -> [a] -> PPScatter
compute_points d1 d2 = PPScatter $ go (sort d1) (sort d2) 0 0 where
    step1 = 1.0 / fromIntegral (length d1)
    step2 = 1.0 / fromIntegral (length d2)
    go [] [] _ _ = [(1.0, 1.0)]
    go [] (_:xs2) amt1 amt2 = (amt1, amt2):go [] xs2 amt1 (amt2 + step2)
    go (_:xs1) [] amt1 amt2 = (amt1, amt2):go xs1 [] (amt1 + step1) amt2
    go all1@(x1:xs1) all2@(x2:xs2) amt1 amt2
        = case x1 `compare` x2 of
            LT -> (amt1, amt2):go xs1 all2 (amt1 + step1) amt2
            GT -> (amt1, amt2):go all1 xs2 amt1 (amt2 + step2)
            EQ -> (amt1, amt2):go xs1 xs2 (amt1 + step1) (amt2 + step2)

plot_scatter :: PPScatter -> EC (Layout Double Double) ()
plot_scatter (PPScatter pts) = do
  layout_title .= "Probability-probability plot"
  setColors [opaque red, opaque blue]
  plot $ line "equality line" [[(0,0),(1,1)]]
  plot $ points "observed" pts

p_p_plot :: (Ord a) => [a] -> [a] -> EC (Layout Double Double) ()
p_p_plot d1 d2 = plot_scatter $ compute_points d1 d2

-- toWindow 300 300 $ p_p_plot [1,2,3] [2,3,4]
-- toFile def "example-p-p.png" $ p_p_plot [1,2,3] [2,3,4]