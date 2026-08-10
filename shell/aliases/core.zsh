# Core aliases, refactored out of the personal .zshrc.
# Kept intentionally small — anything more than a one-liner belongs in
# shell/functions/ or commands/, not here.

# Apps
alias saf='open -a "Safari"'
alias f='open .'
alias cod='code .'

# Terminal
alias cc='clear'

# System
alias lock='pmset displaysleepnow'
alias bat='pmset -g batt'
alias sys='open -a "System Settings"'

# Navigation
alias home='cd ~'
alias down='cd ~/Downloads'

# Config
alias zshrc='${BHARGI_EDITOR:-nano} ~/.zshrc'
alias reload='source ~/.zshrc'

# Renamed from the old bare "bhargi" alias, which now names the CLI.
alias ghprofile='open "https://github.com/Bhargi777"'
