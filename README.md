# Neovim Configuration

## Setup

1. move `init.vim` into directory `~/.config/nvim`
2. exec `vi` in command line, and VimPlug should automatically start installing process, or
   ```shell
   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   ```

### Mac

```shell
# make sure you've install neovim, or
brew install neovim
pip install pynvim
pip install 'python-lsp-server[all]'

```

### Linux
```shell

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage

pip install pynvim
pip install 'python-lsp-server[all]'

```
