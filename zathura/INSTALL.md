# Installing and Configuring Zathura on macOS

Zathura is a lightweight, keyboard-driven PDF viewer with Vim-like keybindings.

## Prerequisites

Ensure Homebrew is installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Installation Steps

### 1. Install Zathura and PDF Plugin

```bash
# Install both Zathura and the PDF plugin
brew install zathura zathura-pdf-poppler
```

### 2. Set Up the PDF Plugin

**IMPORTANT:** The plugin must be linked to the correct location for Zathura to detect it.

```bash
# Create the plugin directory
mkdir -p $(brew --prefix zathura)/lib/zathura

# Link the PDF plugin
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
      $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
```

For reference, on Apple Silicon (M1/M2/M3), this creates:
- Plugin directory: `/opt/homebrew/opt/zathura/lib/zathura/`
- Symlink: `libpdf-poppler.dylib` → `/opt/homebrew/opt/zathura-pdf-poppler/libpdf-poppler.dylib`

On Intel Macs, replace `/opt/homebrew` with `/usr/local`.

### 3. Verify Installation

```bash
# Check Zathura version
zathura --version

# Test with a PDF file
zathura /path/to/document.pdf
```

## Configuration

### Basic Configuration

The configuration file is located at `~/.config/zathura/zathurarc`.

#### Minimal Configuration

```bash
# Copy selection to clipboard
set selection-clipboard clipboard

# Enable dark mode (recolor)
set recolor true
set recolor-lightcolor "#1e1e1e"
set recolor-darkcolor "#d4d4d4"
```

#### Advanced Configuration Example

```bash
# UI Settings
set statusbar-h-padding 0
set statusbar-v-padding 0
set page-padding 1

# Clipboard
set selection-clipboard clipboard

# Search
set incremental-search true
set search-hadjust true

# Color Scheme (Dark Mode)
set recolor true
set recolor-lightcolor "#1e1e1e"
set recolor-darkcolor "#d4d4d4"
set recolor-keephue true

# Window
set adjust-open "best-fit"
set pages-per-row 1

# Scrolling
set scroll-page-aware true
set scroll-full-overlap 0.01
set scroll-step 100

# Zoom
set zoom-min 10
set zoom-max 1000
set zoom-step 10

# Status bar
set window-title-basename true
set statusbar-basename true
```

### Color Schemes

#### Solarized Dark
```bash
set recolor true
set recolor-lightcolor "#002b36"
set recolor-darkcolor "#839496"
set default-bg "#002b36"
set default-fg "#839496"
```

#### Gruvbox Dark
```bash
set recolor true
set recolor-lightcolor "#282828"
set recolor-darkcolor "#ebdbb2"
set default-bg "#282828"
set default-fg "#ebdbb2"
```

#### Nord
```bash
set recolor true
set recolor-lightcolor "#2e3440"
set recolor-darkcolor "#d8dee9"
set default-bg "#2e3440"
set default-fg "#d8dee9"
```

## Essential Keybindings

Zathura uses Vim-like keybindings by default:

### Navigation
- `j` / `k` - Scroll down/up
- `h` / `l` - Scroll left/right
- `gg` - Go to first page
- `G` - Go to last page
- `[number]G` - Go to page [number]
- `Ctrl-d` / `Ctrl-u` - Half page down/up
- `Ctrl-f` / `Ctrl-b` - Full page down/up
- `Space` / `Shift-Space` - Next/previous page

### View
- `+` / `-` - Zoom in/out
- `=` - Reset zoom
- `a` - Fit to page width
- `s` - Fit to page height
- `r` - Rotate 90 degrees
- `R` - Rotate 270 degrees
- `Ctrl-r` - Toggle recolor (dark mode)
- `d` - Toggle dual page mode

### Search
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

### Other
- `f` - Follow links (shows link numbers)
- `F` - Display link target
- `m[key]` - Set bookmark at [key]
- `'[key]` - Go to bookmark [key]
- `q` - Quit
- `:` - Enter command mode
- `Tab` - Show index/table of contents

### Custom Keybindings

Add custom keybindings in `zathurarc`:

```bash
# Example: Use arrow keys for navigation
map <Up> scroll up
map <Down> scroll down
map <Left> scroll left
map <Right> scroll right

# Example: Use Ctrl-s to toggle statusbar
map <C-s> toggle_statusbar

# Example: Print with p
map p print
```

