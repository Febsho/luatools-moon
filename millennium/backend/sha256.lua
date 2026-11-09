-- Pure LuaJIT SHA-256 for Millennium's LuaTools backend.
-- The same plugin also runs under Lumen, which provides a Lua 5.4 version of
-- this module globally. Millennium uses LuaJIT and has no built-in sha256.
local bit = require("bit")
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local bnot, lshift, rshift, tobit = bit.bnot, bit.lshift, bit.rshift, bit.tobit
local K = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function ror(x, n)
    return bor(rshift(x, n), lshift(x, 32 - n))
end

local function pack32(n)
    return string.char(
        band(rshift(n, 24), 0xff), band(rshift(n, 16), 0xff),
        band(rshift(n, 8), 0xff), band(n, 0xff))
end

local function pad(message)
    local bit_length = #message * 8
    local zeroes = (56 - (#message + 1) % 64) % 64
    local high = tobit(math.floor(bit_length / 0x100000000))
    local low = tobit(bit_length)
    return message .. string.char(0x80) .. string.rep("\0", zeroes)
        .. pack32(high) .. pack32(low)
end

local function add(...)
    local sum = 0
    for i = 1, select("#", ...) do sum = sum + select(i, ...) end
    return tobit(sum)
end

local function digest(message)
    message = message or ""
    local h = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    }
    local data = pad(message)
    local w = {}

    for base = 1, #data, 64 do
        for i = 0, 15 do
            local offset = base + i * 4
            w[i + 1] = bor(lshift(data:byte(offset), 24),
                lshift(data:byte(offset + 1), 16),
                lshift(data:byte(offset + 2), 8), data:byte(offset + 3))
        end
        for i = 17, 64 do
            local x, y = w[i - 15], w[i - 2]
            local s0 = bxor(bxor(ror(x, 7), ror(x, 18)), rshift(x, 3))
            local s1 = bxor(bxor(ror(y, 17), ror(y, 19)), rshift(y, 10))
            w[i] = add(w[i - 16], s0, w[i - 7], s1)
        end

        local a, b, c, d = h[1], h[2], h[3], h[4]
        local e, f, g, hh = h[5], h[6], h[7], h[8]
        for i = 1, 64 do
            local s1 = bxor(bxor(ror(e, 6), ror(e, 11)), ror(e, 25))
            local choose = bxor(band(e, f), band(bnot(e), g))
            local t1 = add(hh, s1, choose, K[i], w[i])
            local s0 = bxor(bxor(ror(a, 2), ror(a, 13)), ror(a, 22))
            local majority = bxor(bxor(band(a, b), band(a, c)), band(b, c))
            local t2 = add(s0, majority)
            hh, g, f, e = g, f, e, add(d, t1)
            d, c, b, a = c, b, a, add(t1, t2)
        end

        h[1], h[2], h[3], h[4] = add(h[1], a), add(h[2], b), add(h[3], c), add(h[4], d)
        h[5], h[6], h[7], h[8] = add(h[5], e), add(h[6], f), add(h[7], g), add(h[8], hh)
    end

    local chunks = {}
    for i = 1, 8 do chunks[i] = pack32(h[i]) end
    return table.concat(chunks)
end

local sha256 = { digest = digest }
function sha256.hex(message)
    return (digest(message):gsub(".", function(char)
        return string.format("%02x", char:byte())
    end))
end

return sha256
