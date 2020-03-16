module Stringfy exposing (formatDecimals, humanizeDecimals, stringfy)

import FormatNumber.Humanize exposing (ZeroStrategy(..))
import FormatNumber.Locales exposing (Decimals(..), Locale)
import Parser exposing (FormattedNumber)


{-| Stringify a `FormattedNumber`:

    import FormatNumber.Humanize exposing (ZeroStrategy(..))
    import FormatNumber.Locales exposing (Locale)
    import Parser exposing (FormattedNumber)

    stringfy (Locale 3 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 3.1415 ["3"] "142" "" "")
    --> "3,142"

    stringfy (Locale 3 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber -3.1415 ["3"] "142" "−" "")
    --> "−3,142"

    stringfy (Locale 0 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 1234567.89 ["1", "234", "568"] "" "" "")
    --> "1.234.568"

    stringfy (Locale 0 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 1234567.89 ["1", "234", "568"] "" "−" "")
    --> "−1.234.568"

    stringfy (Locale 1 "." "," "−" "" "+" "" "" "") Nothing (FormattedNumber 999.9 ["999"] "9" "+" "")
    --> "+999,9"

    stringfy (Locale 1 "." "," "−" "" "" "+" "" "") Nothing (FormattedNumber 999.9 ["999"] "9" "" "+")
    --> "999,9+"

    stringfy (Locale 1 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 999.9 ["999"] "9" "−"  "")
    --> "−999,9"

    stringfy (Locale 1 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 999.9 ["999"] "9" "−" "")
    --> "−999,9"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 0.001 ["0"] "00" "" "")
    --> "0,00"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 0.001 ["0"] "00" "" "")
    --> "0,00"

    stringfy (Locale 1 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] "9" "" "")
    --> "5.497.558.138,9"

    stringfy (Locale 1 "." "," "−" "" "" "" "" "") Nothing (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] "9" "−" "")
    --> "−5.497.558.138,9"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") (Just KeepZeros) (FormattedNumber 10.0 ["10"] "00" "" "")
    --> "10"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") (Just KeepZeros) (FormattedNumber 10.1 ["10"] "10" "" "")
    --> "10,10"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") (Just RemoveZeros) (FormattedNumber 10.0 ["10"] "00" "" "")
    --> "10"

    stringfy (Locale 2 "." "," "−" "" "" "" "" "") (Just RemoveZeros) (FormattedNumber 10.1 ["10"] "10" "" "")
    --> "10,1"

-}
stringfy : Locale -> Maybe ZeroStrategy -> FormattedNumber -> String
stringfy locale strategy formatted =
    let
        integers : String
        integers =
            String.join locale.thousandSeparator formatted.integers

        stringfyDecimals : String -> String
        stringfyDecimals =
            case strategy of
                Just strategy_ ->
                    humanizeDecimals locale strategy_

                Nothing ->
                    formatDecimals locale

        decimals : String
        decimals =
            stringfyDecimals formatted.decimals
    in
    String.concat [ formatted.prefix, integers, decimals, formatted.suffix ]


formatDecimals : Locale -> String -> String
formatDecimals locale decimals =
    if decimals == "" then
        ""

    else
        locale.decimalSeparator ++ decimals


{-| Remove all zeros from the tail of a string.
-}
removeZeros : String -> String
removeZeros decimals =
    if String.right 1 decimals /= "0" then
        decimals

    else
        decimals
            |> String.dropRight 1
            |> removeZeros


humanizeDecimals : Locale -> ZeroStrategy -> String -> String
humanizeDecimals locale strategy decimals =
    case locale.decimals of
        Min _ ->
            locale.decimalSeparator ++ decimals

        Max max ->
            if decimals == "" || String.repeat max "0" == decimals then
                ""

            else
                case strategy of
                    KeepZeros ->
                        locale.decimalSeparator ++ decimals

                    RemoveZeros ->
                        decimals
                            |> removeZeros
                            |> formatDecimals locale

        Exact _ ->
            if decimals == "" then
                ""

            else
                case strategy of
                    KeepZeros ->
                        locale.decimalSeparator ++ decimals

                    RemoveZeros ->
                        decimals
                            |> removeZeros
                            |> formatDecimals locale
