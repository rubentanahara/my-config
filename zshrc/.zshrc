#ln -s ~/.config/zshrc/.zshrc ~/.zshrc

# set Editor to Neovim
export EDITOR=nvim

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Rust/Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

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

# LaTeX paths
export PATH="/usr/local/texlive/2024/bin/x86_64-darwin:$PATH"
export MANPATH="/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH"


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

# Local environment
. "$HOME/.local/bin/env"

# Directory management
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# Document management
function epub2pdf() {
  if [ -f "$1" ]; then
    output="${1%.epub}.pdf"
    echo "Converting $1 to $output..."
    ebook-convert "$1" "$output" && zathura "$output"
  else
    echo "File not found: $1"
    echo "Usage: epub2pdf <file.epub>"
  fi
}

# Quick EPUB to PDF without opening
function epub2pdf-only() {
  if [ -f "$1" ]; then
    output="${1%.epub}.pdf"
    echo "Converting $1 to $output..."
    ebook-convert "$1" "$output"
  else
    echo "File not found: $1"
    echo "Usage: epub2pdf-only <file.epub>"
  fi
}

# Convert presenterm markdown to pandoc-compatible PDF
function presenterm2pdf() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    echo "Usage: presenterm2pdf <file.md> [--only]"
    return 1
  fi

  local input="$1"
  local temp_md="/tmp/presenterm_converted_$(basename "$input")"
  local temp_dir="/tmp/presenterm_diagrams_$$"
  local output="${input%.md}.pdf"
  local only_convert=false

  # Check for --only flag
  if [ "$2" = "--only" ]; then
    only_convert=true
  fi

  # Create temp directory for diagrams
  mkdir -p "$temp_dir"

  echo "Converting presenterm markdown to pandoc format..."

  # First pass: Extract and render diagrams
  echo "  → Detecting and rendering diagrams..."
  awk -v temp_dir="$temp_dir" '
    BEGIN {
      diagram_num = 0
      in_diagram = 0
    }

    /^```(mermaid|d2|typst)/ {
      in_diagram = 1
      # Extract diagram type
      line = $0
      gsub(/^```/, "", line)
      gsub(/ .*$/, "", line)
      diagram_type = line
      diagram_num++
      diagram_file = temp_dir "/diagram_" diagram_num
      diagram_content = ""
      print "    • Found " diagram_type " diagram #" diagram_num > "/dev/stderr"
      next
    }

    in_diagram && /^```$/ {
      in_diagram = 0

      # Save diagram content to file and render
      if (diagram_type == "d2") {
        output_file = diagram_file ".d2"
        print diagram_content > output_file
        close(output_file)
        cmd = "d2 --theme=200 \"" diagram_file ".d2\" \"" diagram_file ".png\" 2>&1"
        result = system(cmd)
        if (result == 0) {
          print "    ✓ Rendered D2 diagram" > "/dev/stderr"
        }
      } else if (diagram_type == "typst") {
        output_file = diagram_file ".typ"
        print diagram_content > output_file
        close(output_file)
        cmd = "typst compile \"" diagram_file ".typ\" \"" diagram_file ".png\" 2>&1"
        result = system(cmd)
        if (result == 0) {
          print "    ✓ Rendered Typst formula" > "/dev/stderr"
        }
      } else if (diagram_type == "mermaid") {
        output_file = diagram_file ".mmd"
        print diagram_content > output_file
        close(output_file)
        cmd = "mmdc -i \"" diagram_file ".mmd\" -o \"" diagram_file ".png\" -b transparent 2>&1"
        result = system(cmd)
        if (result == 0) {
          print "    ✓ Rendered Mermaid diagram" > "/dev/stderr"
        }
      }

      # Output image reference with width constraint
      print "![Diagram](" diagram_file ".png){ width=90% }"
      print ""
      next
    }

    in_diagram {
      if (diagram_content != "") diagram_content = diagram_content "\n"
      diagram_content = diagram_content $0
      next
    }

    { print }
  ' "$input" > "$temp_md.stage1"

  # Second pass: Process the markdown file to remove presenterm-specific syntax
  awk '
    # Track if we are in a code block
    /^```/ {
      if (!in_code) {
        in_code = 1
        in_latex = 0
        # Check if this is a latex block
        if ($0 ~ /```latex/) {
          in_latex = 1
          print "$$"  # Open LaTeX display math
          next
        }
        # Remove presenterm attributes from code blocks
        gsub(/ \+[^ ]+/, "", $0)
        # Remove dynamic highlighting {1-4|6-10|all}
        gsub(/ \{[^}]*\}/, "", $0)
      } else {
        if (in_latex) {
          # Close the LaTeX block with $$
          print "$$"
          print ""  # Add blank line after
          in_latex = 0
        }
        in_code = 0
      }
      if (!in_latex) print $0
      next
    }

    # Handle content inside code blocks
    in_code && !in_latex {
      # Remove lines that start with "# " (presenterm hidden lines)
      if ($0 ~ /^# /) next
      print $0
      next
    }

    # Handle LaTeX content
    in_latex {
      # Remove \[ and \] delimiters, keep the formula content
      gsub(/^\\?\[[ ]*/, "")
      gsub(/[ ]*\\?\]$/, "")
      # Remove double backslashes if any
      gsub(/\\\\([a-zA-Z])/, "\\1")
      if ($0 != "") print $0
      next
    }

    # Remove presenterm-specific comments
    /<!-- (pause|end_slide|jump_to_middle|column_layout|column:|reset_layout) -->/ { next }
    /<!-- (pause|end_slide|jump_to_middle|reset_layout)$/ { next }
    /<!-- column_layout:/ { next }
    /<!-- column:/ { next }

    # Fix quadruple backticks to triple
    { gsub(/````/, "```") }

    # Print all other lines
    { print }
  ' "$temp_md.stage1" > "$temp_md"

  rm "$temp_md.stage1"

  echo "Generating PDF from converted markdown..."
  pandoc "$temp_md" -o "$output" \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V colorlinks=true \
    -V linkcolor=blue \
    -V urlcolor=blue \
    --syntax-highlighting=tango

  if [ $? -eq 0 ]; then
    echo "PDF created: $output"

    # Clean up temp files
    rm "$temp_md"
    rm -rf "$temp_dir"

    if [ "$only_convert" = false ]; then
      zathura "$output"
    fi
  else
    echo "Error: PDF conversion failed"
    echo "Temp file saved at: $temp_md"
    echo "Diagrams saved at: $temp_dir"
    return 1
  fi
}

# Markdown to PDF with Zathura
function md2pdf() {
  if [ -f "$1" ]; then
    output="${1%.md}.pdf"
    echo "Converting $1 to $output..."
    pandoc "$1" -o "$output" \
      --pdf-engine=xelatex \
      -V geometry:margin=1in \
      -V colorlinks=true \
      -V linkcolor=blue \
      -V urlcolor=blue \
      --syntax-highlighting=tango \
      && zathura "$output"
  else
    echo "File not found: $1"
    echo "Usage: md2pdf <file.md>"
  fi
}

# Quick Markdown to PDF without opening
function md2pdf-only() {
  if [ -f "$1" ]; then
    output="${1%.md}.pdf"
    echo "Converting $1 to $output..."
    pandoc "$1" -o "$output" \
      --pdf-engine=xelatex \
      -V geometry:margin=1in \
      -V colorlinks=true \
      -V linkcolor=blue \
      -V urlcolor=blue \
      --syntax-highlighting=tango
  else
    echo "File not found: $1"
    echo "Usage: md2pdf-only <file.md>"
  fi
}

# Hot-reload Markdown to PDF with Zathura
function md2pdf-watch() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    echo "Usage: md2pdf-watch <file.md>"
    return 1
  fi

  local input="$1"
  local output="${input%.md}.pdf"
  local temp_output="${output%.pdf}.tmp.pdf"

  # Initial conversion
  echo "Initial conversion: $input -> $output"
  pandoc "$input" -o "$output" \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V colorlinks=true \
    -V linkcolor=blue \
    -V urlcolor=blue \
    --syntax-highlighting=tango

  # Open in Zathura
  zathura "$output" &
  local zathura_pid=$!

  echo "Watching $input for changes... (Ctrl+C to stop)"
  echo "Zathura PID: $zathura_pid"

  # Trap to cleanup on exit
  trap "kill $zathura_pid 2>/dev/null; rm -f '$temp_output'; exit" INT TERM

  # Watch for changes with atomic file operations (Zathura auto-detects file changes)
  echo "$input" | entr -p sh -c "
    pandoc '$input' -o '$temp_output' \
      --pdf-engine=xelatex \
      -V geometry:margin=1in \
      -V colorlinks=true \
      -V linkcolor=blue \
      -V urlcolor=blue \
      --syntax-highlighting=tango && \
    mv '$temp_output' '$output' && \
    sleep 0.2 && \
    echo '✓ PDF updated: $(date +%H:%M:%S)' || \
    echo '✗ PDF update failed: $(date +%H:%M:%S)'
  "

  # Cleanup on normal exit
  kill $zathura_pid 2>/dev/null
  rm -f "$temp_output"
}

# Alternative: use latexmk for hot reload (more reliable on some systems)
function md2pdf-watch-latexmk() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    echo "Usage: md2pdf-watch-latexmk <file.md>"
    return 1
  fi

  local input="$1"
  local output="${input%.md}.pdf"
  local tex_file="${input%.md}.tex"

  echo "Converting to LaTeX and starting continuous preview..."

  # Create a wrapper that converts MD→LaTeX, then watches with latexmk
  echo "$input" | entr -r sh -c "
    pandoc '$input' -o '$tex_file' --to=latex && \
    latexmk -pdf -pvc -view=none '$tex_file'
  " &

  sleep 2
  zathura "$output" &

  wait
}

eval "$(starship init zsh)"

# FZF
eval "$(fzf --zsh)"

# Tmuxifier
eval "$(tmuxifier init -)"

# Zoxide
eval "$(zoxide init zsh)"
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
            git config --global user.email "$GIT_PERSONAL_EMAIL"
            ;;
        "gleam")
            git config --global user.name "rubentanahara"
            git config --global user.email "$GIT_WORK_EMAIL"
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

function flutter-clean() {
  flutter clean
  rm -rf ios/Pods
  rm -rf ios/.symlinks
  rm -rf ios/Flutter/Flutter.framework
  rm -rf ios/Flutter/Flutter.podspec
  flutter pub get
  cd ios && pod install && cd ..
  dart run build_runner build --delete-conflicting-outputs
  flutter gen-l10n
  flutter analyze
}

# Flutter development
function flutter-watch(){
  tmux send-keys "flutter run $1 $2 $3 $4 --pid-file=/tmp/tf1.pid" Enter \;\
  split-window -v \;\
  send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter \;\
  resize-pane -y 1 -t 1 \;\
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
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# pnpm
export PNPM_HOME="/Users/rubentanahara/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


