{-# LANGUAGE DataKinds, FlexibleContexts, GADTs, PolyKinds, RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables, StandaloneDeriving, TypeFamilies     #-}
{-# LANGUAGE TypeOperators, TypeSynonymInstances                       #-}
module Proof.Equational ((:=:)(..), Equality(..), Preorder(..), reflexivity'
                        ,(:\/:), (:/\:), (=>=), (=~=), Leibniz(..)
                        , Reason(..), because, by, (===), start, byDefinition
                        , admitted, Proxy(..), cong, cong', fromRefl
                        , Proposition(..), (:~>), FromBool (..)
                          -- * Re-exported modules
                        , module Data.Singletons, module Data.Proxy
                        ) where
import Data.Proxy
import Data.Singletons

infix 4 :=:
type a :\/: b = Either a b
infixr 2 :\/:

type a :/\: b = (a, b)
infixr 3 :/\:

data a :=: b where
  Refl :: a :=: a

data Leibniz a b = Leibniz { apply :: forall f. f a -> f b }

fromRefl :: (Preorder eq, SingRep b) => a :=: b -> eq a b
fromRefl Refl = reflexivity'

deriving instance Show (a :=: b)

class Preorder (eq :: k -> k -> *) where
  reflexivity  :: Sing a -> eq a a
  transitivity :: eq a b  -> eq b c -> eq a c

class Preorder eq => Equality (eq :: k -> k -> *) where
  symmetry     :: eq a b  -> eq b a

instance Preorder (:=:) where
  transitivity Refl Refl = Refl
  reflexivity  _         = Refl

instance Equality (:=:) where
  symmetry     Refl      = Refl

instance Preorder (->) where
  reflexivity _ = id
  transitivity = flip (.)

leibniz_refl :: Leibniz a a
leibniz_refl = Leibniz id

instance Preorder Leibniz where
  reflexivity _ = leibniz_refl
  transitivity (Leibniz aEqb) (Leibniz bEqc) = Leibniz $ bEqc . aEqb

instance Equality Leibniz where
  symmetry eq  = unFlip $ apply eq $ Flip leibniz_refl

newtype Flip f a b = Flip { unFlip :: f b a }

data Reason eq x y where
  Because :: Sing y -> eq x y -> Reason eq x y

reflexivity' :: (SingRep x, Preorder r) => r x x
reflexivity' = reflexivity sing

by, because :: Sing y -> eq x y -> Reason eq x y
because = Because
by      = Because

infixl 4 ===, =>=, =~=
infix 5 `Because`
infix 5 `because`

(=>=) :: Preorder r => r x y -> Reason r y z -> r x z
eq =>= (_ `Because` eq') = transitivity eq eq'

(===) :: Equality eq => eq x y -> Reason eq y z -> eq x z
(===) = (=>=)

(=~=) :: Preorder r => r x y -> Sing y -> r x y
eq =~= _ = eq

start :: Preorder eq => Sing a -> eq a a
start = reflexivity

byDefinition :: (SingRep a, Preorder eq) => eq a a
byDefinition = reflexivity sing

admitted :: Reason eq x y
admitted = undefined
{-# WARNING admitted "There are some goals left yet unproven." #-}

cong :: forall f a b. Proxy f -> a :=: b -> f a :=: f b
cong Proxy Refl = Refl

cong' :: (Sing m -> Sing (f m)) -> a :=: b -> f a :=: f b
cong' _ Refl =  Refl

class Proposition f where
  type OriginalProp f n :: *
  unWrap :: f n -> OriginalProp f n
  wrap   :: OriginalProp f n -> f n

type family   (xs :: [*]) :~> (a :: *) :: *
type instance '[]       :~> a = a
type instance (x ': xs) :~> a = x -> (xs :~> a)

infixr 1 :~>

class FromBool (c :: *) where
  type Predicate c :: Bool
  type Args c :: [*]
  fromBool :: Predicate c ~ True => Args c :~> c