{-# LANGUAGE LambdaCase #-}

module Main where

import Control.Monad
import Data.Bifunctor
import Data.Maybe
import qualified Data.Map as M
import Data.List
import System.IO
import Text.Printf

import Pipes
import qualified Pipes.Prelude as P

-- grep -R . -e "% *temporal\\." --include ".*\\.out" > report.txt

inputFile :: String
inputFile = "report.txt"

compileTimestamp :: [String] -> Maybe (String,Int)
compileTimestamp [_,t,_,fn] = Just (fn,read $ take (length t - 2) t)
compileTimestamp _ = Nothing

takeWhile' :: ([a] -> Bool) -> [a] -> [a]
takeWhile' _ [] = []
takeWhile' p (x:xs) | p (x:xs)  = x : takeWhile' p xs
                    | otherwise = []

compileTimestamp' :: [String] -> Maybe (String,Int)
compileTimestamp' [_,t,_,fn] = Just (takeWhile' (not . isPrefixOf "._") fn,read $ take (length t - 2) t)
compileTimestamp' _ = Nothing

data Cell = LeftAlign String | RightAlign String

render :: Int -> Cell -> String
render w (LeftAlign out)  = out ++ replicate (w - length out) ' '
render w (RightAlign out) = replicate (w - length out) ' ' ++ out

size :: Cell -> Int
size (LeftAlign out)  = length out
size (RightAlign out) = length out

mkTable :: [Maybe (Cell,Cell)] -> Producer String IO ()
mkTable rows = do
  let m0 = maximum (mapMaybe (fmap $ size . fst) rows)
      m1 = maximum (mapMaybe (fmap $ size . snd) rows)
  forM_ rows $ \case
    Just (x,y) -> yield $ printf "| %s | %s |" (render m0 x) (render m1 y)
    Nothing    -> yield $ printf "|%s+%s|" (replicate (m0 + 2) '-') (replicate (m1 + 2) '-')

main :: IO ()
main = do
  lns <- lines <$> readFile inputFile
  let ls = mapMaybe (compileTimestamp' . words) lns
  let m = M.fromListWith (+) ls
  let candidates = take 100 $ reverse $ sortOn snd $ M.toList m
      result = sortOn fst candidates ++ [("total",sum m)]
      heading = Just (LeftAlign "function",LeftAlign "total time (ms)")
      table  = heading : Nothing : map (Just . bimap LeftAlign (RightAlign . show)) result
      ctable = heading : Nothing : map (Just . bimap LeftAlign (RightAlign . show)) candidates
  withFile "result.org" WriteMode $ \h ->
    runEffect $ mkTable table >-> P.toHandle h
  withFile "candidates.org" WriteMode $ \h ->
    runEffect $ mkTable ctable >-> P.toHandle h
