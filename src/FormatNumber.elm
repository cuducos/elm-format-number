module FormatNumber exposing (format)

{-| This simple package formats `Float` numbers as pretty strings. It is
flexible enough to deal with different number of decimals, different thousand
separators and different decimal separator.

@docs format

## What about `Int` numbers?

Just convert them to `Float` before passing them to `format`:

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format usLocale (toFloat 1234)
    "1,234.00"

    >>> import FormatNumber.Locales exposing (usLocale)
    >>> format { usLocale | decimals = 0 } <| toFloat 1234
    "1,234"

-}

import Helpers
import FormatNumber.Locales as Locales


{-| Format a float number as a pretty string:

    import FormatNumber.Locales exposing (Locale, frenchLocale, spanishLocale, usLocale)

    format { decimals = 2, thousandSeparator = ".", decimalSeparator = ",", negativePrefix = "−", negativeSuffix = "" } 123456.789
    --> "123.456,79"

    format { decimals = 2, thousandSeparator = ",", decimalSeparator = ".", negativePrefix = "−", negativeSuffix = "" } 1234.5567
    --> "1,234.56"

    format (Locale 3 "." "," "−" "") -7654.3210
    --> "−7.654,321"

    format (Locale 1 "," "." "−" "") -0.01
    --> "0.0"

    format (Locale 2 "," "." "−" "") 0.01
    --> "0.01"

    format (Locale 0 "," "." "−" "") 123.456
    --> "123"

    format (Locale 0 "," "." "−" "") 1e9
    --> "1,000,000,000"

    format (Locale 5 "," "." "−" "") 1.0
    --> "1.00000"

    format (Locale 2 "," "." "(" ")") -1.0
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

-}
format : Locales.Locale -> Float -> String
format locale num =
    Helpers.stringfy <| Helpers.parse locale num
