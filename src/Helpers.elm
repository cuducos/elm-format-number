module Helpers exposing (..)

import Char
import FormatNumber.Locales exposing (Locale)
import Round


{-| `Category` is a helper type and constructor to classify numbers in positive
(should use positive prefix and/or suffix), negative (should use negative
prefix and/or suffix), or zero (discard any prefix or suffix).
-}
type Category
    = Positive
    | Zero
    | Negative


{-| `FormattedNumber` type and constructor.
-}
type alias FormattedNumber =
    { locale : Locale
    , original : Float
    , integers : List String
    , decimals : Maybe String
    , prefix : String
    , suffix : String
    }


{-| Identify if the formatted version of a number is negative:

    import FormatNumber.Locales exposing (usLocale)

    classify (FormattedNumber usLocale 1.2 ["1"] (Just "2") "" "")
    --> Positive

    classify (FormattedNumber usLocale 0 ["0"] Nothing "" "")
    --> Zero

    classify (FormattedNumber usLocale -1 ["1"] (Just "0") "" "")
    --> Negative

    classify (FormattedNumber usLocale 0 ["0"] (Just "000") "" "")
    --> Zero

    classify (FormattedNumber usLocale -0.01 ["0"] (Just "0") "" "")
    --> Zero

    classify (FormattedNumber usLocale -0.01 ["0"] (Just "01") "" "")
    --> Negative

    classify (FormattedNumber usLocale 0.01 ["0"] (Just "01") "" "")
    --> Positive

-}
classify : FormattedNumber -> Category
classify formatted =
    let
        onlyZeros : Bool
        onlyZeros =
            formatted.decimals
                |> Maybe.withDefault ""
                |> List.singleton
                |> List.append formatted.integers
                |> String.concat
                |> String.all (\char -> char == '0')
    in
        if onlyZeros then
            Zero
        else if formatted.original < 0 then
            Negative
        else
            Positive


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
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 3 } -3.1415
    --> { locale = { usLocale | decimals = 3 }
    --> , original = -3.1415
    --> , integers = ["3"]
    --> , decimals = Just "141"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 3, positiveSuffix = "+" } 3.1415
    --> { locale = { usLocale | decimals = 3, positiveSuffix = "+" }
    --> , original = 3.1415
    --> , integers = ["3"]
    --> , decimals = Just "142"
    --> , prefix = ""
    --> , suffix = "+"
    --> }

    parse { usLocale | decimals = 0 } 1234567.89
    --> { locale = { usLocale | decimals = 0 }
    --> , original = 1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 0 } -1234567.89
    --> { locale = { usLocale | decimals = 0 }
    --> , original = -1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = Nothing
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } 999.9
    --> { locale = { usLocale | decimals = 1 }
    --> , original = 999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } -999.9
    --> { locale = { usLocale | decimals = 1 }
    --> , original = -999.9
    --> , integers = ["999"]
    --> , decimals = Just "9"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse usLocale 0.001
    --> { locale = usLocale
    --> , original = 0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse usLocale 0.001
    --> { locale = usLocale
    --> , original = 0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse usLocale -0.001
    --> { locale = usLocale
    --> , original = -0.001
    --> , integers = ["0"]
    --> , decimals = Just "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } ((2 ^ 39) / 100)
    --> { locale = { usLocale | decimals = 1 }
    --> , original = 5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = Just "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } ((-2 ^ 39) / 100)
    --> { locale = { usLocale | decimals = 1 }
    --> , original = -5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = Just "9"
    --> , prefix = "−"
    --> , suffix = ""
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
            FormattedNumber locale original integers decimals "" ""
    in
        case classify partial of
            Negative ->
                { partial
                    | prefix = locale.negativePrefix
                    , suffix = locale.negativeSuffix
                }

            Positive ->
                { partial
                    | prefix = locale.positivePrefix
                    , suffix = locale.positiveSuffix
                }

            Zero ->
                partial


{-| Stringify a `FormattedNumber`:

    import FormatNumber.Locales exposing (Locale)

    stringfy (FormattedNumber (Locale 3 "." "," "−" "" "" "") 3.1415 ["3"] (Just "142") "" "")
    --> "3,142"

    stringfy (FormattedNumber (Locale 3 "." "," "−" "" "" "") -3.1415 ["3"] (Just "142") "−" "")
    --> "−3,142"

    stringfy (FormattedNumber (Locale 0 "." "," "−" "" "" "") 1234567.89 ["1", "234", "568"] Nothing "" "")
    --> "1.234.568"

    stringfy (FormattedNumber (Locale 0 "." "," "−" "" "" "") 1234567.89 ["1", "234", "568"] Nothing "−" "")
    --> "−1.234.568"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "+" "") 999.9 ["999"] (Just "9") "+" "")
    --> "+999,9"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "" "+") 999.9 ["999"] (Just "9") "" "+")
    --> "999,9+"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "" "") 999.9 ["999"] (Just "9") "−"  "")
    --> "−999,9"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "" "") 999.9 ["999"] (Just "9") "−" "")
    --> "−999,9"

    stringfy (FormattedNumber (Locale 2 "." "," "−" "" "" "") 0.001 ["0"] (Just "00") "" "")
    --> "0,00"

    stringfy (FormattedNumber (Locale 2 "." "," "−" "" "" "") 0.001 ["0"] (Just "00") "" "")
    --> "0,00"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "" "") 5497558138.88 ["5", "497", "558", "138"] (Just "9") "" "")
    --> "5.497.558.138,9"

    stringfy (FormattedNumber (Locale 1 "." "," "−" "" "" "") 5497558138.88 ["5", "497", "558", "138"] (Just "9") "−" "")
    --> "−5.497.558.138,9"

-}
stringfy : FormattedNumber -> String
stringfy formatted =
    let
        integers : String
        integers =
            String.join formatted.locale.thousandSeparator formatted.integers

        decimals : String
        decimals =
            case formatted.decimals of
                Just digits ->
                    formatted.locale.decimalSeparator ++ digits

                Nothing ->
                    ""
    in
        String.concat [ formatted.prefix, integers, decimals, formatted.suffix ]
