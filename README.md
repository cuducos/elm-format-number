# Elm Format Number [![Build Status](https://travis-ci.org/cuducos/elm-format-number.svg?branch=master)](https://travis-ci.org/cuducos/elm-format-number)


This simple [Elm](http://elm-lang.com) package formats `float` numbers as pretty strings:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale)

format spanishLocale (pi * 1000)  -- "3.141,59"
```

It is flexible enough to deal with different number of decimals, different thousand separators and diffetent decimal separator. It has a couple os predefined `Locale` but you can edit them or create your own:

```elm
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Locale)

myLocale : Locale
myLocale =
    { decimals = 4
    , thousandSeparator = " "
    , decimalSeparator = "."
    }
    
sharesLocale : Locale
sharesLocale = { myLocale | decimals = 3 }

format myLocale (pi * 1000) -- "3 141.5926"
format sharesLocale (pi * 1000) -- "3 141.593"



```

The API is further documented in [package.elm-lang.org](http://package.elm-lang.org/packages/cuducos/elm-format-number/latest/FormatNumber).

## Tests

This package uses [elm-doc-test](https://www.npmjs.com/package/elm-doc-test), all the exemples in the documentation are automatically tested:

```console
$ yarn install
$ yarn test
```
