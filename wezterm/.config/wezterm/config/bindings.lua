local wezterm = require('wezterm')
local platform = require('utils.platform')()
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

local function is_vim(pane)
   local process_info = pane:get_foreground_process_info()
   local process_name = process_info and process_info.name

   return process_name == 'nvim' or process_name == 'vim'
end

local direction_keys = {
   Left = 'h',
   Down = 'j',
   Up = 'k',
   Right = 'l',
   -- reverse lookup
   h = 'Left',
   j = 'Down',
   k = 'Up',
   l = 'Right',
}

local function split_nav(resize_or_move, key)
   return {
      key = key,
      mods = resize_or_move == 'resize' and 'META' or 'CTRL',
      action = wezterm.action_callback(function(win, pane)
         if is_vim(pane) then
            -- pass the keys through to vim/nvim
            win:perform_action({
               SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
            }, pane)
         else
            if resize_or_move == 'resize' then
               win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
            else
               win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
            end
         end
      end),
   }
end

if platform.is_mac or platform.is_linux then
   mod.SUPER = 'CTRL'
elseif platform.is_win then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
   {
      key = 'u',
      mods = mod.SUPER,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- copy/paste --
   { key = 'c',          mods = 'SUPER',  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = 'SUPER',  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   { key = 'w',          mods = mod.SUPER, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '[',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = ']',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = '[',          mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
   { key = ']',          mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

   -- window --
   -- spawn windows
   -- { key = 'n',          mods = 'CTRL|SHIFT',     action = act.SpawnWindow },

   -- background controls --
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },

   -- panes --
   -- panes: split panes
   {
      key = [[v]],
      mods = 'LEADER',
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = [[s]],
      mods = 'LEADER',
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'c',     mods = 'LEADER',     action = act.CloseCurrentPane({ confirm = true}) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER, action = act.ActivatePaneDirection('Right') },
   -- move between split panes
   split_nav('move', 'h'),
   split_nav('move', 'j'),
   split_nav('move', 'k'),
   split_nav('move', 'l'),
   -- resize panes
   split_nav('resize', 'h'),
   split_nav('resize', 'j'),
   split_nav('resize', 'k'),
   split_nav('resize', 'l'),

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   leader = { key = 'Space', mods = mod.SUPER },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
