local wezterm = require('wezterm')
local colors = require('colors.custom')

-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614

local nf = wezterm.nerdfonts

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_CIRCLE = nf.fa_circle --[[ '' ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ '󰞀' ]]

local M = {}

local __cells__ = {} -- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

local _set_process_name = function(s)
  local a = string.gsub(s, '(.*[/\\])(.*)', '%2')
  return a:gsub('%.exe$', '')
end

local _set_title = function(process_name, base_title, max_width, inset)
  local title
  inset = inset or 6

  if process_name:len() > 0 then
    title = process_name
  end

  -- if title:len() > max_width - inset then
  --   local diff = title:len() - max_width + inset
  --   title = wezterm.truncate_right(title, title:len() - diff)
  -- end

  return title
end

local _check_if_admin = function(p)
  if p:match('^Administrator: ') or p:match('(Admin)') then
    return true
  end
  return false
end

---@param fg string
---@param bg string
---@param attribute table
---@param text string
local _push = function(bg, fg, attribute, text)
  table.insert(__cells__, { Background = { Color = bg } })
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Attribute = attribute })
  table.insert(__cells__, { Text = text })
end

M.setup = function()
  wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
    __cells__ = {}

    local bg_left
    local fg_left
    local bg_right
    local fg_right
    local process_name = _set_process_name(tab.active_pane.foreground_process_name)
    local is_admin = _check_if_admin(tab.active_pane.title)
    local title = process_name --_set_title(process_name, tab.active_pane.title, max_width, (is_admin and 8))

    if tab.is_active then
      bg_left = colors.utils.tab_bar.active_tab.left_bg_color
      fg_left = colors.utils.tab_bar.active_tab.left_fg_color
      bg_right = colors.utils.tab_bar.active_tab.right_bg_color
      fg_right = colors.utils.tab_bar.active_tab.right_fg_color
    elseif hover then
      bg_left = colors.utils.tab_bar.inactive_tab_hover.left_bg_color
      fg_left = colors.utils.tab_bar.inactive_tab_hover.left_fg_color
      bg_right = colors.utils.tab_bar.inactive_tab_hover.right_bg_color
      fg_right = colors.utils.tab_bar.inactive_tab_hover.right_fg_color
    else
      bg_left = colors.utils.tab_bar.inactive_tab.left_bg_color
      fg_left = colors.utils.tab_bar.inactive_tab.left_fg_color
      bg_right = colors.utils.tab_bar.inactive_tab.right_bg_color
      fg_right = colors.utils.tab_bar.inactive_tab.right_fg_color
    end

    -- Left semi-circle
    _push(colors.utils.transparent, bg_left, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_LEFT)

    -- Admin Icon
    if is_admin then
      _push(bg_left, fg_left, { Intensity = 'Bold' }, ' ' .. GLYPH_ADMIN .. ' ')
    end

    -- Title
    _push(bg_left, fg_left, { Intensity = 'Bold' }, '' .. title)

    -- padding delimitation

    _push(colors.utils.transparent, bg_left, { Intensity = 'Bold' }, '█')
    -- tab index
    _push(bg_right, fg_right, { Intensity = 'Bold' }, ' ' .. tab.tab_index + 1)

    -- Right semi-circle
    _push(colors.utils.transparent, bg_right, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_RIGHT)

    _push(colors.utils.transparent, colors.utils.transparent, { Intensity = 'Bold' }, ' ')

    return __cells__
  end)
end

return M
