# Elm Format Number

[![Build Status](https://travis-ci.org/lovasoa/elm-format-number.svg?branch=master)](https://travis-ci.org/lovasoa/elm-format-number)

This simple [Elm](http://elm-lang.com) package formats numbers as pretty strings. It is flexible enough to deal with different number of decimals, different thousand separators and diffetent decimal separator.

API documentation at
http://package.elm-lang.org/packages/lovasoa/elm-format-number/latest/FormatNumber

## Usage

### Creating a custom `Locale`

The `Locale` is a `type alias` to hold all the information to format your strings. For example:

```elm
defaultLocale : Locale
defaultLocale =
    { decimals = 2
    , thousandSeparator = ","
    , decimalSeparator = "."
    }
```

### From `Float` do `String`

```elm
formatFloat : Locale -> Float -> String
```

Format a `Float` number as a pretty string. For example, using the locale defined above:

```elm
formatFloat defaultLocale 1234.5567 == "1,234.56"
```

### From `Int` to `String`

```elm
formatInt : Locale -> Int -> String
```

Format a `Int` number as a pretty string. For example, using the locale defined above:

```elm
formatInt defaultLocale 0 == "0"
```

## Tests

Requires [elm-doc-test](https://www.npmjs.com/package/elm-doc-test):

```console
$ elm-doc-test
$ elm-test init
$ elm-test tests/Doc/Main.elm
```
