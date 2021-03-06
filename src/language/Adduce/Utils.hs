
-- | Various utility functions used throughout the interpreter.
module Adduce.Utils where

import Control.Monad (foldM)
import Data.Char (isSpace)
import Data.List (dropWhileEnd, isPrefixOf)
import Data.Map as Map (Map, insert, member, (!))
import Data.Bifunctor (Bifunctor, bimap)

-- | Return the left-hand `Maybe` if it is a `Just`, otherwise return the right-hand `Maybe`.
(?:) :: Maybe a -> Maybe a -> Maybe a
(Just x) ?: _ = Just x
_        ?: x = x

-- | Inverse composition operator.
(&.) :: (a -> b) -> (b -> c) -> (a -> c)
f &. g = g . f

-- | Return the value from an `Either` that has the same left and right types.
fromEither :: Either a a -> a
fromEither = either id id

-- | Partial fold operation which terminates early if the fold function returns a `Left`.
foldPartial :: (b -> a -> Either b b) -> b -> [a] -> b
foldPartial f b = fromEither . foldM f b

-- | IO-wrapped partial fold operation which terminates early if the fold function returns an `IO Left`.
foldPartialIO :: (b -> a -> IO (Either b b)) -> b -> [a] -> IO b
foldPartialIO f = foldM (\b a -> fromEither <$> f b a)

-- | Specialized version of `Data.Bifunctor.bimap` for applying the same function to both arguments.
bimapBoth :: Bifunctor p => (a -> b) -> p a a -> p b b
bimapBoth f = bimap f f

-- | Trim whitespace from both ends of a string.
trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

-- | Split a string by a delimiter
split :: Eq a => [a] -> [a] -> [[a]]
split sub str = split' sub str [] []
  where
  split' _   []  subacc acc = reverse (reverse subacc:acc)
  split' sub str subacc acc
    | sub `isPrefixOf` str = split' sub (drop (length sub) str) [] (reverse subacc:acc)
    | otherwise            = split' sub (tail str) (head str:subacc) acc

-- | Group a list of tuples into a map of lists, grouping by the first of each tuple.
keyedPartition :: Ord k => [(k,v)] -> Map k [v]
keyedPartition = keyedPartition' mempty where
  keyedPartition' m ((k,v):xs)
    | Map.member k m = keyedPartition' (Map.insert k (v : m ! k) m) xs
    | otherwise      = keyedPartition' (Map.insert k [v] m) xs
  keyedPartition' m [] = m

-- | Drop from the end of a list.
dropEnd i xs
  | i <= 0    = xs
  | otherwise = f xs (drop i xs)
  where f (x:xs) (y:ys) = x : f xs ys
        f _ _           = []

