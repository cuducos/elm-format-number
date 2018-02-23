# Elm Format Number [![Build Status](https://circleci.com/gh/cuducos/elm-format-number.svg?style=shield)](https://circleci.com/gh/cuducos/elm-format-number)

This simple [Elm](http://elm-lang.com) package formats `float` numbers as pretty strings:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale, usLocale)

format usLocale (pi * 1000)  -- "3,141.59"
format spanishLocale (pi * 1000)  -- "3.141,59"
```

It is flexible enough to deal with different number of decimals, different thousand separators, different decimal separator, and different ways to represent negative numbers — all that is possible using `Locale`s.

Elm Format Number has a couple of predefined `Locale`s and it is easy to customize your own:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Locale, usLocale)

sharesLocale : Locale
sharesLocale =
    { usLocale
        | decimals = 3
        , negativePrefix = "("
        , negativeSuffix = ")"
    }

format usLocale -pi -- "−3.14"
format sharesLocale -pi -- "(3.142)"
```

The API is further documented in [package.elm-lang.org](http://package.elm-lang.org/packages/cuducos/elm-format-number/latest/FormatNumber).

## Tests

This package uses [elm-verify-examples](https://www.npmjs.com/package/elm-doc-test), all the examples in the documentation are automatically tested:

```console
$ npm install
$ npm test
```
