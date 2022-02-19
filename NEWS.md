# fgdr 1.1.1

# fgdr 1.1.0

* Speed up `read_fgd_dem()` by using data.table for backend.
* Added support for terra format output with `read_fgd_dem()` 
* When a DEM file is read and returned as a df, a unit (meter) attribute is added to the elevation value.

## Bug fix

- Fix a XML element name discrepancy. ([#21](https://github.com/uribo/fgdr/issues/21)).

# fgdr 1.0.1

* Compatibility with dependent packages.

# fgdr 1.0.0

* `read_fdg()` and `read_fgd_dem()` always return JGD2011 (SRID: 6668).
* `read_fdg()` always return `sf` object regardless of what kind of file is given ([#7](https://github.com/uribo/fgdr/pull/7)).
* Change handling no data. It as `NA_real` instead of `-9999` ([#5](https://github.com/uribo/fgdr/issues/5)).
* `read_fgd_dem()`'s handling to fill up missing value cell improvement (@nonsabotage, [#3](https://github.com/uribo/fgdr/issues/3)).
* Added a `NEWS.md` file to track changes to the package.
