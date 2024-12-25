---Shamelessly based on: https://github.com/hrsh7th/cmp-emoji/blob/main/lua/cmp_emoji/update.lua

local function read_json_file(path)
	local file = io.open(path)
	if not file then
		return
	end
	local content = file:read()
	file:close()
	return vim.json.decode(content, { luanil = { object = true, array = true } })
end

local function to_string(chars)
	local nrs = {}
	for _, char in ipairs(chars) do
		table.insert(nrs, vim.fn.eval(([[char2nr("\U%s")]]):format(char)))
	end
	return vim.fn.list2str(nrs, true)
end

local M = {}

---Fetches `emoji.json`
function M.fetch(url, target_dir)
	url = url or "https://raw.githubusercontent.com/iamcal/emoji-data/master/emoji.json"
	target_dir = target_dir or vim.fn.stdpath("cache") .. "/blink-emoji.nvim"

	local emoji_path = target_dir .. "/emoji.json"

	vim.print("Fetching: " .. url)
	vim.print("Target: " .. emoji_path)

	vim.fn.mkdir(target_dir, "p")
	local obj = vim.system({
		"curl",
		"-o",
		emoji_path,
		url,
	}, { timeout = 10000, text = true }):wait()

	vim.print("stdout:\n" .. obj.stdout)
	vim.print("stderr:\n" .. obj.stderr)
	return emoji_path
end

function M.generate(path, target)
	local emoji_data = read_json_file(path)
	if not emoji_data then
		vim.print("Error: Could not read " .. path)
		return
	end
	local file = io.open(target, "w")
	if not file then
		vim.print("Error: Could not open target for writing: " .. target)
		return
	end

	vim.print("Writing lua module: " .. target)

	file:write("local function get()\n  return {\n")
	for _, em in ipairs(emoji_data) do
		local emoji = to_string(vim.split(em.unified, "-", { trimempty = true }))
		for _, short_name in ipairs(em.short_names) do
			local name = ":" .. short_name .. ":"
			file:write(
				('    { label = "%s", insertText = "%s", textEdit = { newText = "%s" } },\n'):format(
					emoji .. " " .. name,
					emoji,
					name
				)
			)
		end
	end
	file:write("  }\nend\n\nreturn { get = get }")
	file:close()
end

function M.build(output_path)
	local emoji_path = M.fetch()
	M.generate(emoji_path, output_path)
	vim.print("Done.\n")
end

return M
