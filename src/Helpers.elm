module Helpers exposing (decimals, splitThousands)

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

-}
decimals : Int -> Float -> String
decimals digits num =
    digits
        |> toFloat
        |> (^) 10
        |> (*) num
        |> round
        |> splitThousands
        |> String.concat
        |> String.right digits
        |> String.padLeft digits '0'
