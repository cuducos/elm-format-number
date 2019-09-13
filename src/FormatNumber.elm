module FormatNumber exposing
    ( format
    , humanize
    )

{-| This simple package formats `Float` numbers as pretty strings. It is
flexible enough to deal with different number of decimals, different thousand
separators and different decimal separator.

@docs format

It also `humanize`s decimals numbers with different strategies for handling zeros:

@docs humanize


## What about `Int` numbers?

Just convert them to `Float` before passing them to `format`:

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format usLocale (toFloat 1234)
    "1,234.00"

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format { usLocale | decimals = 0 } <| toFloat 1234
    "1,234"

-}

import FormatNumber.Humanize exposing (ZeroStrategy(..))
import FormatNumber.Locales as Locales
import Parser exposing (parse)
import Stringfy exposing (stringfy)


{-| Format a float number as a pretty string:

    import FormatNumber.Locales exposing (Locale, frenchLocale, spanishLocale, usLocale)

    format { decimals = 2, thousandSeparator = ".", decimalSeparator = ",", negativePrefix = "−", negativeSuffix = "", positivePrefix = "", positiveSuffix = "", zeroPrefix = "", zeroSuffix = "" } 123456.789
    --> "123.456,79"

    format { decimals = 2, thousandSeparator = ",", decimalSeparator = ".", negativePrefix = "−", negativeSuffix = "", positivePrefix = "", positiveSuffix = "", zeroPrefix = "", zeroSuffix = "" } 1234.5567
    --> "1,234.56"

    format (Locale 3 "." "," "−" "" "" "" "" "") -7654.3210
    --> "−7.654,321"

    format (Locale 1 "," "." "−" "" "" "" "" "") -0.01
    --> "0.0"

    format (Locale 2 "," "." "−" "" "" "" "" "") 0.01
    --> "0.01"

    format (Locale 0 "," "." "−" "" "" "" "" "") 123.456
    --> "123"

    format (Locale 0 "," "." "−" "" "" "" "" "") 1e9
    --> "1,000,000,000"

    format (Locale 5 "," "." "−" "" "" "" "" "") 1.0
    --> "1.00000"

    format (Locale 2 "," "." "(" ")" "" "" "" "") -1.0
    --> "(1.00)"

    format usLocale pi
    --> "3.14"

    format { frenchLocale | decimals = 4 } pi
    --> "3,1416"

    format frenchLocale 67295
    --> "67 295,000"

    format spanishLocale e
    --> "2,718"

    format spanishLocale 67295
    --> "67.295,000"

    format usLocale 67295
    --> "67,295.00"

    format spanishLocale -0.1
    --> "−0,100"

    format spanishLocale -0.00099
    --> "−0,001"

    format usLocale 1e10
    --> "10,000,000,000.00"

    format usLocale -1e10
    --> "−10,000,000,000.00"

    format { usLocale | negativePrefix = "-" } -1.0
    --> "-1.00"

    format { usLocale | positivePrefix = "+" } 1.0
    --> "+1.00"

    format { usLocale | positiveSuffix = "+" } 1.0
    --> "1.00+"

    format usLocale 7.34767309e22
    --> "73,476,730,900,000,000,000,000.00"

    format usLocale 7.34767309e+22
    --> "73,476,730,900,000,000,000,000.00"

    format usLocale 7.34767309e-22
    --> "0.00"

-}
format : Locales.Locale -> Float -> String
format locale number_ =
    number_
        |> Parser.parse locale
        |> Stringfy.stringfy locale Nothing


{-| Humanize the decimal part of a float with different strategies to remove
tail zeros:

    import FormatNumber exposing (humanize)
    import FormatNumber.Humanize exposing (ZeroStrategy(..))
    import FormatNumber.Locales exposing (usLocale)

    humanize usLocale RemoveZeros 10.00
    --> "10"
    humanize usLocale RemoveZeros 10.10
    --> "10.1"

    humanize usLocale KeepZeros 10.00
    --> "10"
    humanize usLocale KeepZeros 10.10
    --> "10.10"

-}
humanize : Locales.Locale -> ZeroStrategy -> Float -> String
humanize locale strategy number_ =
    number_
        |> parse locale
        |> stringfy locale (Just strategy)
