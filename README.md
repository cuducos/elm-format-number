# Elm Format Number ![Build](https://github.com/cuducos/elm-format-number/workflows/Build/badge.svg)

This simple [Elm](https://elm-lang.org) package formats `Float` numbers as pretty strings.

## Format

The `format` function formats `Float` numbers using a locale with settings:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale, usLocale)

format usLocale (pi * 1000)  --> "3,141.59"
format spanishLocale (pi * 1000)  --> "3.141,593"
```

It is flexible enough to deal with different number of decimals, different thousand separators, different decimal separator, and different ways to represent negative numbers — all that is possible using `Locale`s. The `base` locale matches Elm's native `String.fromFloat` using unicode minus (`U+2212`) instead of an hyphen/dash.

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), Locale, usLocale)

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

### The `Decimals` strategy type

`Decimals` type contains different strategies for handling the number of decimals when formatting the number.

* `Min Int` shows at least a certain amount of decimal digits, adding trailing zeros if needed.
* `Max Int` shows up to a certain amount of decimal digits, discarding trailing zeros if needed.
* `Exact Int` shows an exact number of decimal digits, adding trailing zeros if needed.

## Docs

The API is further documented in [package.elm-lang.org](http://package.elm-lang.org/packages/cuducos/elm-format-number/latest/FormatNumber).

## Tests

This package uses [elm-verify-examples](https://www.npmjs.com/package/elm-verify-examples), all the examples in the documentation are automatically tested:

```console
$ npm install
$ npm test
```
