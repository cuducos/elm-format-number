module FormatNumber
    exposing
        ( Locale
        , formatFloat
        , formatInt
        , usLocale
        , frenchLocale
        , spanishLocale
        )

{-| This simple package formats numbers as pretty strings. It is flexible
enough to deal with different number of decimals, different thousand
separators and diffetent decimal separator.

# Locale
@docs Locale, usLocale , frenchLocale, spanishLocale

# Usage

@docs formatFloat, formatInt

# Known bugs

There are known bugs in how elm handles large numbers:

 * https://github.com/elm-lang/elm-compiler/issues/264
 * https://github.com/elm-lang/elm-compiler/issues/1246

This library won't work with large numbers (over 2^31) until elm itself is fixed

    >>> formatFloat usLocale 1e10
    "1,410,065,408.00"
-}

import String
import Helpers exposing (..)


-- Locales


{-| Locale to configure the format options.
-}
type alias Locale =
    { decimals : Int
    , thousandSeparator : String
    , decimalSeparator : String
    }



-- Locales from
-- https://docs.oracle.com/cd/E19455-01/806-0169/overview-9/index.html


{-| locale used in France, Canada, Finland, Sweden
    >>> formatFloat frenchLocale 67295
    "67 295,000"
-}
frenchLocale : Locale
frenchLocale =
    Locale 3 " " ","


{-| locale used in the United States, Great Britain, and Thailand
    >>> formatFloat usLocale 67295
    "67,295.00"
-}
usLocale : Locale
usLocale =
    Locale 2 "," "."


{-| locale used in Spain, Italy and Norway
    >>> formatFloat spanishLocale 67295
    "67.295,000"
-}
spanishLocale : Locale
spanishLocale =
    Locale 3 "." ","



-- Functions


{-| Format a float number as a pretty string:

    >>> formatFloat { decimals = 2, thousandSeparator = ",", decimalSeparator = "." } 1234.5567
    "1,234.56"

    >>> formatFloat (Locale 3 "." ",") -7654.3210
    "-7.654,321"

    >>> formatFloat (Locale 1 "," ".") -0.01
    "0.0"

    >>> formatFloat (Locale 2 "," ".") 0.01
    "0.01"

    >>> formatFloat (Locale 0 "," ".") 123.456
    "123"

    >>> formatFloat (Locale 0 "," ".") 1e9
    "1,000,000,000"

    >>> formatFloat (Locale 5 "," ".") 1.0
    "1.00000"
-}
formatFloat : Locale -> Float -> String
formatFloat locale num =
    (formatInt locale (truncate num))
        ++ (separator locale)
        ++ (nDigits locale.decimals num)


{-| Format a integer number as a pretty string:

    >>> formatInt { decimals = 1, thousandSeparator = ",", decimalSeparator = "." } 0
    "0"

    >>> formatInt (Locale 1 " " ".") 1234567890
    "1 234 567 890"

    >>> formatInt (Locale 10 "," ".") -123456
    "-123,456"

-}
formatInt : Locale -> Int -> String
formatInt locale num =
    case compare num 0 of
        LT ->
            formatInt locale (-num) |> String.cons '-'

        EQ ->
            "0"

        GT ->
            splitIntRec num [] |> String.join locale.thousandSeparator


{-| The separator, or ""

    >> separator (Locale 10 "," ".")
    "."

    >> separator (Locale 0 "," ".")
    ""
-}
separator : Locale -> String
separator locale =
    if locale.decimals == 0 then
        ""
    else
        locale.decimalSeparator
