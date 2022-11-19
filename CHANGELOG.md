# 2.0.0
* Fixed `Bigdecimal` casting with high precision
* Added nested `type casting like Array(Array(Array(Nullable(T))))`
* Added `Map(T1, T2)` support
* Added `Tuple(T1, T2)` support
* Added support for `Faraday` v1 and v2
* Added support for `Oj` parser

# 1.6.3
* [PR](https://github.com/shlima/click_house/pull/38) Add option format for insert
* [PR](https://github.com/shlima/click_house/pull/34) Support X-ClickHouse-Exception-Code header
* [ISSUE](https://github.com/shlima/click_house/issues/33) Fix parameterized types parsing
* Added LowCardinality DDL support
* Fixed body logging with POST queries

# 1.6.2
* [PR](https://github.com/shlima/click_house/pull/31) Add rows_before_limit_at_least to ResultSet
* [PR](https://github.com/shlima/click_house/pull/29) Force JSON format by using "default_format" instead of modifying the query

# 1.6.1
* [PR](https://github.com/shlima/click_house/pull/26) call logging middleware when an error is raised

# 1.6.0
* [PR](https://github.com/shlima/click_house/pull/19) handle value returned as nil in float and integer types (case of Aggregate Function Combinators) 
* [PR](https://github.com/shlima/click_house/pull/18) Fix Faraday deprecation

# 1.5.0
* add support for 'WITH TOTALS' modifier in response
* send SQL in GET request's body [#12](https://github.com/shlima/click_house/pull/12)
* add support of 'WITH TOTALS' on a resulting set

# 1.4.0
* fix decimal type casting [#11](https://github.com/shlima/click_house/issues/11)

# 1.3.9
* add `ClickHouse.connection.add_index`, `ClickHouse.connection.drop_index`

# 1.3.8
* fix `DateTime` casting for queries like `ClickHouse.connection.select_value('select NOW()')` 
* fix resulting set console inspection

# 1.3.7
* specify required ruby version [#10](https://github.com/shlima/click_house/issues/10)

# 1.3.6
* fix ruby 2.7 warning `maybe ** should be added to the call` on `ClickHouse.connection.databases`

# 1.3.5
* added `ClickHouse.connection.explain("sql")` 

# 1.3.4
* added `ClickHouse.type_names(nullable: false)`
* fixed `connection#create_table` column definitions
* `ClickHouse.add_type` now handles Nullable types automatically

# 1.3.3
* fix logger typo

# 1.3.2
* fix null logger for windows users

# 1.3.1
* added request [headers](https://github.com/shlima/click_house/pull/8) support

# 1.3.0
* added support for IPv4/IPv6 types

# 1.2.7
* rubocop version bump

# 1.2.6
* Datetime64 field type support [#3](https://github.com/shlima/click_house/pull/3)
