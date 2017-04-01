module Helpers exposing (..)

{-| `FormattedNumber` type and constructor.
-}


type alias FormattedNumber =
    { original : Float
    , integers : String
    , decimals : String
    , prefix : Maybe String
    }


{-| Adds the sign to a formatted number:

    >>> addPrefix (FormattedNumber 1 "1" "0" Nothing)
    FormattedNumber 1 "1" "0" (Just "")

    >>> addPrefix (FormattedNumber 0 "0" "0" Nothing)
    FormattedNumber 0 "0" "0" (Just "")

    >>> addPrefix (FormattedNumber -1 "1" "0" Nothing)
    FormattedNumber -1 "1" "0" (Just "−")

    >>> addPrefix (FormattedNumber 0 "0" "000" Nothing)
    FormattedNumber 0 "0" "000" (Just "")

    >>> addPrefix (FormattedNumber -0.01 "0" "0" Nothing)
    FormattedNumber -0.01 "0" "0" (Just "")

    >>> addPrefix (FormattedNumber -0.01 "0" "01" Nothing)
    FormattedNumber -0.01 "0" "01" (Just "−")
-}
addPrefix : FormattedNumber -> FormattedNumber
addPrefix formatted =
    case formatted.prefix of
        Just _ ->
            formatted

        Nothing ->
            let
                isPositive : Bool
                isPositive =
                    formatted.original >= 0

                onlyZeros : Bool
                onlyZeros =
                    [ formatted.integers, formatted.decimals ]
                        |> String.concat
                        |> String.all (\c -> c == '0')

                prefix : String
                prefix =
                    if isPositive || onlyZeros then
                        ""
                    else
                        "−"
            in
                { formatted | prefix = Just prefix }


{-| Stringify a `FormattedNumber` using a decimal separator:
    >>> formatToString "." (FormattedNumber -0.01 "0" "" Nothing)
    "0"

    >>> formatToString "." (FormattedNumber -1 "1" "" (Just "−"))
    "−1"

    >>> formatToString "." (FormattedNumber -0.01 "0" "01" (Just ""))
    "0.01"

    >>> formatToString "." (FormattedNumber -0.01 "0" "01" (Just "−"))
    "−0.01"
-}
formatToString : String -> FormattedNumber -> String
formatToString separator formatted =
    let
        prefix : String
        prefix =
            formatted
                |> addPrefix
                |> .prefix
                |> Maybe.withDefault ""

        decimals : String
        decimals =
            if String.isEmpty formatted.decimals then
                ""
            else
                separator ++ formatted.decimals
    in
        String.concat
            [ prefix
            , formatted.integers
            , decimals
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
