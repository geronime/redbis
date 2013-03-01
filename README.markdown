# ReDBis - redis wrapper

+ [github project] (https://github.com/geronime/redbis)

ReDBis is simple redis wrapper to select database by name. ReDBis inherits
from Redis and provides some extra methods.

## DB naming

Naming is done by storing `{:name => :id}` into '`ReDBis::databases`' hash
in database #0.

## Usage

    require 'redbis'

### HiRedis

If you want to use [hiredis] (https://github.com/pietern/hiredis-rb)
it is necessary to install it:

    $ gem install hiredis

or include it in your `Gemfile`:

    gem 'hiredis', '~> 0.4.0'

It will be used automatically (with fallback to plain `redis` in case of
`LoadError`).

It is not included as dependency in gemspec because it does not build
on all systems yet (i.e. FreeBSD).

### Constructor

    r = ReDBis.new(o={})

The `ReDBis` class inherits from `Redis` and accepts two constructor options
on top:

+ `db` - select database with specified name (optional, default database
  with id #0 is selected by default)
+ `create` - whether to record a new database name if no such name is already
  registered (default `false`)

__It is recommended not to use the database with id #0 as the information about
the database names is stored there and `flushdb` would drop it.__

### Methods on top of Redis

#### db_current

Return `{:id => <id>, :name => <name>}` information about currently selected
database. `:name` is `nil` if the database was selected by its id and no name
is registered for it. It is always `nil` for db #0.

#### select

    r.select id

`ReDBis` overrides original `select` method in order to keep the track of the
currently selected database. Otherwise it is backward compatible (to select
the database by its id).

#### db_select

    r.db_select(name, create=false)

Select the database given its name.

If no such database name is already recorded:

+ raise an error for `create=false`,
+ record a new one with the lowest available db id otherwise (raise an error
  if all available db ids are already taken).

#### db_delete

    r.db_delete name

Delete the database with specified name or raise an error if no such name is
registered. The content of the specified database is flushed. Afterwards the
previously selected database is re-selected or database with id #0 is selected
if the name specified currently selected database.

#### db_delete!

Same as `db_delete` but rescue the exception raised if the specified name
is not registered. Returns `true`/`false` as the database was/was not deleted.

## Changelog

+ __0.0.3__: using optional hiredis instead of pure ruby connector
+ __0.0.2__: options passed to initialization method are not replaced
+ __0.0.1__: first revision

## License

ReDBis is copyright (c)2011 Jiri Nemecek, and released under the terms
of the MIT license. See the LICENSE file for the gory details.

