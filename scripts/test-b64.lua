package.path = "./millennium/backend/?.lua;" .. package.path

local b64 = require("b64")

assert(b64.encode("") == "")
assert(b64.encode("f") == "Zg==")
assert(b64.encode("fo") == "Zm8=")
assert(b64.encode("foo") == "Zm9v")
assert(b64.encode("foobar") == "Zm9vYmFy")
assert(b64.decode("Zm9vYmFy") == "foobar")
assert(b64.decode(b64.encode("\0\1\127\128\255")) == "\0\1\127\128\255")
assert(b64.decode("not base64!") == nil)

print("LuaJIT base64 tests passed")
