# zmodload zsh/zprof
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/share/bob/nvim-bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git cargo colorize zsh-autosuggestions zsh-syntax-highlighting zoxide just)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/.zsh/aliases.zsh

alias lg='lazygit'
alias myip='curl http://ipecho.net/plain; echo $'.
alias ffs='sudo !!'
alias yolo='rm -rf node_modules/ && rm package-lock.json && yarn install'
alias zshconfig='code $HOME/.zshrc'
alias a="arch -x86_64"
alias meteo="curl v2.wttr.in/Barcelona\?1F"

alias vim="nvim"
alias nproc="sysctl -n hw.logicalcpu"
alias lzd='lazydocker'
alias cd='z'
alias j='just'

. "$HOME/.cargo/env"
. "$HOME/.atuin/bin/env"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v zoxide &> /dev/null; then
  # alias cd='z'
  eval "$(zoxide init zsh)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
else
  # Customize the prompt to include IMG_NAME
  PROMPT='%F{red} ${IMG_NAME}%{$reset_color%} '$PROMPT
fi

if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -d ~/pal_scm_utils ]; then
  alias alum="open_or_start_container alum-staging"
  alias gallium="open_or_start_container gallium-staging"
  if [[ -d /opt/pal/alum ]]; then
    # export TERM=xterm-256color
    export TERM=xterm-ghostty
    export RCUTILS_COLORIZED_OUTPUT=1
    export PYTHONPATH=/usr/lib/llvm-14/lib/python3.10/dist-packages/:$PYTHONPATH
    source /opt/ros/humble/setup.zsh
    source /opt/pal/alum/setup.zsh
  fi
  if [[ -d /opt/pal/fermium ]]; then
    export RCUTILS_COLORIZED_OUTPUT=1
    # export PYTHONPATH=/usr/lib/llvm-14/lib/python3.10/dist-packages/:$PYTHONPATH
    source /opt/ros/melodic/setup.zsh
    source /opt/pal/fermium/setup.zsh
  fi
  if [[ -d /opt/pal/gallium ]]; then
    # export TERM=xterm-256color
    export TERM=xterm-ghostty
    export RCUTILS_COLORIZED_OUTPUT=1
    # export PYTHONPATH=/usr/lib/llvm-14/lib/python3.10/dist-packages/:$PYTHONPATH
    source /opt/ros/noetic/setup.zsh
    source /opt/pal/gallium/setup.zsh
  fi
  source $HOME/pal_scm_utils/zsh/profile.zsh
fi
export GPG_TTY=$(tty)
conda_init() {
    if [[ ! -d /opt/pal ]]; then
        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup="$('/home/thomasung/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/home/thomasung/miniconda3/etc/profile.d/conda.sh" ]; then
                . "/home/thomasung/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="/home/thomasung/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<
    fi
}
# zprof
export PATH=$PATH:/usr/local/go/bin
export PATH="/home/thomasung/.pixi/bin:$PATH"
