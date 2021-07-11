module FormatNumber.Stringfy exposing (formatDecimals, stringfy)

import FormatNumber.Locales exposing (Decimals(..), Locale)
import FormatNumber.Parser exposing (FormattedNumber)


{-| Stringify a `FormattedNumber`:

    import FormatNumber.Locales exposing (Locale, Decimals(..), System(..))
    import FormatNumber.Parser exposing (FormattedNumber)

    stringfy (Locale (Exact 3) Western "." "," "−" "" "" "" "" "") (FormattedNumber 3.1415 ["3"] "142" "" "")
    --> "3,142"

    stringfy (Locale (Exact 3) Western "." "," "−" "" "" "" "" "") (FormattedNumber -3.1415 ["3"] "142" "−" "")
    --> "−3,142"

    stringfy (Locale (Exact 0) Western "." "," "−" "" "" "" "" "") (FormattedNumber 1234567.89 ["1", "234", "568"] "" "" "")
    --> "1.234.568"

    stringfy (Locale (Exact 0) Western "." "," "−" "" "" "" "" "") (FormattedNumber 1234567.89 ["1", "234", "568"] "" "−" "")
    --> "−1.234.568"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "+" "" "" "") (FormattedNumber 999.9 ["999"] "9" "+" "")
    --> "+999,9"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "" "+" "" "") (FormattedNumber 999.9 ["999"] "9" "" "+")
    --> "999,9+"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "" "" "" "") (FormattedNumber 999.9 ["999"] "9" "−"  "")
    --> "−999,9"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "" "" "" "") (FormattedNumber 999.9 ["999"] "9" "−" "")
    --> "−999,9"

    stringfy (Locale (Exact 2) Western "." "," "−" "" "" "" "" "") (FormattedNumber 0.001 ["0"] "00" "" "")
    --> "0,00"

    stringfy (Locale (Exact 2) Western "." "," "−" "" "" "" "" "") (FormattedNumber 0.001 ["0"] "00" "" "")
    --> "0,00"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "" "" "" "") (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] "9" "" "")
    --> "5.497.558.138,9"

    stringfy (Locale (Exact 1) Western "." "," "−" "" "" "" "" "") (FormattedNumber 5497558138.88 ["5", "497", "558", "138"] "9" "−" "")
    --> "−5.497.558.138,9"

-}
stringfy : Locale -> FormattedNumber -> String
stringfy locale formatted =
    let
        integers : String
        integers =
            String.join locale.thousandSeparator formatted.integers

        stringfyDecimals : String -> String
        stringfyDecimals =
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
