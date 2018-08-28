module FormatNumber.Locales exposing
    ( Locale
    , frenchLocale, spanishLocale, usLocale
    )

{-| These locales and its names are based on this
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
    , positivePrefix : String
    , positiveSuffix : String
    }


{-| Locale used in France, Canada, Finland and Sweden. It has 3 decimals
digits, uses a thin space (`U+202F`) as thousand separator and a `,` as decimal
separator. It uses a minus sign (not a hyphen) as a prefix for negative
numbers, but no sufix or prefix for positive numbers.
-}
frenchLocale : Locale
frenchLocale =
    Locale 3 "\u{202F}" "," "−" "" "" ""


{-| Locale used in Spain, Italy and Norway. It has 3 decimals digits, uses a
`.` as thousand separator and a `,` as decimal separator. It uses a minus sign
(not a hyphen) as a prefix for negative numbers, but no sufix or prefix for
positive numbers.
-}
spanishLocale : Locale
spanishLocale =
    Locale 3 "." "," "−" "" "" ""


{-| Locale used in the United States, Great Britain and Thailand. It has 2
decimals digits, uses a `,` as thousand separator and a `.` as decimal
separator. It uses a minus sign (not a hyphen) as a prefix for negative
numbers, no sufix or prefix for positive numbers.
-}
usLocale : Locale
usLocale =
    Locale 2 "," "." "−" "" "" ""
