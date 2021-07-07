module FormatNumber.Parser exposing
    ( Category(..)
    , FormattedNumber
    , addZerosToFit
    , classify
    , parse
    , removeZeros
    , splitInParts
    , splitThousands
    )

import Char
import FormatNumber.Locales exposing (Decimals(..), Locale, NumericSystem(..))
import Round
import String


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

{-| Split a `String` in `List String` grouping by digits as per Indian 
numbering system. Last 3 digits are grouped together but after that 
numbers are grouped in two. 
[Indian numbering system](https://en.wikipedia.org/wiki/Indian_numbering_system#Use_of_separators):

    splitByIndian "12345678" --> [ "1", "23", "45", "678" ]

    splitByIndian "12" --> [ "12" ]

-}
splitByIndian : String -> List String
splitByIndian integers =
    let
        reversedSplitHundreds : String -> List String
        reversedSplitHundreds value =
            if String.length value > 2 then
                value
                    |> String.dropRight 2
                    |> reversedSplitHundreds
                    |> (::) (String.right 2 value)

            else if String.length value == 0 then
                []
            else
                [ value ]
        
        thousand : String
        thousand = 
            if String.length integers > 3 then
                String.right 3 integers
            else
                integers
    in
    List.reverse
        <| thousand :: (integers |> String.dropRight 3 |> reversedSplitHundreds)

{-| Given a `Locale` and a `Float`, returns a tuple with the integer and the
decimal parts as strings.

    import FormatNumber.Locales exposing (Decimals(..), usLocale)

    splitInParts usLocale 3.1415
    --> ("3", "14")

    splitInParts { usLocale | decimals = Exact 0 } 3.1415
    --> ("3", "")

-}
splitInParts : Locale -> Float -> ( String, String )
splitInParts locale value =
    let
        toString : Float -> String
        toString =
            case locale.decimals of
                Max max ->
                    Round.round max

                Min _ ->
                    String.fromFloat

                Exact exact ->
                    Round.round exact

        asList : List String
        asList =
            value |> toString |> String.split "."

        integers : String
        integers =
            asList |> List.head |> Maybe.withDefault ""

        decimals : String
        decimals =
            case List.tail asList of
                Just values ->
                    values |> List.head |> Maybe.withDefault ""

                Nothing ->
                    ""
    in
    ( integers, decimals )


{-| Remove all zeros from the tail of a string.

    removeZeros "100"
    --> "1"

-}
removeZeros : String -> String
removeZeros decimals =
    if String.right 1 decimals /= "0" then
        decimals

    else
        decimals
            |> String.dropRight 1
            |> removeZeros


{-| Given a `String` adds zeros to its tail until it reaches `desiredLength`.

    addZerosToFit 3 "1"
    --> "100"

-}
addZerosToFit : Int -> String -> String
addZerosToFit desiredLength value =
    let
        length : Int
        length =
            String.length value

        missing : Int
        missing =
            if length < desiredLength then
                abs <| desiredLength - length

            else
                0
    in
    value ++ String.repeat missing "0"


{-| Given a `Locale`, and the decimals as `String`, this function handles the
length of the string, removing or adding zeros as needed.
-}
getDecimals : Locale -> String -> String
getDecimals locale digits =
    case locale.decimals of
        Max _ ->
            removeZeros digits

        Exact _ ->
            digits

        Min min ->
            addZerosToFit min digits

{-| Given a 'NumericSystem` parses a integer `String` into 
a `List String` representing grouped integers:

    - Western NumericSystem: 1000000 -> 1,000,000
    - Indian NumericSystem: 1000000 -> 10,00,000
-}

splitIntegers : NumericSystem -> String -> List String
splitIntegers numericSystem integers = 
    case numericSystem of
        Western -> 
            integers
                |> String.filter Char.isDigit
                |> splitThousands
        Indian ->
            integers
                |> String.filter Char.isDigit
                |> splitByIndian



{-| Given a `Locale` parses a `Float` into a `FormattedNumber`:

    import FormatNumber.Locales exposing (Decimals(..), usLocale)

    parse { usLocale | decimals = Exact 3 } 3.1415
    --> { original = 3.1415
    --> , integers = ["3"]
    --> , decimals = "142"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 3 } -3.1415
    --> { original = -3.1415
    --> , integers = ["3"]
    --> , decimals = "141"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 3, positiveSuffix = "+" } 3.1415
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

    parse { usLocale | decimals = Exact 0 } 1234567.89
    --> { original = 1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = ""
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 0 } -1234567.89
    --> { original = -1234567.89
    --> , integers = ["1", "234", "568"]
    --> , decimals = ""
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 1 } 999.9
    --> { original = 999.9
    --> , integers = ["999"]
    --> , decimals = "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 1 } -999.9
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

    parse { usLocale | decimals = Exact 1 } ((2 ^ 39) / 100)
    --> { original = 5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = "9"
    --> , prefix = ""
    --> , suffix = ""
    --> }

    parse { usLocale | decimals = Exact 1 } ((-2 ^ 39) / 100)
    --> { original = -5497558138.88
    --> , integers = ["5", "497", "558", "138"]
    --> , decimals = "9"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | numericSystem = Indian, decimals = Exact 1 } ((-2 ^ 39) / 100)
    --> { original = -5497558138.88
    --> , integers = ["5", "49", "75", "58", "138"]
    --> , decimals = "9"
    --> , prefix = "−"
    --> , suffix = ""
    --> }

    parse { usLocale | numericSystem = Indian, decimals = Exact 1 } 15
    --> { original = -5497558138.88
    --> , integers = ["15"]
    --> , decimals = "0"
    --> , prefix = ""
    --> , suffix = ""
    --> }

-}
parse : Locale -> Float -> FormattedNumber
parse locale original =
    let
        parts : ( String, String )
        parts =
            splitInParts locale original

        integers : List String
        integers =
            parts
                |> Tuple.first
                |> String.filter Char.isDigit
                |> splitIntegers locale.numericSystem

        decimals : String
        decimals =
            parts
                |> Tuple.second
                |> getDecimals locale

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
