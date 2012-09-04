# rbs

**rbs** is a Ruby port of Python's [pbs](https://github.com/amoffat/pbs).

It tries to make shelling out easier and nicer.

## Quick Examples

**Query the en0 network interface:**

```ruby
require "rbs"
puts rbs.ifconfig "en0"
```

**Check gcc's version:**

```ruby
require "rbs"
puts rbs.gcc(:version).lines.first
```

**POST some JSON to an API:**

```ruby
require "rbs"
rbs.curl(:X, "POST", :"data-ascii", %{{"my":["example","json","document"]}})
```

## Features

* **rbs** supports importing certain commands into the global namespace:

  ```ruby
  require "rbs"
  rbs :echo
  echo "hello world"
  ```

* **rbs** tries to be smart about programs that have dashes in their names:

  ```ruby
  require "rbs"
  rbs.llvm_gcc # tries `llvm_gcc` first, and then tries `llvm-gcc`
  ```

* For programs with *really* funky names, you can use the `[]` operator:

  ```ruby
  require "rbs"
  rbs["ruby-1.9.3-p194", :version] # executes `ruby-1.9.3-p194 --version`
  ```

* **rbs** supports scopes, so if you'd like to run a bunch of commands as root:

  ```ruby
  require "rbs"
  rbs.sudo do
    puts rbs.whoami
    rbs.rm :r, :f, "/"
  end
  ```

* You can also pass a `Hash` into an **rbs** command and it will be decomposed into arguments:

  ```ruby
  require "rbs"
  rbs.configure prefix: "/usr/local", with_zlib_dir: "/path/to/zlib"
  # executes: `configure --prefix=/usr/local --with-zlib-dir=/path/to/zlib`
  ```