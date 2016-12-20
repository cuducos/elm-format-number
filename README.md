# Elm Format Number

This simple [Elm](http://elm-lang.com) package formats numbers as pretty strings. It is flexible enough to deal with different number of decimals, different thousand separators and diffetent decimal separator.

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

alternativeLocale : Locale
alternativeLocale =
    { decimals = 3
    , thousandSeparator = "."
    , decimalSeparator = ","
    }

yetAnotherLocale : Locale
yetAnotherLocale =
    { decimals = 1
    , thousandSeparator = ""
    , decimalSeparator = "."
    }
```

### From `Float` do `String`

```elm
formatFloat : Locale -> Float -> String
```

Format a `Float` number as a pretty string. For example, using the locales defined above:

```elm
formatFloat defaultLocale 1234.5567 == "1,234.56"
formatFloat alternativeLocale -7654.3210 == "-7.654,321"
formatFloat yetAnotherLocale -0.01 == "0.0"
```

### From `Int` to `String`

```elm
formatInt : Locale -> Int -> String
```

Format a `Int` number as a pretty string. For example, using the locales defined above:

```elm
formatInt defaultLocale 0 == "0.00"
formatInt defaultLocale 1234567890 == "1,234,567,890.0"
```

## Tests

Requires [elm-doc-test](https://www.npmjs.com/package/elm-doc-test):

```console
$ elm-doc-test
$ elm-test init
$ elm-test tests/Doc/Main.elm
```
