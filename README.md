# Welcome to my dotfiles!
They're finally organized (for now). I've started using stow to manage my
dotfiles using symlinks. If you're interested in figuring out how that works
for yourself, [here][blog] is a great blog post on it. Note that there are some
initial steps you'll need to clone my entire config.

## Dependencies
For zsh I use oh-my-zsh with powerlevel10k.

yabai is a wm for macOS

tmux config uses tpm

skhd is a keybinder for macOS

sketchybar is a toolbar of macOS



## GNU Stow

If you already have an existing config you want to back up, create your dotfiles
repository, then run `stow .zshrc --adopt` to set the contents of your dotfiles'
`.zshrc` for example, to what you have configured at `~/.zshrc`. You can also
map packages like `nvim`, `doom`, etc. you just need to follow the right
directory hierarchy as shown in the blog linked above.

### Installing on a fresh machine

Typically if I'm installing on a machine that has an existing configuration for a package, I'll use the `--adopt` directive for GNU stow, then do a `git restore`. Here's what that looks like:
1. Clone the repo and `cd` in there.
2. For each package in the repo that you want symlinked, run `stow <package>`. You will need to use `--adopt` if the package already exists on the machine. This creates a symlink for the package to your dotfiles repo.
3. If you want to use the config you had previously stored in your dotfiles repo, then run `git restore <dir>` or `git restore .` if you're feeling wild. If you want to **overwrite** the neovim config you had in your dotfiles repo with the one you have currently at `~/.config/nvim`, then don't do the restore.

> [!WARNING] 
> The `--adopt` flag *will* overwrite the contents of your current
> directory with the contents from your target directory. Please be careful.

## Neovim

For neovim, I use LazyVim with neovim 0.10 # NB: if your compiler is too old, intall from the following repo https://github.com/neovim/neovim-releases/releases/tag/stable

1. If you have an existing neovim installation, delete any existing runtime dir
   you have for neovim to prevent errors in your new version.
   `usr/local/nvim/runtime`. See :checkhealth of your current neovim install to
   confirm what the path is on your machine.
2. Install the last stable version of neovim, I recommand using bob-nvim as a nvim 
   package manager
4. Run `nvim`
5. This will install all of your nvim plugins.
6. Once finished, quit and restart to make sure everything is working
7. I am using LazyVim, I recommand you give a look at their documentation for tailoring
   your configuration.

[blog]: https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html
