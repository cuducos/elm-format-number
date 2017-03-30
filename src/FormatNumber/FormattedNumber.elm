module FormatNumber.FormattedNumber exposing (..)

{-|

Module to manipulate our custom FormattedNumber data structure

@docs FormattedNumber

# FormattedNumber manipulation

-}


{-| `FormattedNumber` type and constructor.
-}
type alias FormattedNumber =
    { original : Float
    , integers : String
    , decimals : Maybe String
    , prefix : Maybe String
    }


{-| Adds the sign to a pre build formatted number

    >>> addSign (FormattedNumber 1 "1" (Just "0") Nothing)
    FormattedNumber 1 "1" (Just "0") Nothing

    >>> addSign (FormattedNumber 0 "0" (Just "0") Nothing)
    FormattedNumber 0 "0" (Just "0") Nothing

    >>> addSign (FormattedNumber -1 "1" (Just "0") Nothing)
    FormattedNumber -1 "1" (Just "0") (Just "−")

    >>> addSign (FormattedNumber 0 "0" (Just "000") Nothing)
    FormattedNumber 0 "0" (Just "000") Nothing

    >>> addSign (FormattedNumber -0.01 "0" (Just "0") Nothing)
    FormattedNumber -0.01 "0" (Just "0") Nothing

    >>> addSign (FormattedNumber -0.01 "0" (Just "01") Nothing)
    FormattedNumber -0.01 "0" (Just "01") (Just "−")
-}
addSign : FormattedNumber -> FormattedNumber
addSign base =
    let
        isPositive : Bool
        isPositive =
            base.original >= 0

        allZeros : String -> Bool
        allZeros =
            String.all (\char -> char == '0')

        onlyZeros : Bool
        onlyZeros =
            case base.decimals of
                Just decimalsString ->
                    (allZeros base.integers) && (allZeros decimalsString)

                Nothing ->
                    allZeros base.integers
    in
        if isPositive || onlyZeros then
            base
        else
            { base | prefix = Just "−" }


{-| Stringify FormattedNumber using custom decimal separator
    >>> formattedNumberToString "." (FormattedNumber -0.01 "0" Nothing Nothing)
    "0"

    >>> formattedNumberToString "." (FormattedNumber -1 "1" Nothing (Just "−"))
    "−1"

    >>> formattedNumberToString "." (FormattedNumber -0.01 "0" (Just "01") Nothing)
    "0.01"

    >>> formattedNumberToString "." (FormattedNumber -0.01 "0" (Just "01") (Just "−"))
    "−0.01"
-}
formattedNumberToString : String -> FormattedNumber -> String
formattedNumberToString separator { integers, decimals, prefix } =
    let
        integerList =
            [ integers ]

        addPrefix partsList =
            case prefix of
                Just sign ->
                    sign :: partsList

                Nothing ->
                    partsList

        addDecimals partsList =
            case decimals of
                Just decimalsString ->
                    List.append partsList [ separator, decimalsString ]

                Nothing ->
                    partsList
    in
        integerList
            |> addPrefix
            |> addDecimals
            |> String.concat
