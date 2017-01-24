module FormatNumber exposing (Locale, formatFloat, formatInt)

{-| This simple package formats numbers as pretty strings. It is flexible
enough to deal with different number of decimals, different thousand
separators and diffetent decimal separator.

# Locale
@docs Locale

# Usage

@docs formatFloat, formatInt


-}

import String
import Helpers exposing (..)


{-| Locale to configure the format options.
-}
type alias Locale =
    { decimals : Int
    , thousandSeparator : String
    , decimalSeparator : String
    }


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
