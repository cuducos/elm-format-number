module Helpers exposing (..)

import Char
import FormatNumber.Locales exposing (Locale)
import Round


{-| `FormattedNumber` type and constructor.
-}
type alias FormattedNumber =
    { locale : Locale
    , original : Float
    , integers : List String
    , decimals : Maybe String
    , negativePrefix : Maybe String
    , negativeSuffix : Maybe String
    }


{-| Identify if the formatted version of a number is negative:

    import FormatNumber.Locales exposing (usLocale)

    isNegative (FormattedNumber usLocale 1.2 ["1"] (Just "2") Nothing Nothing)
    --> False

    isNegative (FormattedNumber usLocale 0 ["0"] Nothing Nothing Nothing)
    --> False

    isNegative (FormattedNumber usLocale -1 ["1"] (Just "0") Nothing Nothing)
    --> True

    isNegative (FormattedNumber usLocale 0 ["0"] (Just "000") Nothing Nothing)
    --> False

    isNegative (FormattedNumber usLocale -0.01 ["0"] (Just "0") Nothing Nothing)
    --> False

    isNegative (FormattedNumber usLocale -0.01 ["0"] (Just "01") Nothing Nothing)
    --> True

-}
isNegative : FormattedNumber -> Bool
isNegative formatted =
    let
        isPositive : Bool
        isPositive =
            formatted.original >= 0

        onlyZeros : Bool
        onlyZeros =
            formatted.decimals
                |> Maybe.withDefault ""
                |> List.singleton
                |> List.append formatted.integers
                |> String.concat
                |> String.all (\char -> char == '0')
    in
        not (isPositive || onlyZeros)


{-| Split a `String` in `List String` grouping by thousands digits:

    splitThousands "12345"  --> [ "12", "345" ]

    splitThousands "12" --> [ "12" ]

-}
splitThousands : String -> List String
splitThousands integers =
    let
        reversedSplitThousands : String -> List String
        reversedSplitThousands value =
            if String.length value > 3 then
                value
                    |> String.dropRight 3
                    |> reversedSplitThousands
                    |> (::) (String.right 3 value)
            else
                [ value ]
    in
        integers
            |> reversedSplitThousands
            |> List.reverse


{-| Given a `Locale` parses a `Float` into a `FormattedNumber`:

    import FormatNumber.Locales exposing (usLocale)

    parse { usLocale | decimals = 3 } 3.1415
    --> { locale = { usLocale | decimals = 3 }
    --> , original = 3.1415
    --> , integers = ["3"]
    --> , decimals = Just "142"
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse { usLocale | decimals = 3 } -3.1415
    --> { locale = { usLocale | decimals = 3 }
    --> , original = -3.1415
    --> , integers = ["3"]
    --> , decimals = Just "141"
    --> , negativePrefix = Just "−"
    --> , negativeSuffix = Just ""
    --> }

    parse { usLocale | decimals = 0 } 1234567.89
    --> { locale = { usLocale | decimals = 0 }
    --> , original = 1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse { usLocale | decimals = 0 } -1234567.89
    --> { locale = { usLocale | decimals = 0 }
    --> , original = -1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , negativePrefix = Just "−"
    --> , negativeSuffix = Just ""
    --> }

    parse { usLocale | decimals = 1 } 999.9
    --> { locale = { usLocale | decimals = 1 }
    --> , original = 999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse { usLocale | decimals = 1 } -999.9
    --> { locale = { usLocale | decimals = 1 }
    --> , original = -999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , negativePrefix = Just "−"
    --> , negativeSuffix = Just ""
    --> }

    parse usLocale 0.001
    --> { locale = usLocale
    --> , original = 0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse usLocale -0.001
    --> { locale = usLocale
    --> , original = -0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse { usLocale | decimals = 1 } ((2 ^ 39) / 100)
    --> { locale = { usLocale | decimals = 1 }
    --> , original = 5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = Just "9"
    --> , negativePrefix = Nothing
    --> , negativeSuffix = Nothing
    --> }

    parse { usLocale | decimals = 1 } ((-2 ^ 39) / 100)
    --> { locale = { usLocale | decimals = 1 }
    --> , original = -5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = Just "9"
    --> , negativePrefix = Just "−"
    --> , negativeSuffix = Just ""
    --> }
-}
parse : Locale -> Float -> FormattedNumber
parse locale original =
    let
        parts : List String
        parts =
            original
                |> Round.round locale.decimals
                |> String.split "."

        integers : List String
        integers =
            parts
                |> List.head
                |> Maybe.withDefault "0"
                |> String.filter Char.isDigit
                |> splitThousands

        decimals : Maybe String
        decimals =
            parts
                |> List.drop 1
                |> List.head

        partial : FormattedNumber
        partial =
            FormattedNumber
                locale
                original
                integers
                decimals
                Nothing
                Nothing
    in
        if isNegative partial then
            { partial
                | negativePrefix = Just locale.negativePrefix
                , negativeSuffix = Just locale.negativeSuffix
            }
        else
            partial


{-| Stringify a `FormattedNumber`:

    import FormatNumber.Locales exposing (Locale)

    stringfy (FormattedNumber (Locale 3 "." "," "−" "") 3.1415 ["3"] (Just "142") Nothing Nothing)
    --> "3,142"

    stringfy (FormattedNumber (Locale 3 "." "," "−" "") -3.1415 ["3"] (Just "142") (Just "−") (Just ""))
    --> "−3,142"

    stringfy (FormattedNumber (Locale 0 "." "," "−" "") 1234567.89 ["1", "234", "568"] Nothing Nothing Nothing)
    --> "1.234.568"

    stringfy (FormattedNumber (Locale 0 "." "," "−" "") 1234567.89 ["1", "234", "568"] Nothing (Just "−") (Just ""))
    --> "−1.234.568"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "") 999.9 ["999"] (Just "9") Nothing Nothing)
    --> "999,9"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "") 999.9 ["999"] (Just "9") (Just "−") (Just ""))
    --> "−999,9"

    stringfy (FormattedNumber (Locale 2 "." "," "−" "") 0.001 ["0"] (Just "00") Nothing Nothing)
    --> "0,00"

    stringfy (FormattedNumber (Locale 2 "." "," "−" "") 0.001 ["0"] (Just "00") Nothing Nothing)
    --> "0,00"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "") 5497558138.88 ["5", "497", "558", "138"] (Just "9") Nothing Nothing)
    --> "5.497.558.138,9"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "") 5497558138.88 ["5", "497", "558", "138"] (Just "9") (Just "−") (Just ""))
    --> "−5.497.558.138,9"
-}
stringfy : FormattedNumber -> String
stringfy formatted =
    let
        decimals : String
        decimals =
            case formatted.decimals of
                Just decimals ->
                    formatted.locale.decimalSeparator ++ decimals

                Nothing ->
                    ""
    in
        String.concat
            [ Maybe.withDefault "" formatted.negativePrefix
            , String.join formatted.locale.thousandSeparator formatted.integers
            , decimals
            , Maybe.withDefault "" formatted.negativeSuffix
            ]
