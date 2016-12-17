module FormatNumber exposing (formatInt, formatFloat)

{-| This simple package formats numbers as pretty strings. It is flexible
enough to deal with different number of decimals, different thousand
separators and diffetent decimal separator.

# Usage
@docs formatFloat, formatInt

-}

import String


{-| Format a float number as a pretty string. The four arguments are: number of
decimals, thousand separator, decimal separator and the float number itself.

    >>> formatFloat 2 "," "." 1234.5567
    "1,234.56"

    >>> formatFloat 3 "." "," -7654.3210
    "-7.654,321"

    >>> formatFloat 1 "," "." -0.01
    "0.0"
-}
formatFloat : Int -> String -> String -> Float -> String
formatFloat decimals thousandSeparetor decimalSeparator num =
    let
        multiplier : Int
        multiplier =
            10 ^ decimals

        digits : Int
        digits =
            num
                |> (*) (toFloat multiplier)
                |> round
    in
        if digits == 0 then
            formattedZero decimals decimalSeparator
        else
            formattedNumber decimals thousandSeparetor decimalSeparator digits


{-| Format a float number as a pretty string. The four arguments are: number of
decimals, thousand separator, decimal separator and the float number itself.
    >>> formatInt 1 "," "." 0
    "0.0"

    >>> formatInt 1 "," "." 1234567890
    "1,234,567,890.0"

-}
formatInt : Int -> String -> String -> Int -> String
formatInt decimals thousandSeparetor decimalSeparator num =
    formatFloat decimals thousandSeparetor decimalSeparator (toFloat num)



--
-- Auxiliar functions
--


formattedZero : Int -> String -> String
formattedZero decimals decimalSeparator =
    String.concat
        [ "0"
        , decimalSeparator
        , String.repeat decimals "0"
        ]


formattedNumber : Int -> String -> String -> Int -> String
formattedNumber decimals thousandSeparetor decimalSeparator num =
    let
        digits : String
        digits =
            toString num

        intDigits : String
        intDigits =
            String.dropRight decimals digits

        decDigits : String
        decDigits =
            String.right decimals digits
    in
        String.concat
            [ addThousandSeparator thousandSeparetor intDigits
            , decimalSeparator
            , decDigits
            ]


addThousandSeparator : String -> String -> String
addThousandSeparator separator num =
    let
        parts : List String
        parts =
            String.split separator num

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
                    [ addThousandSeparator separator newFirstPart
                    , String.right 3 firstPart
                    ]
            else
                [ firstPart ]
    in
        String.join separator <|
            List.concat
                [ firstParts
                , remainingParts
                ]
