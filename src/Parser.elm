module Parser exposing (Category(..), FormattedNumber, classify, parse, splitThousands)

import Char
import FormatNumber.Humanize exposing (ZeroStrategy(..))
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
    { original : Float
    , integers : List String
    , decimals : String
    , prefix : String
    , suffix : String
    }


{-| Identify if the formatted version of a number is negative:

    classify (FormattedNumber 1.2 ["1"] "2" "" "")
    --> Positive

    classify (FormattedNumber 0 ["0"] "" "" "")
    --> Zero

    classify (FormattedNumber -1 ["1"] "0" "" "")
    --> Negative

    classify (FormattedNumber 0 ["0"] "000" "" "")
    --> Zero

    classify (FormattedNumber -0.01 ["0"] "0" "" "")
    --> Zero

    classify (FormattedNumber -0.01 ["0"] "01" "" "")
    --> Negative

    classify (FormattedNumber 0.01 ["0"] "01" "" "")
    --> Positive

-}
classify : FormattedNumber -> Category
classify formatted =
    let
        onlyZeros : Bool
        onlyZeros =
            formatted.decimals
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

    splitThousands "12345" --> [ "12", "345" ]

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
    --> , decimals = "142"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 3 } -3.1415
    --> { original = -3.1415
    --> , integers = ["3"]
    --> , decimals = "141"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 3, positiveSuffix = "+" } 3.1415
    --> { original = 3.1415
    --> , integers = ["3"]
    --> , decimals = "142"
    --> , prefix = ""
    --> , suffix = "+"
    --> }

    parse { usLocale | negativePrefix = "(", negativeSuffix = ")", positiveSuffix = " ", zeroSuffix = " " } -12.34
    --> { original = -12.34
    --> , integers = ["12"]
    --> , decimals = "34"
    --> , prefix = "("
    --> , suffix = ")"
    --> }

    parse { usLocale | negativePrefix = "(", negativeSuffix = ")", positiveSuffix = " ", zeroSuffix = " " } 12.34
    --> { original = 12.34
    --> , integers = ["12"]
    --> , decimals = "34"
    --> , prefix = ""
    --> , suffix = " "
    --> }

    parse { usLocale | negativePrefix = "(", negativeSuffix = ")", positiveSuffix = " ", zeroSuffix = " " } 0.0
    --> { original = 0.0
    --> , integers = ["0"]
    --> , decimals = "00"
    --> , prefix = ""
    --> , suffix = " "
    --> }

    parse { usLocale | decimals = 0 } 1234567.89
    --> { original = 1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = ""
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 0 } -1234567.89
    --> { original = -1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = ""
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } 999.9
    --> { original = 999.9
    --> , integers = ["999"]
    --> , decimals = "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } -999.9
    --> { original = -999.9
    --> , integers = ["999"]
    --> , decimals = "9"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse usLocale 0.001
    --> { original = 0.001
    --> , integers = ["0"]
    --> , decimals = "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse usLocale 0.001
    --> { original = 0.001
    --> , integers = ["0"]
    --> , decimals = "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse usLocale -0.001
    --> { original = -0.001
    --> , integers = ["0"]
    --> , decimals = "00"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } ((2 ^ 39) / 100)
    --> { original = 5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = 1 } ((-2 ^ 39) / 100)
    --> { original = -5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = "9"
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

        decimals : String
        decimals =
            parts
                |> List.drop 1
                |> List.head
                |> Maybe.withDefault ""

        partial : FormattedNumber
        partial =
            FormattedNumber original integers decimals "" ""
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
            { partial
                | prefix = locale.zeroPrefix
                , suffix = locale.zeroSuffix
            }
