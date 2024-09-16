$env.CARGO_HOME = ($env.HOME | path join .cargo)
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | append /usr/local/bin
  | prepend '/opt/homebrew/bin'
  | append ($env.CARGO_HOME | path join bin)
  | append ($env.HOME | path join .local bin)
  | uniq # filter so the paths are unique
)

zoxide init nushell | save -f ~/.zoxide.nu
