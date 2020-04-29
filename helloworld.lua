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
