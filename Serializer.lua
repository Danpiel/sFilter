-- Export/import encoding: a small self-describing serializer (no loadstring), optional
-- Deflate compression through C_EncodingUtil and Base64 so the result can be pasted in chat or Discord.

local _, ns = ...

local Serializer = {}
ns.Serializer = Serializer

local HEADER = "!SF1!"
-- Strings exported while the addon was called DSFilter.
local LEGACY_HEADER = "!DSF1!"
local MAX_DEPTH = 16
local MAX_NODES = 50000

local byte, char, sub, format, concat = string.byte, string.char, string.sub, string.format, table.concat
local floor = math.floor

------------------------------------------------------------------------
-- Serialize
------------------------------------------------------------------------

local function WriteValue(out, value, depth)
	local kind = type(value)
	if kind == "string" then
		out[#out + 1] = "s" .. #value .. ":" .. value
	elseif kind == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			error("cannot serialize a non-finite number")
		end
		if value == floor(value) and value >= -2^53 and value <= 2^53 then
			out[#out + 1] = format("n%d;", value)
		else
			out[#out + 1] = format("n%.17g;", value)
		end
	elseif kind == "boolean" then
		out[#out + 1] = value and "T" or "F"
	elseif kind == "table" then
		if depth >= MAX_DEPTH then
			error("table is nested too deeply")
		end
		out[#out + 1] = "t"
		for k, v in pairs(value) do
			local keyKind = type(k)
			if (keyKind == "string" or keyKind == "number") and type(v) ~= "function" and type(v) ~= "userdata" then
				WriteValue(out, k, depth + 1)
				WriteValue(out, v, depth + 1)
			end
		end
		out[#out + 1] = "}"
	else
		error("cannot serialize a value of type " .. kind)
	end
end

function Serializer.Serialize(value)
	local out = {}
	WriteValue(out, value, 0)
	return concat(out)
end

------------------------------------------------------------------------
-- Deserialize
------------------------------------------------------------------------

local function ReadValue(state, depth)
	state.nodes = state.nodes + 1
	if state.nodes > MAX_NODES then
		error("too much data")
	end

	local data, pos = state.data, state.pos
	local tag = sub(data, pos, pos)
	if tag == "s" then
		local colon = data:find(":", pos + 1, true)
		if not colon then
			error("malformed string")
		end
		local length = tonumber(sub(data, pos + 1, colon - 1))
		if not length or length < 0 or colon + length > #data then
			error("malformed string length")
		end
		state.pos = colon + length + 1
		return sub(data, colon + 1, colon + length)
	elseif tag == "n" then
		local stop = data:find(";", pos + 1, true)
		if not stop then
			error("malformed number")
		end
		local number = tonumber(sub(data, pos + 1, stop - 1))
		if not number or number ~= number then
			error("malformed number")
		end
		state.pos = stop + 1
		return number
	elseif tag == "T" or tag == "F" then
		state.pos = pos + 1
		return tag == "T"
	elseif tag == "t" then
		if depth >= MAX_DEPTH then
			error("table is nested too deeply")
		end
		state.pos = pos + 1
		local result = {}
		while true do
			if state.pos > #data then
				error("unterminated table")
			end
			if sub(data, state.pos, state.pos) == "}" then
				state.pos = state.pos + 1
				return result
			end
			local key = ReadValue(state, depth + 1)
			if type(key) ~= "string" and type(key) ~= "number" then
				error("invalid table key")
			end
			result[key] = ReadValue(state, depth + 1)
		end
	end
	error("unexpected data")
end

function Serializer.Deserialize(data)
	if type(data) ~= "string" or data == "" then
		return false, "empty input"
	end
	local state = { data = data, pos = 1, nodes = 0 }
	local ok, result = pcall(ReadValue, state, 0)
	if not ok then
		return false, (tostring(result):gsub("^.-:%d+: ", ""))
	end
	if state.pos <= #data then
		return false, "trailing data"
	end
	return true, result
end

------------------------------------------------------------------------
-- Base64 (pure Lua fallback for clients without C_EncodingUtil)
------------------------------------------------------------------------

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local encodeMap, decodeMap = {}, {}
for i = 1, #ALPHABET do
	local c = sub(ALPHABET, i, i)
	encodeMap[i - 1] = c
	decodeMap[byte(c)] = i - 1
end

function Serializer.EncodeBase64Lua(data)
	local out = {}
	for i = 1, #data, 3 do
		local a, b, c = byte(data, i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1 = floor(n / 262144) % 64
		local c2 = floor(n / 4096) % 64
		local c3 = floor(n / 64) % 64
		local c4 = n % 64
		out[#out + 1] = encodeMap[c1] .. encodeMap[c2]
			.. (b and encodeMap[c3] or "=")
			.. (c and encodeMap[c4] or "=")
	end
	return concat(out)
end

function Serializer.DecodeBase64Lua(data)
	data = data:gsub("[^%w%+/=]", "")
	if #data % 4 ~= 0 then
		return nil
	end
	local out = {}
	for i = 1, #data, 4 do
		local n, padding = 0, 0
		for j = 0, 3 do
			local c = byte(data, i + j)
			local value = decodeMap[c]
			if c == 61 then -- "="
				padding = padding + 1
				value = 0
			elseif not value or padding > 0 then
				return nil
			end
			n = n * 64 + value
		end
		local a = floor(n / 65536) % 256
		local b = floor(n / 256) % 256
		local c = n % 256
		if padding == 0 then
			out[#out + 1] = char(a, b, c)
		elseif padding == 1 then
			out[#out + 1] = char(a, b)
		elseif padding == 2 then
			out[#out + 1] = char(a)
		else
			return nil
		end
	end
	return concat(out)
end

local function EncodeBase64(data)
	if C_EncodingUtil and C_EncodingUtil.EncodeBase64 then
		return C_EncodingUtil.EncodeBase64(data)
	end
	return Serializer.EncodeBase64Lua(data)
end

local function DecodeBase64(data)
	if C_EncodingUtil and C_EncodingUtil.DecodeBase64 then
		local ok, result = pcall(C_EncodingUtil.DecodeBase64, data)
		return ok and result or nil
	end
	return Serializer.DecodeBase64Lua(data)
end

------------------------------------------------------------------------
-- Export string
------------------------------------------------------------------------

function Serializer.Encode(value)
	local payload = Serializer.Serialize(value)
	local mode = "r"
	if C_EncodingUtil and C_EncodingUtil.CompressString then
		local ok, compressed = pcall(C_EncodingUtil.CompressString, payload)
		if ok and compressed then
			payload, mode = compressed, "z"
		end
	end
	return HEADER .. mode .. EncodeBase64(payload)
end

-- Returns ok, valueOrError.
function Serializer.Decode(text)
	if type(text) ~= "string" then
		return false, "empty input"
	end
	text = text:gsub("%s", "")
	local header = HEADER
	if sub(text, 1, #LEGACY_HEADER) == LEGACY_HEADER then
		header = LEGACY_HEADER
	elseif sub(text, 1, #HEADER) ~= HEADER then
		return false, "not an sFilter string"
	end
	local mode = sub(text, #header + 1, #header + 1)
	local payload = DecodeBase64(sub(text, #header + 2))
	if not payload or payload == "" then
		return false, "broken Base64"
	end
	if mode == "z" then
		if not (C_EncodingUtil and C_EncodingUtil.DecompressString) then
			return false, "this client cannot decompress the string"
		end
		local ok, decompressed = pcall(C_EncodingUtil.DecompressString, payload)
		if not ok or not decompressed then
			return false, "broken compressed data"
		end
		payload = decompressed
	elseif mode ~= "r" then
		return false, "unknown format"
	end
	return Serializer.Deserialize(payload)
end
