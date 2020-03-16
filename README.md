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

It is flexible enough to deal with different number of decimals, different thousand separators, different decimal separator, and different ways to represent negative numbers — all that is possible using `Locale`s. `base` locale matches String.fromFloat using unicode minus (U+2212) − instead of hyphen/dash -.

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

### Decimals

`Decimals` type contains different strategies for handling the number of decimals when formatting the number.

1. `Min Int` - will show at least a certain amount of decimal digits, adding trailing zeros if needed
2. `Max Int` - will show up to a certain amount of decimal digits, discarding trailing zeros if needed
3. `Exact Int` - will show an exact number of decimal digits, adding trailing zeros if needed

## Docs

The API is further documented in [package.elm-lang.org](http://package.elm-lang.org/packages/cuducos/elm-format-number/latest/FormatNumber).

## Tests

This package uses [elm-verify-examples](https://www.npmjs.com/package/elm-verify-examples), all the examples in the documentation are automatically tested:

```console
$ npm install
$ npm test
```
