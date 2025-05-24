local async = require "blink.cmp.lib.async"

local emojis
local config

---Include the trigger character when accepting a completion.
---@param context blink.cmp.Context
local function transform(items, context)
  return vim.tbl_map(function(entry)
    return vim.tbl_deep_extend("force", entry, {
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      textEdit = {
        range = {
          start = {
            line = context.cursor[1] - 1,
            character = context.bounds.start_col - 2,
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

---@param value string|string[]|fun():string[]
---@return fun():string[]
local function as_func(value)
  local ret

  if type(value) == "string" then
    return function()
      return { value }
    end
  elseif type(value) == "table" then
    return function()
      return value
    end
  elseif type(value) == "function" then
    return value --[[@as fun(self: blink.cmp.Source)]]
  end

  return function()
    return {}
  end
end

local function keyword_pattern(line, trigger_characters)
  -- Pattern is taken from `cmp-emoji` for similar trigger behavior.
  for _, c in ipairs(trigger_characters) do
    local pattern = [=[\%([[:space:]"'`]\|^\)\zs]=]
      .. c
      .. [=[[[:alnum:]_\-\+]*]=]
      .. c
      .. [=[\?]=]
      .. "$"
    if vim.regex(pattern):match_str(line) then
      return true
    end
  end
  return false
end

---@type blink.cmp.Source
local M = {}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  config = vim.tbl_deep_extend("keep", opts or {}, {
    insert = true,
    trigger = function()
      return { ":" }
    end,
  })
  self.get_trigger_characters = as_func(config.trigger)
  if not emojis then
    emojis = require("blink-emoji.emojis").get()
  end
  return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
  local task = async.task.empty():map(function()
    local cursor_before_line = context.line:sub(1, context.cursor[2])
    if
      not keyword_pattern(cursor_before_line, self:get_trigger_characters())
    then
      callback()
    else
      callback {
        is_incomplete_forward = true,
        is_incomplete_backward = true,
        items = transform(emojis, context),
        context = context,
      }
    end
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

return M
