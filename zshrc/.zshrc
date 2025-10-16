#ln -s ~/.config/zshrc/.zshrc ~/.zshrc

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Rust/Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Dotnet
export DOTNET_ROOT="/opt/homebrew/share/dotnet"

# Neovim Mason
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Java
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"

# Flutter
export PATH="$HOME/development/flutter/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# MySQL Client
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Aspire CLI
export PATH="$HOME/.aspire/bin:$PATH"

# Tmuxifier
export PATH="$HOME/.tmuxifier/bin:$PATH"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Locale
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR=nvim

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# FZF
eval "$(fzf --zsh)"

# Tmuxifier
eval "$(tmuxifier init -)"

# Zsh plugins
source $HOMEBREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Angular CLI completion
source <(ng completion script)

# Bun completions
[ -s "/Users/rubentanahara/.bun/_bun" ] && source "/Users/rubentanahara/.bun/_bun"

# Local environment
. "$HOME/.local/bin/env"

# Directory management
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# GitHub account switching
function changeGitHubAccount() {
    local accounts=("personal" "gleam")
    
    if [ -z "$1" ]; then
        echo "Usage: changeGitHubAccount <account>"
        echo "Available accounts: ${accounts[*]}"
        return 1
    fi

    case "$1" in
        "personal")
            git config --global user.name "rubentanahara"
            git config --global user.email "ruben.mtz.tanahara@outlook.com"
            ;;
        "gleam")
            git config --global user.name "rubentanahara"
            git config --global user.email "rmartinez@gleam.mx"
            ;;
        *)
            echo "Error: Invalid account '$1'"
            echo "Available accounts: ${accounts[*]}"
            return 1
            ;;
    esac

    echo "Successfully switched to $1 account"
    echo "Git user: $(git config --global user.name)"
    echo "Git email: $(git config --global user.email)"
    
    printf "Do you want to switch GitHub CLI authentication? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        gh auth logout
        gh auth login
    fi
}

# Flutter development
function flutter-watch(){
  tmux send-keys "flutter run $1 $2 $3 $4 --pid-file=/tmp/tf1.pid" Enter \;\
  split-window -v \;\
  send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter \;\
  resize-pane -y 5 -t 1 \;\
  select-pane -t 0 \;
}

# Android utilities
function adb-screenshot() {
 adb exec-out screencap -p > /tmp/screenshot.png && open /tmp/screenshot.png
}

# Android emulator helpers
function _closeEmulators() {
    echo "Checking for running emulators..."
    if adb devices | grep -q emulator; then
        echo "Closing running emulator..."
        adb -e emu kill
        sleep 3
    fi
}

function list_emulators() {
    echo "Available Android Emulators:"
    emulator -list-avds
}

function andemu() {
    _closeEmulators
    
    echo "\nAvailable emulators:"
    emulator -list-avds | nl -v 0
    
    typeset num_avds=$(emulator -list-avds | wc -l)
    
    echo "\nEnter the number (0-$((num_avds-1))) of the emulator to start:"
    read selection
    
    if [[ ! $selection =~ ^[0-9]+$ ]] || [ $selection -ge $num_avds ]; then
        echo "Invalid selection. Please enter a number between 0 and $((num_avds-1))"
        return 1
    fi
    
    typeset selected_avd=$(emulator -list-avds | sed -n "$((selection+1))p")
    echo "Starting $selected_avd..."
    emulator -avd $selected_avd &
}

function wipeemu() {
    _closeEmulators
    
    echo "\nAvailable emulators:"
    emulator -list-avds | nl -v 0
    
    typeset num_avds=$(emulator -list-avds | wc -l)
    
    echo "\nEnter the number (0-$((num_avds-1))) of the emulator to wipe:"
    read selection
    
    if [[ ! $selection =~ ^[0-9]+$ ]] || [ $selection -ge $num_avds ]; then
        echo "Invalid selection. Please enter a number between 0 and $((num_avds-1))"
        return 1
    fi
    
    typeset selected_avd=$(emulator -list-avds | sed -n "$((selection+1))p")
    
    echo "\nAre you sure you want to wipe data from '$selected_avd'? [y/N]"
    read confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "Wiping data from $selected_avd..."
        emulator -avd $selected_avd -wipe-data
        echo "Emulator started with fresh data!"
    else
        echo "Operation cancelled."
    fi
}

function andrun() {
    _closeEmulators
    
    echo "\nAvailable emulators:"
    emulator -list-avds | nl -v 0
    
    typeset num_avds=$(emulator -list-avds | wc -l)
    
    echo "\nEnter the number (0-$((num_avds-1))) of the emulator to run:"
    read selection
    
    if [[ ! $selection =~ ^[0-9]+$ ]] || [ $selection -ge $num_avds ]; then
        echo "Invalid selection. Please enter a number between 0 and $((num_avds-1))"
        return 1
    fi
    
    typeset selected_avd=$(emulator -list-avds | sed -n "$((selection+1))p")
    
    echo "\nDo you want to perform a clean build? [y/N]"
    read clean_build
    
    if [[ $clean_build =~ ^[Yy]$ ]]; then
        echo "Performing clean build..."
        ./gradlew clean build assembleDebug -x lint
    else
        echo "Building..."
        ./gradlew assembleDebug -x lint
    fi
    
    if [ $? -eq 0 ]; then
        echo "\nBuild successful! Starting emulator..."
        emulator -avd $selected_avd &
        
        echo "Waiting for emulator to boot..."
        adb wait-for-device
        
        until adb shell getprop sys.boot_completed 2>/dev/null | grep -m 1 "1"; do
            sleep 2
        done
        
        echo "Installing app..."
        ./gradlew installDebug
        
        echo "\nApp installed successfully!"
    else
        echo "\nBuild failed! Please check the errors above."
    fi
}

