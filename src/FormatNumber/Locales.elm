module FormatNumber.Locales exposing
    ( Decimals(..)
    , Locale
    , base
    , fromString
    , frenchLocale, spanishLocale, usLocale
    )

{-| These locales and its names are based on this
[International Language Environments
Guide](https://docs.oracle.com/cd/E19455-01/806-0169/overview-9/index.html)

@docs Decimals

@docs Locale

@docs base

@docs fromString


# Pre-defined locales

@docs frenchLocale, spanishLocale, usLocale

-}

import Regex


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


{-| The `base` locale uses unicode minus (`U+2212`) instead of a hyphen/dash
for visual consistency.

Note that `String.toFloat` does not understand unicode minus (`U+2212`), thus
it will return `Nothing` for negative number strings formatted using `base`
locale.

If you need a result compatible with `String.toFloat`, consider
creating your own locale with hypen as the `negativePrefix` or use a custom
string to float function that handles `U+2212` if need be.

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


{-| Reads a JavaScript's `Number.toLocaleString()` return value to create the
`Locale` according to the user's local settings. This is useful when combined
with [Elm's Flags](https://guide.elm-lang.org/interop/flags.html), e.g.:

```js
Elm.Main.init\({
  flags: {
    numberFormat: (Math.PI * -1000).toLocaleString()
  }
}\)
```

Then we use `fromString` to read this value from the flag (although it does
not cover the case with zero decimal places). **If it fails to parse the string
to a `Locale`, it will return the `base` locale**.

    fromString "-3,141.593"
    --> { base
    --> | decimals = Exact 3
    --> , thousandSeparator = ","
    --> , decimalSeparator = "."
    --> , negativePrefix = "-"
    --> }

-}
fromString : String -> Locale
fromString value =
    let
        regex : Regex.Regex
        regex =
            "\\d"
                |> Regex.fromString
                |> Maybe.withDefault Regex.never

        cleaned : String
        cleaned =
            Regex.replace regex (\_ -> "") value

        partial : Locale
        partial =
            case String.toList cleaned of
                negativePrefix :: thousandSeparator :: decimalSeparator :: negativeSuffix :: [] ->
                    { base
                        | negativePrefix = String.fromChar negativePrefix
                        , thousandSeparator = String.fromChar thousandSeparator
                        , decimalSeparator = String.fromChar decimalSeparator
                        , negativeSuffix = String.fromChar negativeSuffix
                    }

                negativePrefix :: thousandSeparator :: decimalSeparator :: [] ->
                    { base
                        | negativePrefix = String.fromChar negativePrefix
                        , thousandSeparator = String.fromChar thousandSeparator
                        , decimalSeparator = String.fromChar decimalSeparator
                    }

                _ ->
                    base

        decimals : Decimals
        decimals =
            case String.split partial.decimalSeparator value of
                _ :: digits :: [] ->
                    Exact (String.length digits)

                _ ->
                    partial.decimals
    in
    { partial | decimals = decimals }


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
