-- comments are denoted like this

print(1 + 1 + 1)
print(1 + 1)
print(1)
print("Hello world!")


-- boolean data type
a = true
print(type(a))

-- all numbers are numbers like in R
b = 5.5
c = 8888023023948234234
d = -27.73045720394867230495872
e = tonumber("2325.85985") -- string to number

print(type(b) .. " " .. b)
print(type(c) .. " " .. c)
print(type(d) .. " " .. d)
print(type(e) .. " " .. e)


-- string data type
print(type("hello") .. ' "hello"') -- free to use ' and " interchangeably like in R / python
print(type(tostring(23950)) .. " tostring(23950)")


-- null is 'nil' in lua
b = nil
collectgarbage() -- happens automatically but can be forced. deletes nil vars

-- functions are declared to vars like in R
-- I guess lua was a big inspiration for R?
squareemup = function(x) return x*x end
print(squareemup(5))

getdistance = function(x1, y1, x2, y2)
    print("you've entered the super-duper distance calculation function!")
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- arf no real support for named arguments T_T
-- but we can use comments as in Java
print(getdistance(
        --[[ x1: ]] 5,
        --[[ y1: ]] 7,
        --[[ x2: ]] 22,
        --[[ y2: ]] 24))

-- the "swap" operation we've seen in python apparently
-- also came from lua
a = 2
b = 3
b, a = a, b
print(a .. " <- should now be 3 after we swapped")


-- the "table" data type has the functionalities of arrays and dictionaries
somenumbers = {7, 2, 4, 20}
print(type(somenumbers))
print(somenumbers)  -- prints info about the memory address (i think), not about the table

print("somenumbers[1] is " .. somenumbers[1] .. " because in lua the first index is 1")

scores = {}
print(type(scores))


scores.jelle = 10
scores.joe = 5
scores.hero = 0
print(type(scores)) -- still a table

print(scores.jelle) -- returns 10
scores.jelle = nil

-- this is just like enumerate() in python
-- maybe this was the inspiration or maybe it
-- already existed before lua
-- however, we MUST use iterators, this is the 
-- standard for loop even if we're not interested
-- in the index or key of our table
for _, number in ipairs(somenumbers) do
    print(number)
end

-- From the docs;
-- Tables are the sole data-structuring mechanism in Lua;
-- they can be used to represent ordinary arrays, lists,
--  symbol tables, sets, records, graphs, trees, etc. 
-- To represent records, Lua uses the field name as an index.
-- The language supports this representation by providing
-- a.name as syntactic sugar for a["name"]. There are several
-- convenient ways to create tables in Lua (see §3.4.9).

-- A table in Lua is an object in more than one sense.
-- Like objects, tables have a state. Like objects, 
-- tables have an identity (a selfness) that is independent
-- of their values; specifically, two objects (tables) with
-- the same value are different objects, whereas an object
-- can have different values at different times, but it is always
-- the same object. Like objects, tables have a life cycle that 
-- is independent of who created them or where they were created.

-- tables also serve as objects in lua
-- this is one of the syntaxes, you can also specify the 'self'
-- argument explicitly but then you have to pass it every time
-- you call the method which seems worse
Account = {balance = 0}
    function Account:withdraw (v)
        self.balance = self.balance - v
    end

Account.balance = 50
Account:withdraw(5)                 -- syntax 1
Account.withdraw(Account, 5)        -- syntax 2
print(Account.balance)

-- and keeping with the theme of tables being everything,
-- we can also make it serve as a class by giving it 
-- a constructor
MoveableObject = {xPos = 0, yPos = 0}
    function MoveableObject:shoot (v)
        print("pewpewpew")
    end
    function MoveableObject:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)  -- make o inherit functions from MoveableObject
      self.__index = self  -- no idea what this does
      return o
    end

player = MoveableObject:new({xPos = 10, yPos = 10})
enemy = MoveableObject:new()

player:shoot()
print(player.xPos)
print(player.yPos)
enemy:shoot()
