module Helpers exposing (..)

{-| `FormattedNumber` type and constructor.
-}


type alias FormattedNumber =
    { original : Float
    , integers : String
    , decimals : String
    }


{-| Get the sign to prefix formatted number:

    >>> getSign (FormattedNumber 1 "1" "0")
    ""

    >>> getSign (FormattedNumber 0 "0" "0")
    ""

    >>> getSign (FormattedNumber -1 "1" "0")
    "−"

    >>> getSign (FormattedNumber 0 "0" "000")
    ""

    >>> getSign (FormattedNumber -0.01 "0" "0")
    ""

    >>> getSign (FormattedNumber -0.01 "0" "01")
    "−"
-}
getSign : FormattedNumber -> String
getSign formatted =
    let
        isPositive : Bool
        isPositive =
            formatted.original >= 0

        onlyZeros : Bool
        onlyZeros =
            [ formatted.integers, formatted.decimals ]
                |> String.concat
                |> String.all (\c -> c == '0')
    in
        if isPositive || onlyZeros then
            ""
        else
            "−"


{-| Stringify a `FormattedNumber` using a decimal separator:
    >>> formatToString "." (FormattedNumber -0.01 "0" "")
    "0"

    >>> formatToString "." (FormattedNumber -1 "1" "")
    "−1"

    >>> formatToString "." (FormattedNumber -0.01 "0" "01")
    "−0.01"
-}
formatToString : String -> FormattedNumber -> String
formatToString separator formatted =
    String.concat
        [ getSign formatted
        , formatted.integers
        , if String.isEmpty formatted.decimals then
            ""
          else
            separator ++ formatted.decimals
        ]


{-| Split a `Int` in `List String` grouping by thousands digits:

    >>> splitThousands 12345
    [ "12", "345" ]

    >>> splitThousands 12
    [ "12" ]

-}
splitThousands : Int -> List String
splitThousands num =
    if num >= 1000 then
        [ num % 1000 ]
            |> List.map toString
            |> List.map (String.padLeft 3 '0')
            |> List.append (splitThousands <| num // 1000)
    else
        [ toString num ]


{-| Format a `Float` to an unsigned string separated by the thousands:

    >>> integers "," 12345
    "12,345"

    >>> integers "," 12
    "12"

    >>> integers "," -12345
    "12,345"

    >>> integers "," -12
    "12"

    >>> integers "." 12345
    "12.345"
-}
integers : String -> Float -> String
integers thousandSeparator num =
    num
        |> truncate
        |> abs
        |> splitThousands
        |> String.join thousandSeparator


{-| Returns the first n decimal digits:

    >>> decimals 2 123.45
    "45"

    >>> decimals 1 1.99
    "0"

    >>> decimals 2 1.0
    "00"

    >>> decimals 3 -1.0001
    "000"

    >>> decimals 2 0.01
    "01"

    >>> decimals 2 0.10
    "10"

    >>> decimals 0 3.1415
    ""

-}
decimals : Int -> Float -> String
decimals digits num =
    if digits == 0 then
        ""
    else
        digits
            |> toFloat
            |> (^) 10
            |> (*) (abs num)
            |> round
            |> splitThousands
            |> String.concat
            |> String.right digits
            |> String.padLeft digits '0'
