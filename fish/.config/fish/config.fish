set -l banners
# Env var
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx DOT_DIR ~/dotfiles


switch $(uname)
    case Linux
        set -x OSTYPE Linux
    case Darwin
        set -x OSTYPE macOS
    case '*'
        set -x OSTYPE UNKNOWN
end


function fish_greeting -d "Theo's Custom Greetin Msg"
    # Getting the battery info
    set -l batlv -1
    if [ $OSTYPE = Linux ]
        if test -a /sys/class/power_supply/BAT0/capacity
            set batlv $(cat /sys/class/power_supply/BAT0/capacity)
            elif -a /sys/class/power_supply/BAT1/capacity
            set batlv $(cat /sys/class/power_supply/BAT1/capacity)
        end
    else if command -v pmset &>/dev/null
        set batlv $(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    end

    # Colors
    set -l normal (set_color normal)
    set -l cyan (set_color -o cyan)
    set -l brcyan (set_color -o brcyan)
    set -l green (set_color -o green)
    set -l brgreen (set_color -o brgreen)
    set -l red (set_color -o red)
    set -l brred (set_color -o brred)

    set -l blue (set_color -o blue)
    set -l brblue (set_color -o brblue)
    set -l magenta (set_color -o magenta)
    set -l brmagenta (set_color -o brmagenta)
    set -l yellow (set_color -o yellow)
    set -l bryellow (set_color -o bryellow)

    # Setting battery colors
    if [ $batlv -eq 1 ]
        set batcolo $red
        set batlv "Error in the battery "
    else if [ $batlv -ge 80 ]
        set batcolo $brcyan
    else if [ $batlv -gt 40 ]
        set batcolo $green
    else
        set batcolo $red
    end

    # Collection of Oliver ASCII arts
    set -l olivers \
        '
           .
          ":"
        ___:____     |"\/"|
      ,`        `.    \  /
      |  O        \___/  |
    ~^~^~^~^~^~^~^~^~^~^~^~^~
    ' \
        '
         .        .
       . |\\ -^- /| .
      /| } O.-.O { |\\
  '
  
    set -l oliver "$(random choice $olivers)" # will break new line without the quotes

    # Other information
    set -l my_hostname $(hostname -s) # -s to trim domain, hostname variable is taken by Fish
    set -l timestamp $(date -I) $(date +"%T")
    set -l uptime $(uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 " " }')

    set -l weather $(curl "wttr.in/Barcelona?format=%cWeather++:+++++++++%f+-+%w+-+%u+UV+-+💧+%p+-+%l")

    # Print the msg
    echo
    echo -e "  " "$brgreen" "Welcome back $USER!" "$normal"
    echo -e "  " "$brred" "$oliver" "$normal"
    echo -e "  " "$blue" " Hostname :\t" "$brmagenta$my_hostname" "$normal"
    echo -e "  " "$magenta" " Uptime   :\t" "$brblue$uptime" "$normal"
    echo -e "  " "$cyan" "󱈏 Battery  :\t" "$batcolo$batlv%" "$normal"
    echo -e " " "$yellow" "$weather" "$normal"
    echo
end

if [ $OSTYPE = macOS ]
    source (dirname (status --current-filename))/config-osx.fish
end

if status is-interactive
    # Commands to run in interactive sessions can go here
  set -l func_dir $XDG_CONFIG_HOME/fish/alias.fish
  [ -f $func_dir ] && source $func_dir || echo -e (set_color -o red) "[ERR] $func_dir does not exist!"

  # Enable Vi keybinding
  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_vi_force_cursor
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish

if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end
