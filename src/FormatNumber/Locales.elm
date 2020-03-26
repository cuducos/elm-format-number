module FormatNumber.Locales exposing
    ( Decimals(..)
    , Locale
    , base
    , frenchLocale, spanishLocale, usLocale
    )

{-| These locales and its names are based on this
[International Language Environments
Guide](https://docs.oracle.com/cd/E19455-01/806-0169/overview-9/index.html)

@docs Decimals

@docs Locale

@docs base


# Pre-defined locales

@docs frenchLocale, spanishLocale, usLocale

-}


{-| The `Decimals` type contains different strategies for handling the number of
decimals when formatting the number:

  - `Min` `Int` shows at least a certain amount of decimal digits, adding
    trailing zeros if needed.
  - `Max` `Int` shows up to a certain amount of decimal digits, discarding
    trailing zeros if needed.
  - `Exact` `Int` shows an exact number of decimal digits, adding trailing
    zeros if needed.

-}
type Decimals
    = Min Int
    | Max Int
    | Exact Int


{-| This is the `Locale` type and constructor.
-}
type alias Locale =
    { decimals : Decimals
    , thousandSeparator : String
    , decimalSeparator : String
    , negativePrefix : String
    , negativeSuffix : String
    , positivePrefix : String
    , positiveSuffix : String
    , zeroPrefix : String
    , zeroSuffix : String
    }


{-| The `base` locale matches Elm's native `String.fromFloat` using unicode
minus (`U+2212`) instead of an hyphen/dash.
-}
base : Locale
base =
    { decimals = Min 0
    , thousandSeparator = ""
    , decimalSeparator = "."
    , negativePrefix = "−"
    , negativeSuffix = ""
    , positivePrefix = ""
    , positiveSuffix = ""
    , zeroPrefix = ""
    , zeroSuffix = ""
    }


{-| Locale used in France, Canada, Finland and Sweden. It has 3 decimals
digits, uses a thin space (`U+202F`) as thousand separator and a `,` as decimal
separator. It uses a minus sign (not a hyphen) as a prefix for negative
numbers, but no suffix or prefix for positive numbers.
-}
frenchLocale : Locale
frenchLocale =
    { base
        | decimals = Exact 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


{-| Locale used in Spain, Italy and Norway. It has 3 decimals digits, uses a
`.` as thousand separator and a `,` as decimal separator. It uses a minus sign
(not a hyphen) as a prefix for negative numbers, but no suffix or prefix for
positive numbers.
-}
spanishLocale : Locale
spanishLocale =
    { base
        | decimals = Exact 3
        , thousandSeparator = "."
        , decimalSeparator = ","
    }


{-| Locale used in the United States, Great Britain and Thailand. It has 2
decimals digits, uses a `,` as thousand separator and a `.` as decimal
separator. It uses a minus sign (not a hyphen) as a prefix for negative
numbers, no suffix or prefix for positive numbers.
-}
usLocale : Locale
usLocale =
    { base
        | decimals = Exact 2
        , thousandSeparator = ","
    }