function andrunfast() {
    if [ -z "$1" ]; then
        echo "Usage: andrunfast <emulator-name> [clean]"
        echo "\nAvailable emulators:"
        emulator -list-avds
        return 1
    fi
    
    _closeEmulators
    
    if [ "$2" = "clean" ]; then
        ./gradlew clean build assembleDebug
    else
        ./gradlew assembleDebug
    fi
    
    if [ $? -eq 0 ]; then
        emulator -avd $1 &
        adb wait-for-device
        until adb shell getprop sys.boot_completed 2>/dev/null | grep -m 1 "1"; do
            sleep 2
        done
        ./gradlew installDebug
    fi
}

# HTTP utilities
curl_pretty() {
  method=$1
  shift
  curl -s -i -X "$method" "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat
}

curl_get()    { curl -s -i -X GET    "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat; }
curl_post()   { curl -s -i -X POST   "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat; }
curl_patch()  { curl -s -i -X PATCH  "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat; }
curl_put()    { curl -s -i -X PUT    "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat; }
curl_delete() { curl -s -i -X DELETE "$@" | awk 'BEGIN{body=0} /^\r$/{body=1; print ""; next} !body{print; next} body{print | "jq"}' | bat; }

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias cd..="cd .."
alias c="clear"

# File operations
alias ll="lsd -lah"
alias la="lsd -A"
alias lf="lsd -F"
alias mkdirp="mkdir -p"
alias md="mkdir"
alias del="rm -rf"
alias cpv="cp -iv"
alias mvv="mv -iv"
alias dux="du -h --max-depth=1"
alias tree="tree -C"

# Development tools
alias yz="yazi"
alias f="fzf"
alias n="nvim"
alias sz="source ~/.zshrc"
alias nz="n ~/.zshrc"
alias cc="cd ~/.config"
alias nc="n ~/.config"
alias dev="cd ~/Desktop/dev"

# Dotnet
alias dwr="dotnet watch run"
alias dnb="dotnet build"
alias dnc="dotnet clean"
alias dnr="dotnet restore"
alias dnt='dotnet test --logger "console;verbosity=detailed"'
alias dotnetFull='dnc && dnr && dnb && dnt'

# Tmux
alias tmx="tmux"
alias devtmx="tmux new -s sylow.dev"

# Go
alias gob="go build"
alias gor="go run"
alias goc="go clean"
alias gof="go fmt"

# Package management
alias showPackage="bat package.json"

# Neovim maintenance
alias cleanUpNeovim="rm -rf ~/.local/share/nvim && rm -rf ~/.local/state/nvim && rm -rf ~/.cache/nvim"

# Android development
alias andbuild='./gradlew clean build assembleDebug --configuration-cache --no-daemon'
alias andclean='./gradlew clean'
alias andinstall='./gradlew installDebug'
alias andlist='emulator -list-avds'
alias andkill='_closeEmulators'
alias anddevices='adb devices'
alias andrestart='adb kill-server && adb start-server'
alias andclearapp='adb shell pm clear'

# Android debugging
alias andwarnings='./gradlew assembleDebug --warning-mode all'
alias andinfo='./gradlew assembleDebug --info'
alias anddebug='./gradlew assembleDebug --debug'
alias andstacktrace='./gradlew assembleDebug --stacktrace'
alias andscan='./gradlew assembleDebug --scan'
alias andlint='./gradlew lintDebug && open app/build/reports/lint-results-debug.html'

# Git
alias gs="git status -sb"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gcb="git checkout -b"
alias grm="git rm"
alias gstash="git stash"

# System monitoring
alias mem="free -h"
alias cpu="top -o cpu"
alias df="df -h"
alias psaux="ps aux --sort=-%mem"
alias reboot="sudo reboot"
alias shutdown="sudo shutdown now"

# Network
alias pingg="ping google.com"
alias myip="curl ifconfig.me"
alias ports="netstat -tulanp"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Homebrew
alias brewup="brew update && brew upgrade && brew cleanup"
alias brews="brew services list"
alias brewsearch="brew search"
alias brewinfo="brew info"

# NPM
alias npmi="npm install"
alias npms="npm start"
alias npmb="npm run build"
alias npmt="npm test"
alias npmu="npm update"
alias mcp="npx @michaellatman/mcp-get"

# Python
alias py="python3"

# Docker
alias dstart='open --background -a Docker'

# GitHub CLI
alias gh-prl='gh pr list --author @me'
alias gh-myissues='gh issue list --author @me'
alias gh-prc='gh pr create --fill'
alias gh-prb='gh pr view --web'
alias gh-prm='gh pr merge --squash'
alias gh-open='gh repo view --web'
alias gh-clone='gh repo clone -- --ssh'
alias gh-fork='gh repo fork --clone'
alias gh-wf='gh workflow list'
alias gh-wft='gh workflow run'
alias gh-logs='gh run view --log'
alias gh-delete-branch='gh api -X DELETE repos/:owner/:repo/branches/:branch'
alias gh-release='gh release create --draft'
alias gh-branches='gh repo list --source'
alias gh-issues='gh issue list --web'
alias gh-prs='gh pr list --web'
alias gh-star='gh repo star'
alias gh-unstar='gh repo unstar'
alias gh-rate='gh api rate_limit'
alias gh-repo-info='gh repo view --json name,owner,description --jq ".name + \" by \" + .owner.login + \": \" + .description"'
