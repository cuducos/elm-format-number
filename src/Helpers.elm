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
    }


{-| Get the sign to prefix formatted number:

    >>> addPrefix (FormattedNumber 1.2 ["1"] (Just "2") Nothing)
    FormattedNumber 1.2 ["1"] (Just "2") Nothing

    >>> addPrefix (FormattedNumber 0 ["0"] Nothing Nothing)
    FormattedNumber 0 ["0"] Nothing Nothing

    >>> addPrefix (FormattedNumber -1 ["1"] (Just "0") Nothing)
    FormattedNumber -1 ["1"] (Just "0") (Just "−")

    >>> addPrefix (FormattedNumber 0 ["0"] (Just "000") Nothing)
    FormattedNumber 0 ["0"] (Just "000") Nothing

    >>> addPrefix (FormattedNumber -0.01 ["0"] (Just "0") Nothing)
    FormattedNumber -0.01 ["0"] (Just "0") Nothing

    >>> addPrefix (FormattedNumber -0.01 ["0"] (Just "01") Nothing)
    FormattedNumber -0.01 ["0"] (Just "01") (Just "−")
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
                Just "−"
    in
        { formatted | prefix = prefix }


{-| Split a `String` in `List String` grouping by thousands digits:

    >>> splitThousands "12345"
    [ "12", "345" ]

    >>> splitThousands "12"
    [ "12" ]

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


{-| Given `decimalDigits` parses a `Float` into a `FormattedNumber`:

    >>> parse 3 3.1415
    { original = 3.1415
    , integers = ["3"]
    , decimals = Just "142"
    , prefix = Nothing
    }

    >>> parse 3 -3.1415
    { original = -3.1415
    , integers = ["3"]
    , decimals = Just "141"
    , prefix = Just "−"
    }

    >>> parse 0 1234567.89
    { original = 1234567.89
    , integers = ["1", "234", "568"]
    , decimals = Nothing
    , prefix = Nothing
    }

    >>> parse 0 -1234567.89
    { original = -1234567.89
    , integers = ["1", "234", "568"]
    , decimals = Nothing
    , prefix = Just "−"
    }

    >>> parse 1 999.9
    { original = 999.9
    , integers = ["999"]
    , decimals = Just "9"
    , prefix = Nothing
    }

    >>> parse 1 -999.9
    { original = -999.9
    , integers = ["999"]
    , decimals = Just "9"
    , prefix = Just "−"
    }

    >>> parse 2 0.001
    { original = 0.001
    , integers = ["0"]
    , decimals = Just "00"
    , prefix = Nothing
    }

    >>> parse 2 -0.001
    { original = -0.001
    , integers = ["0"]
    , decimals = Just "00"
    , prefix = Nothing
    }

    >>> parse 1 ((2 ^ 39) / 100)
    { original = 5497558138.88
    , integers = ["5", "497", "558", "138"]
    , decimals = Just "9"
    , prefix = Nothing
    }

    >>> parse 1 ((-2 ^ 39) / 100)
    { original = -5497558138.88
    , integers = ["5", "497", "558", "138"]
    , decimals = Just "9"
    , prefix = Just "−"
    }
-}
parse : Int -> Float -> FormattedNumber
parse decimalDigits original =
    let
        parts : List String
        parts =
            original
                |> Round.round decimalDigits
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
        addPrefix <| FormattedNumber original integers decimals Nothing


{-| Stringify a `FormattedNumber` using a `Locale`:

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 3 "." ",") (FormattedNumber 3.1415 ["3"] (Just "142") Nothing)
    "3,142"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 3 "." ",") (FormattedNumber -3.1415 ["3"] (Just "142") (Just "−"))
    "−3,142"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 0 "." ",") (FormattedNumber 1234567.89 ["1", "234", "568"] Nothing Nothing)
    "1.234.568"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 0 "." ",") (FormattedNumber 1234567.89 ["1", "234", "568"] Nothing (Just "−"))
    "−1.234.568"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 1 "." ",") (FormattedNumber 999.9 ["999"] (Just "9") Nothing)
    "999,9"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 1 "." ",") (FormattedNumber 999.9 ["999"] (Just "9") (Just "−"))
    "−999,9"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 2 "." ",") (FormattedNumber 0.001 ["0"] (Just "00") Nothing)
    "0,00"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 2 "." ",") (FormattedNumber 0.001 ["0"] (Just "00") Nothing)
    "0,00"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 1 "." ",") (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] (Just "9") Nothing)
    "5.497.558.138,9"

    >>> import FormatNumber.Locales exposing (Locale)
    >>> stringfy (Locale 1 "." ",") (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] (Just "9") (Just "−"))
    "−5.497.558.138,9"
-}
stringfy : Locale -> FormattedNumber -> String
stringfy locale formatted =
    let
        decimals : String
        decimals =
            case formatted.decimals of
                Just decimals ->
                    locale.decimalSeparator ++ decimals

                Nothing ->
                    ""
    in
        String.concat
            [ Maybe.withDefault "" formatted.prefix
            , String.join locale.thousandSeparator formatted.integers
            , decimals
            ]
