-- [[ Setting options ]]
-- See `:help opt`
--  For more options, you can see `:help option-list`
local opt = vim.opt

opt.number = true -- Make line numbers default
opt.relativenumber = true -- You can also add relative line numbers, for help with jumping.
opt.mouse = 'a' -- Enable mouse mode, can be useful for resizing splits for example!
opt.showmode = false -- Don't show the mode, since it's already in status line

-- Sync clipboard between OS and Neo
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`

opt.clipboard = 'unnamedplus'

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neowill display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
opt.inccommand = 'split'

opt.cursorline = true -- Show which line your cursor is on
opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
opt.hlsearch = true -- Set highlight on search, but clear on pressing <Esc> in normal mode
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.expandtab = true -- Use spaces instead of tabs
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = 'longest:full,full' -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.fillchars = {
  foldopen = '',
  foldclose = '',
  -- fold = "⸱",
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

if vim.fn.has 'nvim-0.10' == 1 then
  opt.smoothscroll = true
end

-- Folding
vim.opt.foldlevel = 99

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
