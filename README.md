# Type.lua

Lua typing module

## Introduction

As you see, lua doesn't have an Object-oriented system.

But sometimes, we want our code to be Rich typed. A module which could help us easily identify which `table` was `new` by which `table`. So that we need a type util or helper.

Currently, we have so much choices for this situation. Such like `30log`. \
But `30log` itself is not readable and it was just minify into 30 lines, which same as something like `.min.js`.

So `Type.lua` is invented for easily used and easily understand.

## Using `Type.lua`

Using `Type.lua`, you can get benefits below

### 1. Check type

Let's check `b` is a `Base`.

And check `d` is a `Derived` and also has ancestor `Base`.

```lua
local Base = {}

function Base.new()
  local o = {}

  -- You can also not to return Type.set
  -- in case if you wanna do something after
  -- Type.set(o, Base)

  return Type.set(o, Base)
end

local b = Base.new()

print(Type.is(b, Base)) -- Will print "true"
print(Type.get(b) == Base) -- Will also print "true"

local Derived = {}

function Derived()
  local o = {}

  return Type.set(o, Derived)
end

local d = Derived.new()

print(Type.is(d, Derived)) -- Will print "true"
print(Type.is(d, Base))    -- Will print "true", too
```

### 2. Initializers

```lua
local Base = {}

function Base.new()
  local o = {}

  -- Init attributes here
  o.n = 123

  Type.set(o, Base)

  -- Call initializer after Type.set
  o:init()

  return o
end

function Base:init()
  print("Base:init()")
end
```

### 3. Operator overloading

Something like C++ and Ruby. Coders can customizes the Lua operators for operands of user-defined types.

Such like using `def +(obj)` in Ruby and `T operator+(T const& obj)` in C++.

```lua
local Base = {}

function Base.new(n)
  local o = {}

  -- Init attributes here
  o.n = n

  return Type.set(o, Base, {
    add = function ( lhs, rhs, parent )
      return Base.new(lhs.n + rhs.n)
    end
  })
end

local b1 = Base.new(100)
print("b1.n =", b1.n) -- 100

local b2 = Base.new(200)
print("b2.n =", b2.n) -- 200

local b3 = b1 + b2
print("b3.n =", b3.n) -- 300
```

Now `Type.lua` can support 5 Operators to be overloaded:

* `add` Operator +
* `sub` Operator -
* `mul` Operator *
* `div` Operator /
* `concat` Operator ..

#### 3.1 Add Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @param parent any self.parent's add method
--- @return any Result to return
function add(lhs, rhs, parent)
end
```

#### 3.1 Sub Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @param parent any self.parent's sub method
--- @return any Result to return
function sub(lhs, rhs, parent)
end
```

#### 3.1 Mul Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @param parent any self.parent's mul method
--- @return any Result to return
function mul(lhs, rhs, parent)
end
```

#### 3.1 Div Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @param parent any self.parent's div method
--- @return any Result to return
function div(lhs, rhs, parent)
end
```

#### 3.1 Concat Operator interface

Concat interface is implemented for concat some string like objects.

```lua
--- @param str1 any Left number
--- @param str2 any Right number
--- @param parent any self.parent's concat method
--- @return any Result to return
function concat(str1, str2, parent)
end
```

### 4. Getter and Setter

Without getter and setter, you can't get private member defined in closure.

```lua
local Base = {}

function Base.new(n)
  -- Init private member here
  local prop = {n = n}
  local o = {}

  return Type.set(o, Base)
end

print("b1.n =", b1.n) -- nil
```

#### 4.1 Sample of Getter

You should overload `get` to fetch private members and return.

Interface `get`:

```lua
--- @param t any The self reference
--- @param k any Key
--- @param parent any self.parent's get method
--- @return any Result to return
function get(t, k, parent)
end
```

Example:

```lua
local Base = {}

function Base.new(n)
  -- Init private member here
  local prop = {n = n}
  local o = {}

  return Type.set(o, Base, {
    get = function ( t, k, parent )
      -- k == "n"
      -- return prop["n"]
      return prop[k]

      -- More correctly, You should also return parent's getter
      -- Otherwise, parent's member will hidden
      --
      -- return prop[k] or parent(t, k, p)
    end
  })
end

print("b1.n =", b1.n) -- nil
```

#### 4.2 Sample of Setter

And you can overload `set` to update private members.

Interface `set`:

```lua
--- @param t any The self reference
--- @param k any Key
--- @param v any Value
--- @param parent any self.parent's set method
function set(t, k, v, parent)
end
```

Example:

```lua
local Base = {}

function Base.new(n)
  -- Init private member here
  local prop = {n = n}
  local o = {}

  return Type.set(o, Base, {
    get = function ( t, k, p )
      return prop[k] or parent(t, k, p)
    end,
    set = function ( t, k, v, p )
      -- Avoid to set member which not exists
      -- Otherwise prop will add a new key [k] with value [v]
      prop[k] = prop[k] and v

      -- Calling parent's setter is alternative
      p(t, k, v, p)
    end
  })
end

print("b1.n =", b1.n) -- nil
```

## Q & A

Q: `Type.lua` is `Metatable Approach` or `Closure Approach`

A: Mixed.

If you have any question you can wrote me a ticket in Issue.

## License

This module is MIT-Licensed
