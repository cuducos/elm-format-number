module Helpers exposing (..)

import Char
import FormatNumber.Locales exposing (Locale)
import Round


{-| `FormattedNumber` type and constructor.
-}
type alias FormattedNumber =
    { original : Float
    , integers : List String
    , decimals : Maybe String
    , prefix : Maybe String
    , locale : Locale
    }


{-| Get the sign to prefix a `FormattedNumber`:

    import FormatNumber.Locales exposing (usLocale)

    addPrefix (FormattedNumber 1.2 ["1"] (Just "2") Nothing usLocale)
    --> FormattedNumber 1.2 ["1"] (Just "2") Nothing usLocale

    addPrefix (FormattedNumber 0 ["0"] Nothing Nothing usLocale)
    --> FormattedNumber 0 ["0"] Nothing Nothing usLocale

    addPrefix (FormattedNumber -1 ["1"] (Just "0") Nothing usLocale)
    --> FormattedNumber -1 ["1"] (Just "0") (Just "−") usLocale

    addPrefix (FormattedNumber 0 ["0"] (Just "000") Nothing usLocale)
    --> FormattedNumber 0 ["0"] (Just "000") Nothing usLocale

    addPrefix (FormattedNumber -0.01 ["0"] (Just "0") Nothing usLocale)
    --> FormattedNumber -0.01 ["0"] (Just "0") Nothing usLocale

    addPrefix (FormattedNumber -0.01 ["0"] (Just "01") Nothing usLocale)
    --> FormattedNumber -0.01 ["0"] (Just "01") (Just "−") usLocale

-}
addPrefix : FormattedNumber -> FormattedNumber
addPrefix formatted =
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

        prefix : Maybe String
        prefix =
            if isPositive || onlyZeros then
                Nothing
            else
                Just formatted.locale.minusSign
    in
        { formatted | prefix = prefix }


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
    --> { original = 3.1415
    --> , integers = ["3"]
    --> , decimals = Just "142"
    --> , prefix = Nothing
    --> , locale = { usLocale | decimals = 3 }
    --> }

    parse { usLocale | decimals = 3 } -3.1415
    --> { original = -3.1415
    --> , integers = ["3"]
    --> , decimals = Just "141"
    --> , prefix = Just "−"
    --> , locale = { usLocale | decimals = 3 }
    --> }

    parse { usLocale | decimals = 0 } 1234567.89
    --> { original = 1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , prefix = Nothing
    --> , locale = { usLocale | decimals = 0 }
    --> }

    parse { usLocale | decimals = 0 } -1234567.89
    --> { original = -1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , prefix = Just "−"
    --> , locale = { usLocale | decimals = 0 }
    --> }

    parse { usLocale | decimals = 1 } 999.9
    --> { original = 999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , prefix = Nothing
    --> , locale = { usLocale | decimals = 1 }
    --> }

    parse { usLocale | decimals = 1 } -999.9
    --> { original = -999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , prefix = Just "−"
    --> , locale = { usLocale | decimals = 1 }
    --> }

    parse usLocale 0.001
    --> { original = 0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , prefix = Nothing
    --> , locale = usLocale
    --> }

    parse usLocale -0.001
    --> { original = -0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , prefix = Nothing
    --> , locale = usLocale
    --> }

    parse { usLocale | decimals = 1 } ((2 ^ 39) / 100)
    --> { original = 5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = Just "9"
    --> , prefix = Nothing
    --> , locale = { usLocale | decimals = 1 }
    --> }

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> parse { usLocale | decimals = 1 } ((-2 ^ 39) / 100)
    { original = -5497558138.88
    , integers = ["5", "497", "558", "138"]
    , decimals = Just "9"
    , prefix = Just "−"
    , locale = { usLocale | decimals = 1 }
    }
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
    in
        addPrefix <| FormattedNumber original integers decimals Nothing locale


{-| Stringify a `FormattedNumber`:

    import FormatNumber.Locales exposing (Locale)

    stringfy (FormattedNumber 3.1415 ["3"] (Just "142") Nothing (Locale 3 "." "," "−"))
    --> "3,142"

    stringfy (FormattedNumber -3.1415 ["3"] (Just "142") (Just "−") (Locale 3 "." "," "−"))
    --> "−3,142"

    stringfy (FormattedNumber 1234567.89 ["1", "234", "568"] Nothing Nothing (Locale 0 "." "," "−"))
    --> "1.234.568"

    stringfy (FormattedNumber 1234567.89 ["1", "234", "568"] Nothing (Just "−") (Locale 0 "." "," "−"))
    --> "−1.234.568"

    stringfy (FormattedNumber 999.9 ["999"] (Just "9") Nothing (Locale 1 "." "," "−"))
    --> "999,9"

    stringfy (FormattedNumber 999.9 ["999"] (Just "9") (Just "−") (Locale 1 "." "," "−"))
    --> "−999,9"

    stringfy (FormattedNumber 0.001 ["0"] (Just "00") Nothing (Locale 2 "." "," "−"))
    --> "0,00"

    stringfy (FormattedNumber 0.001 ["0"] (Just "00") Nothing (Locale 2 "." "," "−"))
    --> "0,00"

    stringfy (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] (Just "9") Nothing (Locale 1 "." "," "−"))
    --> "5.497.558.138,9"

    stringfy (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] (Just "9") (Just "−") (Locale 1 "." "," "−"))
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
            [ Maybe.withDefault "" formatted.prefix
            , String.join formatted.locale.thousandSeparator formatted.integers
            , decimals
            ]