## Common Commands

From command mode (press `:`):

- `:open [file]` - Open a file
- `:write [file]` - Save to file
- `:print` - Print document
- `:info` - Show document information
- `:exec [command]` - Execute external command
- `:quit` - Quit Zathura

## Integration with Other Tools

### Set as Default PDF Viewer

```bash
# Using duti (install with: brew install duti)
duti -s org.pwmt.zathura pdf all
```

### Open from Terminal

Add to your shell configuration (`~/.zshrc` or `~/.bashrc`):

```bash
# Alias for opening PDFs
alias pdf='zathura'

# Function to open most recent PDF in Downloads
pdflatest() {
    zathura "$(ls -t ~/Downloads/*.pdf | head -1)"
}
```

### Integration with Vim/Neovim

For LaTeX workflows, open compiled PDFs from Vim:

```vim
" In your .vimrc or init.vim
command! OpenPDF :!zathura %:r.pdf &
nnoremap <leader>p :OpenPDF<CR>
```

## Troubleshooting

### "Found no plugins" Error

This means the PDF plugin isn't properly linked. Re-run the plugin setup:

```bash
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
       $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
```

### Plugin Path Verification

Check if the plugin exists:

```bash
# Verify symlink
ls -la $(brew --prefix zathura)/lib/zathura/

# Check if target exists
ls -la $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib
```

### Homebrew Path Issues

For Apple Silicon Macs, Homebrew installs to `/opt/homebrew`.
For Intel Macs, Homebrew installs to `/usr/local`.

You can check your Homebrew prefix:
```bash
brew --prefix
```

### Reinstalling

If issues persist, completely reinstall:

```bash
# Remove old installation
brew uninstall zathura zathura-pdf-poppler
rm -rf ~/.config/zathura
rm -rf ~/.local/share/zathura

# Reinstall
brew install zathura zathura-pdf-poppler

# Set up plugin again
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
      $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
```

## EPUB Support

Zathura doesn't natively support EPUB files, but you can convert them to PDF using Calibre.

### Installation

```bash
brew install calibre
```

### Shell Functions

Add these functions to your `~/.zshrc` for easy EPUB handling:

```bash
# Convert EPUB to PDF and open in Zathura
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

# Convert EPUB to PDF without opening
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
```

### Usage

```bash
# Convert and open in Zathura
epub2pdf book.epub

# Convert only (doesn't open)
epub2pdf-only book.epub

# Direct conversion (manual)
ebook-convert book.epub book.pdf
zathura book.pdf
```

### Advanced Conversion Options

Calibre's `ebook-convert` supports many options:

```bash
# Convert with specific page size
ebook-convert book.epub book.pdf --paper-size a4

# Adjust margins
ebook-convert book.epub book.pdf --pdf-page-margin-left 36 --pdf-page-margin-right 36

# Custom font size
ebook-convert book.epub book.pdf --pdf-default-font-size 12

# Preserve cover
ebook-convert book.epub book.pdf --preserve-cover-aspect-ratio
```

For more options, see: `ebook-convert --help`

### Alternative EPUB Readers

If you prefer native EPUB reading:

- **Epy** (Terminal-based with vim keybindings): `brew install epy`
- **Foliate** (GUI reader): `brew install --cask foliate`

## Additional Resources

- [Official Zathura Documentation](https://pwmt.org/projects/zathura/)
- [Man Page](https://manpages.org/zathura): `man zathura`
- [Configuration Man Page](https://manpages.org/zathurarc): `man zathurarc`
- [GitHub Repository](https://github.com/pwmt/zathura)
- [Homebrew Formula Issue](https://github.com/zegervdv/homebrew-zathura/issues/19)
- [Calibre Documentation](https://manual.calibre-ebook.com/)

## Performance Tips

- For large PDFs, Zathura is significantly faster than Preview.app
- Use `set render-loading false` for faster initial load
- Adjust `set scroll-step` for smoother scrolling
- Use `set page-cache-size [number]` to control memory usage

## Notes

- Zathura uses girara as its UI library
- The Homebrew version is maintained by the community tap `homebrew-zathura`
- Plugin architecture allows for different backends (PDF, PostScript, DjVu, etc.)
- On macOS, only the PDF plugin is commonly used
