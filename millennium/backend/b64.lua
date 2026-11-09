-- LuaJIT-compatible base64 encoder/decoder for the Millennium backend.
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local decode_map = {}
for index = 1, #alphabet do
    decode_map[alphabet:sub(index, index)] = index - 1
end

local b64 = {}

function b64.encode(data)
    if type(data) ~= "string" then error("base64 input must be a string") end
    local out = {}
    for offset = 1, #data, 3 do
        local first = data:byte(offset)
        local second = data:byte(offset + 1)
        local third = data:byte(offset + 2)
        local a = rshift(first, 2)
        local b = bor(lshift(band(first, 0x03), 4), rshift(second or 0, 4))
        local c = second and bor(lshift(band(second, 0x0f), 2), rshift(third or 0, 6))
        local d = third and band(third, 0x3f)
        out[#out + 1] = alphabet:sub(a + 1, a + 1)
        out[#out + 1] = alphabet:sub(b + 1, b + 1)
        out[#out + 1] = c and alphabet:sub(c + 1, c + 1) or "="
        out[#out + 1] = d and alphabet:sub(d + 1, d + 1) or "="
    end
    return table.concat(out)
end

function b64.decode(text)
    if type(text) ~= "string" then return nil end
    if text == "" then return "" end
    if #text % 4 ~= 0 or text:find("[^A-Za-z0-9+/=]") then return nil end
    local out = {}
    for offset = 1, #text, 4 do
        local c1, c2 = text:sub(offset, offset), text:sub(offset + 1, offset + 1)
        local c3, c4 = text:sub(offset + 2, offset + 2), text:sub(offset + 3, offset + 3)
        local n1, n2 = decode_map[c1], decode_map[c2]
        local n3 = c3 == "=" and nil or decode_map[c3]
        local n4 = c4 == "=" and nil or decode_map[c4]
        if n1 == nil or n2 == nil or (c3 ~= "=" and n3 == nil)
            or (c4 ~= "=" and n4 == nil) then return nil end
        if c3 == "=" and c4 ~= "=" then return nil end
        if (c3 == "=" or c4 == "=") and offset + 3 ~= #text then return nil end

        out[#out + 1] = string.char(bor(lshift(n1, 2), rshift(n2, 4)))
        if n3 ~= nil then
            out[#out + 1] = string.char(bor(lshift(band(n2, 0x0f), 4), rshift(n3, 2)))
        end
        if n4 ~= nil then
            out[#out + 1] = string.char(bor(lshift(band(n3, 0x03), 6), n4))
        end
    end
    return table.concat(out)
end

return b64
