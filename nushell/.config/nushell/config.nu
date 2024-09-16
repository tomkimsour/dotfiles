$env.config = {
  show_banner : false
  ls: {
        use_ls_colors: true # use the LS_COLORS environment variable to colorize output
        clickable_links: true # enable or disable clickable links. Your terminal has to support links.
    }
  completions : {
      algorithm: "fuzzy"
    }
  filesize: {
      metric: true
    }
}

alias nu-open = open
alias open = ^open
alias z = zoxide
alias l = ls -a
alias lg = lazygit 
alias myip = curl http://ipecho.net/plain;
alias ffs = sudo !! 
alias yolo = rm -rf node_modules/ and rm package-lock.json and yarn install 
alias zshconfig = code $env.HOME/.zshrc 
alias a = arch -x86_64 
alias ibrew = arch -x86_64 brew 
alias meteo = curl v2.wttr.in/Barcelona\?1F 
alias vim = nvim 
alias python = /opt/homebrew/bin/python3
alias lvim = ~/.local/bin/lvim 
alias nproc = sysctl -n hw.logicalcpu

echo ~/banner
use ~/.cache/starship/init.nu
source ~/.zoxide.nu
