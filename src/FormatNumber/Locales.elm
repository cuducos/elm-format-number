module FormatNumber.Locales exposing (..)

{-|

These locales and its names are based on this
[International Language Environments
Guide](https://docs.oracle.com/cd/E19455-01/806-0169/overview-9/index.html)

@docs Locale

# Pre-defined locales

@docs frenchLocale, spanishLocale, usLocale

-}


{-| This is the `Locale` type and constructor.
-}
type alias Locale =
    { decimals : Int
    , thousandSeparator : String
    , decimalSeparator : String
    , negativePrefix : String
    , negativeSuffix : String
    }


{-| Locale used in France, Canada, Finland and Sweden. It has 3 decimals
digits, uses a thin space (`U+202F`) as thousand separator and a `,` as decimal
separator. It uses a minus sign (not a hyphen).
-}
frenchLocale : Locale
frenchLocale =
    Locale 3 "\x202F" "," "−" ""


{-| Locale used in Spain, Italy and Norway. It has 3 decimals digits, uses a
`.` as thousand separator and a `,` as decimal separator. It uses a minus sign
(not a hyphen).
-}
spanishLocale : Locale
spanishLocale =
    Locale 3 "." "," "−" ""


{-| Locale used in the United States, Great Britain and Thailand. It has 2
decimals digits, uses a `,` as thousand separator and a `.` as decimal
separator. It uses a minus sign (not a hyphen).
-}
usLocale : Locale
usLocale =
    Locale 2 "," "." "−" ""
