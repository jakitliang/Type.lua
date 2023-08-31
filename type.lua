--- Type.lua
--- A simple and tiny Rich Type Programming module
--- @author Jakit Liang
--- @date 2023-08-31
--- @license MIT

--- The Type module
--- @class Type
local Type = {}

--- Get type of the instance
--- @param obj table Instance object
--- @return table obj of the instance
Type.get = function (obj)
  return obj.__type
end

--- Bind arguments to a funtion
--- @param func function Function to be bind
--- @param ... any Anything you wanna bind
--- @return function
Type.bind = function (func, ...)
  local function packn(...)
    return {n = select('#', ...), ...}
  end

  local function unpackn(t)
    return (table.unpack or unpack)(t, 1, t.n)
  end

  local function mergen(...)
    local res = {n = 0}
    for i = 1, select('#', ...) do
      local t = select(i, ...)
      for j = 1, t.n do
        res.n = res.n + 1
        res[res.n] = t[j]
      end
    end
    return res
  end

  local args = packn(...)
  return function (...)
    return func(unpackn(mergen(args, packn(...))))
  end
end

--- Set object point to type
--- @param obj table Instance object
--- @param _type table Target type
--- @param meta table|nil Metatable to be set
--- @return table obj Configured object
Type.set = function (obj, _type, meta)
  obj.__type = _type
  local baseMeta = getmetatable(obj)
  local newMeta = {}
  if baseMeta then
    for k, v in pairs(baseMeta) do
      newMeta[k] = newMeta[k] or baseMeta[k]
    end
  end
  -- Index (Must update to current _type)
  if meta and meta.get then
    newMeta.__index = function (t, k)
      return _type[k] or meta.get(t, k, baseMeta and baseMeta.__index)
    end
  else
    newMeta.__index = function (t, k)
      -- Find class method
      return _type[k]
    end
  end
  if meta == nil then
    return setmetatable(obj, newMeta)
  end
  if meta.set then
    newMeta.__newindex = function (t, k, v)
      -- Note: If key is exists, then __newindex will not call
      -- So self:functions in table will not be affected

      return t[k] == nil and rawset(t, k, v)
      or meta.set(t, k, v, baseMeta and baseMeta.__newindex)
    end
  end
  if meta.add then
    newMeta.__add = function (lhs, rhs)
      return meta.add(lhs, rhs, baseMeta and baseMeta.__add)
    end
  end
  if meta.sub then
    newMeta.__sub = function (lhs, rhs)
      return meta.sub(lhs, rhs, baseMeta and baseMeta.__sub)
    end
  end
  if meta.mul then
    newMeta.__mul = function (lhs, rhs)
      return meta.mul(lhs, rhs, baseMeta and baseMeta.__mul)
    end
  end
  if meta.div then
    newMeta.__div = function (lhs, rhs)
      return meta.div(lhs, rhs, baseMeta and baseMeta.__div)
    end
  end
  if meta.concat then
    newMeta.__concat = function (lhs, rhs)
      return meta.concat(lhs, rhs, baseMeta and baseMeta.__concat)
    end
  end
  return setmetatable(obj, newMeta)
end

--- Make the child type inherit to the parent type
--- @param child table Child type
--- @param parent table Parent type
Type.extends = function (child, parent)
  Type[child] = parent
end

--- Check if object is an instance of target type
--- @param obj table Instance object
--- @param _type table Target type
--- @return boolean bool The check result
Type.is = function (obj, _type)
  if type(obj) ~= "table" then
    return false
  end

  local _t = obj.__type
  if _t == _type then
    return true
  end

  while Type[_t] do
    if Type[_t] == _type then
      return true
    end
    _t = Type[_t]
  end

  return false
end

--- Get metatable into a new table
--- @param o table Object to get metatable
--- @return table metatable
Type.getMetatable = function (o)
  local mt = {}
  local _ = getmetatable(o)
  if _ == nil then
    return mt
  end
  for k, v in pairs(_) do
    mt[k] = v
  end
  return mt
end

return Type
