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


{-| To format numbers we use elm-format-number package because, we cannot use Number.toLocaleString() directly.
To determine locale number format we use magic string passed via flags like so:
`Elm.Client.init({ flags: { numberFormat: (-1111.111111).toLocaleString() } })`
To actually get number format in form needed for elm-format-number we use this function.
Note: it does not cover the case with zero decimal places.

[More information](https://github.com/cuducos/elm-format-number/issues/27).

-}
parseLocale : String -> Locale
parseLocale a =
    let
        ( negativePrefix, thousandSeparator, decimalSeparator ) =
            case a |> String.replace "1" "" |> String.toList of
                neg :: thousand :: dec :: [] ->
                    ( String.fromChar neg, String.fromChar thousand, String.fromChar dec )

                _ ->
                    ( base.negativePrefix, base.thousandSeparator, base.decimalSeparator )

        decimals =
            case a |> String.split decimalSeparator of
                _ :: dec :: [] ->
                    Locales.Exact (String.length dec)

                _ ->
                    base.decimals
    in
    { base
        | decimals = decimals
        , negativePrefix = negativePrefix
        , thousandSeparator = thousandSeparator
        , decimalSeparator = decimalSeparator
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
