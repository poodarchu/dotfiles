# AI-powered nvim IDE

## Nvim preparation

### Mac

```shell
curl -LO https://github.com/neovim/neovim/releases/download/v0.7.2/nvim-macos.tar.gz
tar -zxf nvim-macos.tar.gz
# add nvim to system PATH
# make alias to vi / vim
```

### Linux
```shell

curl -LO https://github.com/neovim/neovim/releases/download/v0.7.2/nvim.appimage
chmod u+x nvim.appimage
# add nvim.appimage to system PATH
# make alias to vi / vim
```

## Setup

1. move `init.vim` into directory `~/.config/nvim`
2. exec `vi` in command line, and VimPlug should automatically start installing process, or
   ```shell
   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   ```
3. optionally, you can exec `:PlugInstall` / `:PlugUpdate` to check whether all dependencies have been loaded as expected.

## Post-steps

```shell
pip install pynvim
pip install 'python-lsp-server[all]'
```

### Copilot
```shell 
# Install node.js
wget https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-x64.tar.xz

# Install coplit
git clone https://github.com/github/copilot.vim.git ~/.config/nvim/pack/github/start/copilot.vim

# Start Neovim and invoke
:Copilot setup
```
