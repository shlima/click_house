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
