module FormatNumber.Humanize exposing (ZeroStrategy(..))

{-| These types abstract different strategies to handle decimals ending in
zeros. `KeepZeros` will only remove decimals if all digits are zeros, while
`RemoveZeros` will shorten the decimals removing ending zeros.

@docs Humanize

-}


{-| This is the `ZeroStrategy` type.
-}
type ZeroStrategy
    = KeepZeros
    | RemoveZeros
