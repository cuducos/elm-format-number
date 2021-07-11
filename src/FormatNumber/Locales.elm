module FormatNumber.Locales exposing
    ( Decimals(..)
    , Locale
    , System(..)
    , base
    , fromString
    , frenchLocale, indianLocale, spanishLocale, usLocale
    )

{-| These locales and its names are based on this
[International Language Environments
Guide](https://docs.oracle.com/cd/E19455-01/806-0169/overview-9/index.html)

@docs Decimals

@docs Locale

@docs System

@docs base

@docs fromString


# Pre-defined locales

@docs frenchLocale, indianLocale, spanishLocale, usLocale

-}

import Regex
import Set


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


{-| The `System` type contains different numeric systems currently supported:

  - `Western` separates digits by thousands (e.g.: 1000000 might be separated
    as 1,000,000).
  - `Indian` separates digits by the thousand and, from there, by hundreds
    (e.g.: 1000000 might be separated as 10,00,000).

-}
type System
    = Western
    | Indian


{-| This is the `Locale` type and constructor.
-}
type alias Locale =
    { decimals : Decimals
    , system : System
    , thousandSeparator : String
    , decimalSeparator : String
    , negativePrefix : String
    , negativeSuffix : String
    , positivePrefix : String
    , positiveSuffix : String
    , zeroPrefix : String
    , zeroSuffix : String
    }


{-| The `base` locale is a `Western` numeric system which uses unicode minus
(`U+2212`) instead of a hyphen/dash for visual consistency.

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
    , system = Western
    }


{-| Reads a JavaScript's `Number.toLocaleString()` return value to try to
create a `Locale` according to the user's local settings. This is useful when
combined with [Elm's Flags](https://guide.elm-lang.org/interop/flags.html),
e.g.:

```js
Elm.Main.init\({
  flags: {
    numberFormat: (Math.PI * -1000000).toLocaleString()
  }
}\)
```

Then we use `fromString` to read this value from the flag.

The input `value` should be a number that offers enough hints so `fromString`
can make a informed prediction of the `Locale`:

  - the number needs to be negative to predict the negative suffix and prefix

  - the number needs to have decimals to predict the decimal separator

  - the number needs use different separators for thousands and for decimals to
    predict these separators

  - the number's module needs to be greater than (or equal to) 100.000 and
    lesser than (or equal to) 999.999 to predict the right numeric system, i.e.
    `Western` or `Indian`

    fromString "3.1415" -> Nothing

    fromString "-314,159.265"
    --> Just { base
    --> | decimals = Exact 3
    --> , thousandSeparator = ","
    --> , decimalSeparator = "."
    --> , negativePrefix = "-"
    --> }

    fromString "-3,14,159.265"
    --> Just { base
    --> | decimals = Exact 3
    --> , thousandSeparator = ","
    --> , decimalSeparator = "."
    --> , negativePrefix = "-"
    --> , system = Indian
    --> }

-}
fromString : String -> Maybe Locale
fromString value =
    let
        negativePrefixRegex : Regex.Regex
        negativePrefixRegex =
            "^\\D*"
                |> Regex.fromString
                |> Maybe.withDefault Regex.never

        negativeSuffixRegex : Regex.Regex
        negativeSuffixRegex =
            "\\D*$"
                |> Regex.fromString
                |> Maybe.withDefault Regex.never

        negativePrefix : String
        negativePrefix =
            value
                |> Regex.find negativePrefixRegex
                |> List.head
                |> Maybe.map .match
                |> Maybe.withDefault ""

        negativeSuffix : String
        negativeSuffix =
            value
                |> Regex.find negativeSuffixRegex
                |> List.head
                |> Maybe.map .match
                |> Maybe.withDefault ""

        digitsRegex : Regex.Regex
        digitsRegex =
            "\\d+"
                |> Regex.fromString
                |> Maybe.withDefault Regex.never

        cleaned : List String
        cleaned =
            value
                |> Regex.replace negativePrefixRegex (\_ -> "")
                |> Regex.replace negativeSuffixRegex (\_ -> "")
                |> Regex.split digitsRegex
                |> List.filter (String.isEmpty >> not)

        isEmpty : Bool
        isEmpty =
            List.isEmpty cleaned

        onlyOne : Bool
        onlyOne =
            cleaned
                |> List.length
                |> (==) 1

        allTheSame : Bool
        allTheSame =
            cleaned
                |> Set.fromList
                |> Set.size
                |> (==) 1

        partial : Maybe Locale
        partial =
            if isEmpty then
                Nothing

            else if onlyOne then
                Nothing

            else if allTheSame then
                Nothing

            else
                Just
                    { base
                        | negativePrefix = negativePrefix
                        , negativeSuffix = negativeSuffix
                        , decimalSeparator = cleaned |> List.reverse |> List.head |> Maybe.withDefault ""
                        , thousandSeparator = cleaned |> List.head |> Maybe.withDefault ""
                    }

        decimals : Maybe Decimals
        decimals =
            case partial of
                Just locale ->
                    if String.isEmpty locale.decimalSeparator then
                        Nothing

                    else
                        case String.split locale.decimalSeparator value of
                            _ :: digits :: [] ->
                                digits
                                    |> String.length
                                    |> Exact
                                    |> Just

                            _ ->
                                Nothing

                _ ->
                    Nothing

        updateDecimalsAndSystem : Locale -> Decimals -> Maybe Locale
        updateDecimalsAndSystem locale dec =
            let
                thousandSeparators : Int
                thousandSeparators =
                    cleaned
                        |> List.filter (\s -> s == locale.thousandSeparator)
                        |> List.length
            in
            if thousandSeparators == 1 then
                Just { locale | decimals = dec }

            else if thousandSeparators == 2 then
                Just { locale | decimals = dec, system = Indian }

            else
                Nothing
    in
    decimals
        |> Maybe.map2 updateDecimalsAndSystem partial
        |> Maybe.withDefault Nothing


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


{-| Locale used in India. It is similar to `usLocale`, but uses the `Indian`
numeric system.
-}
indianLocale : Locale
indianLocale =
    { base
        | decimals = Exact 2
        , thousandSeparator = ","
        , system = Indian
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
