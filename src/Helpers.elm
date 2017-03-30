module Helpers exposing (..)

{-| Module containing helper functions

@docs splitThousands, decimals

-}


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


{-| Returns the first n decimal digits:

    >>> decimals 2 123.45
    Just "45"

    >>> decimals 1 1.99
    Just "0"

    >>> decimals 2 1.0
    Just "00"

    >>> decimals 3 -1.0001
    Just "000"

    >>> decimals 2 0.01
    Just "01"

    >>> decimals 2 0.10
    Just "10"

-}
decimals : Int -> Float -> Maybe String
decimals digits num =
    if digits == 0 then
        Nothing
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
            |> Just


{-| Format an `Float` to a positive integer string, separated by input

    >>> toSeparatedIntegerString 12345 ","
    "12,345"

    >>> toSeparatedIntegerString 12 ","
    "12"

    >>> toSeparatedIntegerString -12345 ","
    "12,345"

    >>> toSeparatedIntegerString -12 ","
    "12"

    >>> toSeparatedIntegerString 12345 "."
    "12.345"
-}
toSeparatedIntegerString : Float -> String -> String
toSeparatedIntegerString num thousandSeparator =
    num
        |> truncate
        |> abs
        |> splitThousands
        |> String.join thousandSeparator
