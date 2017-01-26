module Helpers exposing (..)

{-| Module containing helper functions
-}


{-| Returns the n first digits after the comma in a float

    >>> digits 2 123.45
    "45"

    >>> digits 0 125
    ""

    >>> digits 1 1.99
    "0"

    >>> digits 2 1.0
    "00"

    >>> digits 2 -1.0001
    "00"

    >>> digits 2 0.01
    "01"

    >>> digits 2 0.10
    "10"
-}
digits : Int -> Float -> String
digits digits f =
    let
        multiplicator =
            toFloat (10 ^ digits)

        fint =
            (round (f * multiplicator))
    in
        splitIntRec fint []
            |> String.concat
            |> String.right digits
            |> String.padLeft digits '0'


{-| Recursive helper to format an integer

    >>> splitIntRec 12345 []
    ["12", "345"]
-}
splitIntRec : Int -> List String -> List String
splitIntRec num tmp =
    if num >= 10 ^ 3 then
        splitIntRec
            (num // 10 ^ 3)
            ((num % 10 ^ 3 |> toString |> String.padLeft 3 '0') :: tmp)
    else
        (toString num) :: tmp
