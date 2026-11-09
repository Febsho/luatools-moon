package.path = "./millennium/backend/?.lua;" .. package.path

local sha256 = require("sha256")

assert(sha256.hex("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
assert(sha256.hex("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
assert(#sha256.digest("abc") == 32)

print("LuaJIT SHA-256 test passed")
