# Elm Format Number

This simple [Elm](http://elm-lang.com) package formats numbers as pretty strings. It is flexible enough to deal with different number of decimals, different thousand separators and diffetent decimal separator.

## Usage

### From `Float` to `String`

```elm
formatFloat : Int -> String -> String -> Float -> String
```

Format a float number as a pretty string. The four arguments are: number of decimals, thousand separator, decimal separator and the float number itself.

```elm
formatFloat 2 "," "." 1234.5567 == "1,234.56"
formatFloat 3 "." "," -7654.3210 == "-7.654,321"
formatFloat 1 "," "." -0.01 == "0.0"
```

### From `Int` to `String`

```elm
formatInt : Int -> String -> String -> Int -> String
```

Format a float number as a pretty string. The four arguments are: number of decimals, thousand separator, decimal separator and the float number itself.

```elm
formatInt 1 "," "." 0 == "0.0"
formatInt 1 "," "." 1234567890 == "1,234,567,890.0"
```

## Tests

Requires [elm-doc-test](https://www.npmjs.com/package/elm-doc-test):

```console
$ elm-doc-test
$ elm-test init
$ elm-test tests/Doc/Main.elm
```
