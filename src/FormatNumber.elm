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

import FormatNumber.Locales as Locales
import FormatNumber.Parser exposing (parse)
import FormatNumber.Stringfy exposing (stringfy)


{-| Format a float number as a pretty string:

    import FormatNumber.Locales exposing (Decimals(..), Locale, System(..), frenchLocale, spanishLocale, usLocale)

    format { decimals = Exact 2, system = Western, thousandSeparator = ".", decimalSeparator = ",", negativePrefix = "−", negativeSuffix = "", positivePrefix = "", positiveSuffix = "", zeroPrefix = "", zeroSuffix = "" } 123456.789
    --> "123.456,79"

    format { decimals = Exact 2, system = Western, thousandSeparator = ",", decimalSeparator = ".", negativePrefix = "−", negativeSuffix = "", positivePrefix = "", positiveSuffix = "", zeroPrefix = "", zeroSuffix = "" } 1234.5567
    --> "1,234.56"

    format (Locale (Exact 3) Western "." "," "−" "" "" "" "" "") -7654.3210
    --> "−7.654,321"

    format (Locale (Exact 1) Western "," "." "−" "" "" "" "" "") -0.01
    --> "0.0"

    format (Locale (Exact 2) Western "," "." "−" "" "" "" "" "") 0.01
    --> "0.01"

    format (Locale (Exact 0) Western "," "." "−" "" "" "" "" "") 123.456
    --> "123"

    format (Locale (Exact 0) Western "," "." "−" "" "" "" "" "") 1e9
    --> "1,000,000,000"

    format (Locale (Exact 5) Western "," "." "−" "" "" "" "" "") 1.0
    --> "1.00000"

    format (Locale (Exact 2) Western "," "." "(" ")" "" "" "" "") -1.0
    --> "(1.00)"

    format usLocale pi
    --> "3.14"

    format { frenchLocale | decimals = Exact 4 } pi
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

    format (Locale (Exact 3) Western "." "," "−" "" "" "" "" "") 123
    --> "123,000"

    format (Locale (Min 3) Western "." "," "−" "" "" "" "" "") 123.45678
    --> "123,45678"

    format (Locale (Min 0) Western "." "," "−" "" "" "" "" "") 1230
    --> "1.230"

    format (Locale (Min 3) Western "." "," "−" "" "" "" "" "") 123.45600
    --> "123,456"

    format (Locale (Min 3) Western "." "," "−" "" "" "" "" "") 123.456001
    --> "123,456001"

    format (Locale (Max 3) Western "." "," "−" "" "" "" "" "") 123.45678
    --> "123,457"

    format (Locale (Max 3) Western "." "," "−" "" "" "" "" "") 123.45633
    --> "123,456"

    format (Locale (Max 3) Western "." "," "−" "" "" "" "" "") 123.45600
    --> "123,456"

    format (Locale (Max 3) Western "." "," "−" "" "" "" "" "") 123.45
    --> "123,45"

    format (Locale (Max 3) Western "." "," "−" "" "" "" "" "") 123
    --> "123"

    format { usLocale | system = Indian } 7.34767309e22
    --> "73,47,67,30,90,00,00,00,00,00,000.00"

    format { usLocale | system = Indian } 75
    --> "75.00"

-}
format : Locales.Locale -> Float -> String
format locale number_ =
    number_
        |> parse locale
        |> stringfy locale
