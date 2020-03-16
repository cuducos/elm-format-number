# Elm Format Number [![Build Status](https://circleci.com/gh/cuducos/elm-format-number.svg?style=shield)](https://circleci.com/gh/cuducos/elm-format-number)

This simple [Elm](https://elm-lang.org) package formats `Float` numbers as pretty strings.

## Format

The `format` function formats `Float` numbers using a locale with settings:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale, usLocale)

format usLocale (pi * 1000)  --> "3,141.59"
format spanishLocale (pi * 1000)  --> "3.141,593"
```

It is flexible enough to deal with different number of decimals, different thousand separators, different decimal separator, and different ways to represent negative numbers — all that is possible using `Locale`s.

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Locale, usLocale, Decimals(..))

sharesLocale : Locale
sharesLocale =
    { usLocale
        | decimals = Exact 3
        , negativePrefix = "("
        , negativeSuffix = ")"
    }

format usLocale -pi --> "−3.14"
format sharesLocale -pi --> "(3.142)"
```

## Humanize

The `humanize` function limits the number of decimals according to the `Locale` but may remove zeros from the tail in order to make it more humam readable. The `RemoveZero` removes any tail `0` from the result, while `KeepZeros` only remove decimals if _all_ decimal digits are `0`:

```elm
import FormatNumber exposing (humanize)
import FormatNumber.Humanize exposing (ZeroStrategy(..))
import FormatNumber.Locales exposing (usLocale)

humanize usLocale RemoveZeros 10.00 --> "10"
humanize usLocale RemoveZeros 10.10 --> "10.1"

humanize usLocale KeepZeros 10.00 --> "10"
humanize usLocale KeepZeros 10.10 --> "10.10"
```

## Docs

The API is further documented in [package.elm-lang.org](http://package.elm-lang.org/packages/cuducos/elm-format-number/latest/FormatNumber).

## Tests

This package uses [elm-verify-examples](https://www.npmjs.com/package/elm-verify-examples), all the examples in the documentation are automatically tested:

```console
$ npm install
$ npm test
```
