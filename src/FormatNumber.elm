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

    >>> formatFloat (Locale 0 "," ".") 123.456
    "123"
-}
formatFloat : Locale -> Float -> String
formatFloat locale num =
    let
        multiplier : Int
        multiplier =
            10 ^ locale.decimals

        digits : Int
        digits =
            num
                |> (*) (toFloat multiplier)
                |> round
    in
        formattedNumber locale digits


{-| Format a integer number as a pretty string:

    >>> formatInt { decimals = 1, thousandSeparator = ",", decimalSeparator = "." } 0
    "0"

    >>> formatInt (Locale 1 "," ".") 1234567890
    "1,234,567,890"

-}
formatInt : Locale -> Int -> String
formatInt locale num =
    num
        |> toFloat
        |> formatFloat { locale | decimals = 0 }



--
-- Auxiliar functions
--


formattedNumber : Locale -> Int -> String
formattedNumber locale num =
    if num == 0 then
        formattedZero locale
    else
        formattedNonZeroNumber locale num


separator : Locale -> String
separator locale =
    if locale.decimals == 0 then
        ""
    else
        locale.decimalSeparator


formattedZero : Locale -> String
formattedZero locale =
    String.concat
        [ "0"
        , separator locale
        , String.repeat locale.decimals "0"
        ]


formattedNonZeroNumber : Locale -> Int -> String
formattedNonZeroNumber locale num =
    let
        digits : String
        digits =
            toString num

        intDigits : String
        intDigits =
            String.dropRight locale.decimals digits

        decDigits : String
        decDigits =
            String.right locale.decimals digits
    in
        String.concat
            [ addThousandSeparator locale intDigits
            , separator locale
            , decDigits
            ]


addThousandSeparator : Locale -> String -> String
addThousandSeparator locale num =
    let
        parts : List String
        parts =
            String.split locale.thousandSeparator num

        firstPart : String
        firstPart =
            List.head parts |> Maybe.withDefault ""

        remainingParts : List String
        remainingParts =
            List.tail parts |> Maybe.withDefault []

        firstParts : List String
        firstParts =
            if String.length firstPart > 3 then
                let
                    newFirstPart : String
                    newFirstPart =
                        String.dropRight 3 firstPart
                in
                    [ addThousandSeparator locale newFirstPart
                    , String.right 3 firstPart
                    ]
            else
                [ firstPart ]
    in
        List.concat [ firstParts, remainingParts ]
            |> String.join locale.thousandSeparator
