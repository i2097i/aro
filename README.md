# aro
>__a cli for tarot__ - follow the way of the aro eht.

##### __current version:__
[![gem version](https://badge.fury.io/rb/aro.svg)](https://badge.fury.io/rb/aro)

aro is a command line interface that allows you to manage multiple tarot decks.


### install

```bash
$ gem install aro
```

### use

```bash
$ aro -h
```

### develop

[rubygems.org guides](https://guides.rubygems.org)

```ruby
# the Rakefile contains bundler's gem_tasks,
# which are used for gem development.

# Rakefile
require "bundler/gem_tasks"
```

```bash
# list tasks
$ rake --tasks

# build gem
$ rake build

# build and install
$ rake install
```

### test

```bash
$ rspec
```

#### pre-commit hook:
```bash
: cat .git/hooks/pre-commit
#!/bin/sh

echo "running pre-commit hooks"
echo "exec rspec -f d -o ./spec/spec.log"
exec rspec -f d -o ./spec/spec.log
```

[license](http://opensource.org/licenses/MIT) [issues](https://github.com/i2097i/aro/issues)

>aro by i2097i is copyright (2025)
