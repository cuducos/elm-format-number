module FormatNumber exposing (format)

{-| This simple package formats `float` numbers as pretty strings. It is
flexible enough to deal with different number of decimals, different thousand
separators and diffetent decimal separator.

@docs format


## What about `Int` numbers?

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format usLocale (toFloat 1234)
    "1,234.00"

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format { usLocale | decimals = 0 } <| toFloat 1234
    "1,234"

## Known bugs

There are [known](https://github.com/elm-lang/elm-compiler/issues/264)
[bugs](https://github.com/elm-lang/elm-compiler/issues/1246) in how Elm handles
large numbers. This library cannot work with large numbers (over `2 ^ 31`)
until Elm itself is fixed:

    >>> format usLocale 1e10
    "1,410,065,408.00"

-}

import Helpers
import FormatNumber.Locales as Locales
import String


{-| Format a float number as a pretty string:

    >>> format { decimals = 2, thousandSeparator = ".", decimalSeparator = "," } 123456.789
    "123.456,79"

    >>> format { decimals = 2, thousandSeparator = ",", decimalSeparator = "." } 1234.5567
    "1,234.56"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 3 "." ",") -7654.3210
    "−7.654,321"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 1 "," ".") -0.01
    "0.0"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 2 "," ".") 0.01
    "0.01"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 0 "," ".") 123.456
    "123"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 0 "," ".") 1e9
    "1,000,000,000"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> format (Locale 5 "," ".") 1.0
    "1.00000"

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format usLocale pi
    "3.14"

    >>> import FormatNumber.Locales exposing (frenchLocale)
    >>> format { frenchLocale | decimals = 4 } pi
    "3,1416"

    >>> import FormatNumber.Locales exposing (frenchLocale)
    >>> format frenchLocale 67295
    "67 295,000"

    >>> import FormatNumber.Locales exposing (spanishLocale)
    >>> format spanishLocale e
    "2,718"

    >>> import FormatNumber.Locales exposing (spanishLocale)
    >>> format spanishLocale 67295
    "67.295,000"

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format usLocale 67295
    "67,295.00"

-}
format : Locales.Locale -> Float -> String
format locale num =
    let
        truncated : Int
        truncated =
            truncate num

        integers : String
        integers =
            case compare truncated 0 of
                GT ->
                    truncated
                        |> Helpers.splitThousands
                        |> String.join locale.thousandSeparator

                EQ ->
                    "0"

                LT ->
                    -truncated
                        |> toFloat
                        |> format { locale | decimals = 0 }
                        |> String.cons '−'
    in
        if locale.decimals == 0 then
            integers
        else
            String.concat
                [ integers
                , locale.decimalSeparator
                , Helpers.decimals locale.decimals num
                ]
