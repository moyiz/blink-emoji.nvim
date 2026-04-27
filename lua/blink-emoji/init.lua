local async = require "blink.cmp.lib.async"

local emojis
local config

---Include the trigger character when accepting a completion.
---@param context blink.cmp.Context
local function transform(items, context, trigger_len)
  return vim.tbl_map(function(entry)
    return vim.tbl_deep_extend("force", entry, {
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      textEdit = {
        range = {
          start = {
            line = context.cursor[1] - 1,
            character = context.bounds.start_col - 1 - trigger_len
          },
          ["end"] = {
            line = context.cursor[1] - 1,
            character = context.cursor[2],
          },
        },
      },
    })
  end, items)
end

---@type blink.cmp.Source
local M = {}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  config = vim.tbl_deep_extend("keep", opts or {}, {
    insert = true,
    trigger = ":"
  })
  if not emojis then
    emojis = require("blink-emoji.emojis").get()
  end
  return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
  local task = async.task.empty():map(function()
    local trigger = self:get_trigger_characters()
    local trigger_len = string.len(trigger[1])
		local is_char_trigger = vim.tbl_contains(
      trigger,
			context.line:sub(context.bounds.start_col - trigger_len, context.bounds.start_col - 1)
		)
		callback({
			is_incomplete_forward = true,
			is_incomplete_backward = true,
			items = is_char_trigger and transform(emojis, context, trigger_len) or {},
			context = context,
		})
  end)
  return function()
    task:cancel()
  end
end

---`newText` is used for `ghost_text`, thus it is set to the emoji name in `emojis`.
---Change `newText` to the actual emoji when accepting a completion.
function M:resolve(item, callback)
  local resolved = vim.deepcopy(item)
  if config.insert then
    resolved.textEdit.newText = resolved.insertText
  end
  return callback(resolved)
end

function M:get_trigger_characters()
  local value = config.trigger

  if type(value) == "string" then
    return { value }
  elseif type(value) == "table" then
    return value
  elseif type(value) == "function" then
    return value()
  end

  return {}
end

return M
