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

local get_pre_trigger_characters

---@module 'blink.cmp'
---@type blink.cmp.Source
local M = {}

---@class blink-emoji.config
---@field insert boolean Whether to insert the emoji or complete its name.
---@field pre_trigger string|string[]|fun(self: blink.cmp.Source):string[] Characters that must be present before the trigger.
---@field trigger string|string[]|fun(self: blink.cmp.Source):string[] Trigger characters.
local defaults = {
  insert = true,
  pre_trigger = function()
    return { "", " ", "\t" }
  end,
  trigger = function()
    return { ":" }
  end,
}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  config = vim.tbl_deep_extend("keep", opts or {}, defaults)
  self.get_trigger_characters = as_func(config.trigger)
  get_pre_trigger_characters = as_func(config.pre_trigger)
  if not emojis then
    emojis = require("blink-emoji.emojis").get()
  end
  return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
  local task = async.task.empty():map(function()
    local is_char_trigger = context.trigger.kind == "trigger_character"
      and vim.list_contains(
        self:get_trigger_characters(),
        context.trigger.character
      )
      and vim.list_contains(
        get_pre_trigger_characters(),
        context.line:sub(
          context.bounds.start_col - 2,
          context.bounds.start_col - 2
        )
      )
    callback {
      is_incomplete_forward = true,
      is_incomplete_backward = true,
      items = is_char_trigger and transform(emojis, context) or {},
      context = context,
    }
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
