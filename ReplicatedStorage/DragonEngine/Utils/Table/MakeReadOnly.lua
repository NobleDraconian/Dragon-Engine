return setmetatable({}, {
    __index = tab,
    __newindex = function(tab, key, value)
        error("Attempt to modify read-only table")
    end,
    __metatable = false
});