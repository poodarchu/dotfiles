-- init.lua - Modern Neovim Configuration for Warp Terminal
-- ========================================================

-- Performance optimizations - disable unused built-in plugins
local disabled_built_ins = {
  "gzip", "tar", "tarPlugin", "zip", "zipPlugin", "getscript", "getscriptPlugin",
  "vimball", "vimballPlugin", "2html_plugin", "logiPat", "rrhelper",
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "matchit", "matchparen", "spec"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Leader keys (set early)
vim.g.mapleader = '\\'
vim.g.maplocalleader = ','

-- Nerd Font detection
vim.g.have_nerd_font = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
  -- Core functionality
  {
    'tpope/vim-sensible',
    event = "VimEnter",
  },

  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<F3>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
      { "<F2>", "<cmd>Neotree reveal<cr>", desc = "Reveal in Neo-tree" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        container = {
          enable_character_fade = true
        },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = nil,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          provider = function(icon, node, state)
            if node.type == "file" or node.type == "terminal" then
              local success, web_devicons = pcall(require, "nvim-web-devicons")
              local name = node.type == "terminal" and "terminal" or node.name
              if success then
                local devicon, hl = web_devicons.get_icon(name)
                icon.text = devicon or ""
                icon.highlight = hl
              end
            end
          end,
          default = "*",
          highlight = "NeoTreeFileIcon"
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            added     = "", 
            modified  = "", 
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          }
        },
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
          hide_by_name = {
            "node_modules",
            "__pycache__",
            ".git",
            ".DS_Store",
            "thumbs.db",
          },
          hide_by_pattern = {
            "*.meta",
            "*/src/*/tsconfig.json",
          },
          always_show = {
            ".gitignored",
          },
          never_show = {
            ".DS_Store",
            "thumbs.db",
          },
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        group_empty_dirs = false,
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
      },
      window = {
        position = "left",
        width = 35,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<space>"] = { 
            "toggle_node", 
            nowait = false,
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel",
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
          ["l"] = "focus_preview",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["a"] = { 
            "add",
            config = {
              show_path = "none"
            }
          },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
        }
      },
    },
  },

  -- Web dev icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = {
      color_icons = true,
      default = true,
      strict = true,
    },
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
          else
            gitsigns.nav_hunk('next')
          end
        end, {desc = "Next Hunk"})

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
          else
            gitsigns.nav_hunk('prev')
          end
        end, {desc = "Prev Hunk"})

        -- Actions
        map('n', '<leader>ghs', gitsigns.stage_hunk, {desc = "Stage hunk"})
        map('n', '<leader>ghr', gitsigns.reset_hunk, {desc = "Reset hunk"})
        map('v', '<leader>ghs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = "Stage hunk"})
        map('v', '<leader>ghr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = "Reset hunk"})
        map('n', '<leader>ghS', gitsigns.stage_buffer, {desc = "Stage buffer"})
        map('n', '<leader>ghu', gitsigns.undo_stage_hunk, {desc = "Undo stage hunk"})
        map('n', '<leader>ghR', gitsigns.reset_buffer, {desc = "Reset buffer"})
        map('n', '<leader>ghp', gitsigns.preview_hunk, {desc = "Preview hunk"})
        map('n', '<leader>ghb', function() gitsigns.blame_line{full=true} end, {desc = "Blame line"})
        map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, {desc = "Toggle line blame"})
        map('n', '<leader>ghd', gitsigns.diffthis, {desc = "Diff this"})
        map('n', '<leader>ghD', function() gitsigns.diffthis('~') end, {desc = "Diff this ~"})
        map('n', '<leader>gtd', gitsigns.toggle_deleted, {desc = "Toggle deleted"})

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = "Select hunk"})
      end
    },
  },

  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Enhanced statusline
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'gruvbox-material',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return " " .. str
            end
          }
        },
        lualine_b = {
          {
            'branch',
            icon = '',
          },
          {
            'diff',
            symbols = {added = ' ', modified = ' ', removed = ' '},
            diff_color = {
              added = { fg = '#a7c080' },
              modified = { fg = '#ffdf1b' },
              removed = { fg = '#ff6666' },
            },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic', 'nvim_lsp' },
            symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
            diagnostics_color = {
              color_error = { fg = '#ff6666' },
              color_warn = { fg = '#ffdf1b' },
              color_info = { fg = '#7fbbb3' },
              color_hint = { fg = '#a7c080' },
            },
          }
        },
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = false,
            path = 1,
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          }
        },
        lualine_x = {
          {
            'encoding',
            fmt = string.upper,
          },
          {
            'fileformat',
            symbols = {
              unix = '',
              dos = '',
              mac = '',
            }
          },
          {
            'filetype',
            colored = true,
            icon_only = false,
            icon = { align = 'right' },
          }
        },
        lualine_y = {'progress'},
        lualine_z = {
          {
            'location',
            fmt = function(str)
              return str .. " "
            end
          }
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {'neo-tree', 'lazy', 'trouble', 'mason', 'fugitive'}
    },
  },

  -- Colorscheme
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_foreground = 'material'
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
      vim.g.gruvbox_material_ui_contrast = 'high'
      vim.cmd.colorscheme('gruvbox-material')
    end,
  },

  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        injected_languages = false,
        highlight = { "Function", "Label" },
        priority = 500,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,
        ts_config = {
          lua = {'string', 'source'},
          javascript = {'string', 'template_string'},
          java = false,
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        disable_in_macro = true,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        check_comma = true,
        map_cr = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
      })
    end,
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Find String" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = {
            "node_modules",
            "__pycache__",
            ".git/",
            "*.pyc",
            "target/",
            "dist/",
            "build/",
            "*.o",
            "*.a",
            "*.so",
            "*.dylib",
            ".DS_Store",
            "thumbs.db",
          },
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
          live_grep = {
            additional_args = function()
              return {"--hidden"}
            end
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              winblend = 10,
              width = 0.5,
              prompt = " ",
              results_height = 15,
              preview_cutoff = 1200,
            })
          },
        },
      })

      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },

  -- Session management
  {
    'folke/persistence.nvim',
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      pre_save = nil,
      save_empty = false,
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
      { "<leader>/", mode = { "n", "v" }, desc = "Comment toggle" },
    },
    config = function()
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
        extra = {
          above = 'gcO',
          below = 'gco',
          eol = 'gcA',
        },
        mappings = {
          basic = true,
          extra = true,
        },
        pre_hook = nil,
        post_hook = nil,
      })
      
      -- Additional comment mappings
      vim.keymap.set('n', '<leader>/', function()
        require('Comment.api').toggle.linewise.current()
      end, { desc = "Toggle comment line" })
      
      vim.keymap.set('v', '<leader>/', function()
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'nx', false)
        require('Comment.api').toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment selection" })
    end,
  },

  -- Enhanced dashboard (Startify theme with custom header)
  {
    'goolord/alpha-nvim',
    event = "VimEnter",
    dependencies = { 
      'nvim-tree/nvim-web-devicons',
      'echasnovski/mini.icons'
    },
    config = function()
      local alpha = require('alpha')
      local startify = require('alpha.themes.startify')

      -- Custom ASCII art for "Benjin ZHU"
      startify.section.header.val = {
        "",
        "",
        "██████╗ ███████╗███╗   ██╗     ██╗██╗███╗   ██╗    ███████╗██╗  ██╗██╗   ██╗",
        "██╔══██╗██╔════╝████╗  ██║     ██║██║████╗  ██║    ╚══███╔╝██║  ██║██║   ██║",
        "██████╔╝█████╗  ██╔██╗ ██║     ██║██║██╔██╗ ██║      ███╔╝ ███████║██║   ██║",
        "██╔══██╗██╔══╝  ██║╚██╗██║██   ██║██║██║╚██╗██║     ███╔╝  ██╔══██║██║   ██║",
        "██████╔╝███████╗██║ ╚████║╚█████╔╝██║██║ ╚████║    ███████╗██║  ██║╚██████╔╝",
        "╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚════╝ ╚═╝╚═╝  ╚═══╝    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ",
        "",
        "                         💻 Welcome to Neovim 💻                           ",
        "",
      }

      -- Customize the startify configuration
      startify.section.header.opts.hl = "Type"
      startify.section.header.opts.position = "center"

      -- Custom MRU (Most Recently Used) title
      startify.section.mru.val = {
        { type = "text", val = "Recent files", opts = { hl = "SpecialComment", shrink_margin = false, position = "center" } },
      }

      -- Add custom footer
      startify.section.bottom_buttons.val = {
        startify.button("q", "  Quit", ":qa<CR>"),
      }

      -- Set up the theme
      alpha.setup(startify.config)

      -- Add startup time to footer after lazy loading
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          
          -- Add startup info to the configuration
          startify.section.footer = {
            type = "text",
            val = " Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
            opts = { hl = "Comment", position = "center" }
          }
          
          -- Update the layout to include footer
          local config = startify.config
          table.insert(config.layout, { type = "padding", val = 1 })
          table.insert(config.layout, startify.section.footer)
          
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      -- Disable status and tablines for alpha
      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        desc = "disable status and tablines for alpha",
        callback = function()
          if vim.o.laststatus ~= 0 then
            vim.o.laststatus = 0
          end
          if vim.o.showtabline ~= 0 then
            vim.o.showtabline = 0
          end
        end,
      })

      -- Re-enable status and tablines after alpha
      vim.api.nvim_create_autocmd("BufUnload", {
        buffer = 0,
        desc = "enable status and tablines after alpha",
        callback = function()
          vim.o.laststatus = 3
          vim.o.showtabline = 2
        end,
      })
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim',
      'j-hui/fidget.nvim',
    },
  },

  -- LSP installer
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
  },

  -- LSP progress notifications
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = {
        window = {
          winblend = 100,
        },
      },
    },
  },

  -- Completion with enhanced icons
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
    },
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        sh = { "shfmt" },
      },
      format_on_save = false,
      formatters = {
        black = {
          prepend_args = { "--line-length", "120" },
        },
        isort = {
          prepend_args = { "--profile", "black", "--line-length", "120" },
        },
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "bash", "c", "html", "javascript", "json", "lua", "markdown",
          "python", "query", "regex", "tsx", "typescript", "vim", "yaml", 
          "cpp", "rust", "go", "dockerfile", "toml"
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          disable = { "python", "yaml" },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
              ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
              ["[A"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },

  -- Which-key (Updated for v3 API)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      preset = "modern",
      delay = function(ctx)
        return ctx.plugin and 0 or 200
      end,
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "git hunks" },
          { "<leader>gt", group = "git toggle" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>w", group = "windows" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "<leader>b", group = "buffer" },
          { "<leader>t", group = "toggle/terminal" },
          { "<leader>d", group = "debug" },
          { "<leader><tab>", group = "tabs" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
        },
      },
      keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      win = {
        border = "rounded",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
        winblend = 0,
        zindex = 1000,
      },
      layout = {
        width = { min = 20 },
        spacing = 3,
      },
      show_help = true,
      show_keys = true,
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
    },
  },

  -- Better diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      icons = true,
      fold_open = "",
      fold_closed = "",
      action_keys = {
        close = "q",
        cancel = "<esc>",
        refresh = "r",
        jump = {"<cr>", "<tab>"},
        open_split = { "<c-x>" },
        open_vsplit = { "<c-v>" },
        open_tab = { "<c-t>" },
        jump_close = {"o"},
        toggle_mode = "m",
        toggle_preview = "P",
        hover = "K",
        preview = "p",
        close_folds = {"zM", "zm"},
        open_folds = {"zR", "zr"},
        toggle_fold = {"zA", "za"},
        previous = "k",
        next = "j"
      },
      multiline = true,
      indent_lines = true,
      win_config = { border = "single" },
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      auto_jump = {"lsp_definitions"},
      signs = {
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "",
      },
      use_diagnostic_signs = false
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      { "gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP References (Trouble)" },
    },
  },

  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.3
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        }
      },
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end
      },
    },
  },

  -- Better UI
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({plugins = {"dressing.nvim"}})
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({plugins = {"dressing.nvim"}})
        return vim.ui.input(...)
      end
    end,
    opts = {
      input = {
        enabled = true,
        default_prompt = "Input:",
        trim_prompt = true,
        title_pos = "left",
        insert_only = true,
        start_in_insert = true,
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        buf_options = {},
        win_options = {
          winblend = 10,
          wrap = false,
          list = true,
          listchars = "precedes:…,extends:…",
          sidescrolloff = 0,
        },
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          i = {
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
            ["<Up>"] = "HistoryPrev",
            ["<Down>"] = "HistoryNext",
          },
        },
        override = function(conf)
          conf.col = -1
          conf.row = 0
          return conf
        end,
      },
      select = {
        enabled = true,
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        trim_prompt = true,
        telescope = nil,
        fzf = {
          window = {
            width = 0.5,
            height = 0.4,
          },
        },
        fzf_lua = {
          winopts = {
            height = 0.5,
            width = 0.5,
          },
        },
        nui = {
          position = "50%",
          size = nil,
          relative = "editor",
          border = {
            style = "rounded",
          },
          buf_options = {
            swapfile = false,
            filetype = "DressingSelect",
          },
          win_options = {
            winblend = 10,
          },
          max_width = 80,
          max_height = 40,
          min_width = 40,
          min_height = 10,
        },
        builtin = {
          show_numbers = true,
          border = "rounded",
          relative = "editor",
          buf_options = {},
          win_options = {
            winblend = 10,
            cursorline = true,
            cursorlineopt = "both",
          },
          width = nil,
          max_width = { 140, 0.8 },
          min_width = { 40, 0.2 },
          height = nil,
          max_height = 0.9,
          min_height = { 10, 0.2 },
          mappings = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
          },
        },
        format_item_override = {},
        get_config = nil,
      },
    },
  },

  -- Enhanced notifications
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      background_colour = "#000000",
      fps = 30,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "",
        WARN = ""
      },
      level = 2,
      minimum_width = 50,
      render = "default",
      stages = "fade_in_slide_out",
      top_down = true
    },
    init = function()
      vim.notify = require("notify")
    end,
  },

  -- Buffer management
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 30,
        max_prefix_length = 30,
        tab_size = 21,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {'close'}
        },
        sort_by = 'insert_after_current',
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left"
          }
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
}

-- Load plugins with lazy.nvim
require("lazy").setup(plugins, {
  defaults = {
    lazy = false,
    version = false,
  },
  ui = {
    border = "rounded",
    size = {
      width = 0.8,
      height = 0.8,
    },
    wrap = true,
    backdrop = 60,
    title = nil,
    title_pos = "center",
    pills = true,
    icons = {
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = " ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = " ",
      source = " ",
      start = "",
      task = " ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
    browser = nil,
    throttle = 20,
    custom_keys = {
      ["<localleader>l"] = {
        function(plugin)
          require("lazy.util").float_term(nil, {
            cwd = plugin.dir,
          })
        end,
        desc = "Open terminal in plugin dir",
      },
    },
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  checker = { 
    enabled = true, 
    notify = false,
    frequency = 3600,
  },
  change_detection = { 
    enabled = true,
    notify = false,
  },
  dev = {
    path = "~/projects",
    patterns = {},
    fallback = false,
  },
})

-- ===========================
-- BASIC SETTINGS
-- ===========================

local opt = vim.opt

-- Basic options
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath('data') .. '/undo'
opt.updatetime = 250
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.shiftround = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- UI
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = 'yes'
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = '120'
opt.termguicolors = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 0
opt.showmode = false
opt.showcmd = true
opt.cmdheight = 1
opt.conceallevel = 0
opt.showtabline = 2

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.shortmess:append("c")

-- Performance
opt.lazyredraw = false
opt.synmaxcol = 300
opt.redrawtime = 10000

-- Files
opt.autoread = true
opt.autowrite = true
opt.confirm = true
opt.hidden = true

-- Folding using Treesitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- Only set folding for supported filetypes
    local ft = vim.bo.filetype
    if ft ~= "" and ft ~= "help" and ft ~= "alpha" and ft ~= "dashboard" and ft ~= "neo-tree" and ft ~= "Trouble" and ft ~= "lazy" and ft ~= "mason" then
      vim.opt_local.foldmethod = 'expr'
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt_local.foldlevel = 99
      vim.opt_local.foldlevelstart = 99
      vim.opt_local.foldenable = true
    end
  end,
})

-- ===========================
-- AUTOCOMMANDS
-- ===========================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings
local general = augroup("General", { clear = true })

autocmd("TextYankPost", {
  group = general,
  desc = "Highlight on yank",
  callback = function()
    vim.highlight.on_yank({ 
      higroup = "Visual", 
      timeout = 200,
      on_visual = true,
    })
  end,
})

autocmd("BufReadPost", {
  group = general,
  desc = "Go to last loc when opening a buffer",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
  group = general,
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Remove trailing whitespace
autocmd("BufWritePre", {
  group = general,
  desc = "Remove trailing whitespace",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    pcall(function() vim.cmd([[%s/\s\+$//e]]) end)
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = general,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize splits if window got resized
autocmd({ "VimResized" }, {
  group = general,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = general,
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "dbout",
    "gitsigns.blame",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Make it easier to close man-files when opened inline
autocmd("FileType", {
  group = general,
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- File type specific settings
local filetype_settings = augroup("FileTypeSettings", { clear = true })

autocmd("FileType", {
  group = filetype_settings,
  pattern = { "python" },
  callback = function()
    vim.opt_local.colorcolumn = "120"
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

autocmd("FileType", {
  group = filetype_settings,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.colorcolumn = "100"
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

autocmd("FileType", {
  group = filetype_settings,
  pattern = { "lua", "yaml", "json", "html", "css", "javascript", "typescript", "markdown" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- ===========================
-- LSP SETUP (FIXED)
-- ===========================

-- Setup neodev first (for Lua development)
require('neodev').setup({
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = true,
  },
  setup_jsonls = true,
  lspconfig = true,
  pathStrict = true,
})

-- Setup Mason
require('mason').setup()

-- Setup lspconfig
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- Enhanced on_attach function (FIXED)
local on_attach = function(client, bufnr)
  -- Check if buffer is modifiable before setting options
  if vim.api.nvim_buf_get_option(bufnr, 'modifiable') then
    -- Enable completion triggered by <c-x><c-o>
    pcall(vim.api.nvim_buf_set_option, bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  end

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- LSP mappings
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', bufopts, { desc = "Go to declaration" }))
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', bufopts, { desc = "Go to definition" }))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', bufopts, { desc = "Hover" }))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', bufopts, { desc = "Go to implementation" }))
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend('force', bufopts, { desc = "Signature help" }))
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', bufopts, { desc = "Add workspace folder" }))
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', bufopts, { desc = "Remove workspace folder" }))
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend('force', bufopts, { desc = "List workspace folders" }))
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, vim.tbl_extend('force', bufopts, { desc = "Type definition" }))
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, vim.tbl_extend('force', bufopts, { desc = "Rename" }))
  vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', bufopts, { desc = "Code action" }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', bufopts, { desc = "References" }))

  -- Diagnostic mappings
  vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, vim.tbl_extend('force', bufopts, { desc = "Show line diagnostics" }))
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', bufopts, { desc = "Go to previous diagnostic" }))
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', bufopts, { desc = "Go to next diagnostic" }))
  vim.keymap.set('n', '<leader>cl', vim.diagnostic.setloclist, vim.tbl_extend('force', bufopts, { desc = "Set diagnostic loclist" }))

  -- Enhanced hover with better styling
  vim.keymap.set('n', '<leader>K', function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then
      vim.lsp.buf.hover()
    end
  end, vim.tbl_extend('force', bufopts, { desc = "Enhanced Hover" }))

  -- Document highlight
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", {
      clear = false
    })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- Format on save (only for modifiable buffers)
  if client.supports_method("textDocument/formatting") and vim.api.nvim_buf_get_option(bufnr, 'modifiable') then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
      buffer = bufnr,
      callback = function()
        -- Double-check modifiable before formatting
        if vim.api.nvim_buf_get_option(bufnr, 'modifiable') then
          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(c)
              return c.id == client.id
            end,
          })
        end
      end,
    })
  end
end

-- Setup mason-lspconfig with handlers
require('mason-lspconfig').setup({
  ensure_installed = { 'pylsp', 'clangd', 'lua_ls', 'rust_analyzer', 'ts_ls' },
  automatic_installation = true,
  handlers = {
    -- Default handler for all servers
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,

    -- Specific configurations for servers that need custom settings
    ["pylsp"] = function()
      lspconfig.pylsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { 
                enabled = true,
                maxLineLength = 120,
                ignore = {'E501'},
              },
              flake8 = { 
                enabled = false,
                maxLineLength = 120,
              },
              black = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              pylint = { enabled = true },
              pyflakes = { enabled = true },
              mccabe = { enabled = true },
              rope_completion = { enabled = true },
              rope_autoimport = { enabled = true },
            },
          },
        },
      })
    end,

    ["clangd"] = function()
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { 
          "clangd", 
          "--offset-encoding=utf-16",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })
    end,

    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = { 
              version = 'LuaJIT',
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              globals = {'vim'},
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              },
            },
            telemetry = { enable = false },
            hint = {
              enable = true,
              arrayIndex = "Disable",
              await = true,
              paramName = "Disable",
              paramType = true,
              semicolon = "Disable",
              setType = false,
            },
          },
        },
      })
    end,

    ["rust_analyzer"] = function()
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      })
    end,

    ["ts_ls"] = function()
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        init_options = {
          preferences = {
            disableSuggestions = true,
          }
        },
        commands = {
          OrganizeImports = {
            function()
              vim.lsp.buf.execute_command({
                command = "_typescript.organizeImports",
                arguments = {vim.api.nvim_buf_get_name(0)},
              })
            end,
            description = "Organize Imports",
          },
        },
      })
    end,
  },
})

-- ===========================
-- COMPLETION SETUP (ENHANCED)
-- ===========================

local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered({
      border = "rounded",
      winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
    }),
    documentation = cmp.config.window.bordered({
      border = "rounded",
      winhighlight = "Normal:CmpDoc",
    }),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ 
      behavior = cmp.ConfirmBehavior.Replace,
      select = true 
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    -- Enhanced navigation
    ['<Down>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Up>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
  }, {
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
      symbol_map = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      },
      before = function (entry, vim_item)
        return vim_item
      end
    }),
  },
  experimental = {
    ghost_text = true,
  },
  -- Enhanced completion behavior
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  preselect = cmp.PreselectMode.Item,
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?`.
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Integration with autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- ===========================
-- DIAGNOSTICS (ENHANCED)
-- ===========================

vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    -- Enhanced styling
    style = "minimal",
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    max_width = 0,
    max_height = 0,
    wrap = true,
    scope = "cursor",
  },
})

-- Enhanced diagnostic signs with proper icons
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ===========================
-- ENHANCED HOVER STYLING
-- ===========================

-- Override default hover handler for better styling
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    -- Dark grey background
    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
    max_width = 80,
    max_height = 20,
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    zindex = 1001,
  }
)

-- Enhanced signature help
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded",
    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
    max_width = 80,
    max_height = 15,
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    zindex = 1001,
  }
)

-- ===========================
-- KEY MAPPINGS (ENHANCED)
-- ===========================

local keymap = vim.keymap.set

-- Better up/down
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Move to window using the <ctrl> hjkl keys
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Clear search with <esc>
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
keymap(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
keymap("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
keymap("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
keymap("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
keymap("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
keymap("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
keymap("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
keymap("i", ",", ",<c-g>u")
keymap("i", ".", ".<c-g>u")
keymap("i", ";", ";<c-g>u")

-- Save file
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Lazy
keymap("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- New file
keymap("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- File operations (fixed to avoid conflicts)
keymap("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>fq", "<cmd>confirm q<cr>", { desc = "Quit file" })

-- Splits
keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- Tabs
keymap("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Git mappings
keymap("n", "<leader>ga", "<cmd>Gwrite<CR>", { desc = "Git add" })
keymap("n", "<leader>gc", "<cmd>Git commit --verbose<CR>", { desc = "Git commit" })
keymap("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
keymap("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
keymap("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff" })
keymap("n", "<leader>gl", "<cmd>Git log<CR>", { desc = "Git log" })

-- Buffer management (fixed to avoid conflicts)
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
keymap("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Python debugging / breakpoints
local function toggle_pdb_above()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = vim.api.nvim_get_current_line():match('^%s*')
  local pdb_line = current_indent .. "import pdb; pdb.set_trace()  # Breakpoint"

  if current_line == 1 then
    local line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if vim.trim(line_content) == vim.trim(pdb_line) then
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
      vim.notify("Breakpoint removed from line 1.", vim.log.levels.INFO)
    else
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {pdb_line})
      vim.notify("Breakpoint added at line 1.", vim.log.levels.INFO)
    end
  else
    local line_above = vim.api.nvim_buf_get_lines(0, current_line - 2, current_line - 1, false)[1] or ""
    if vim.trim(line_above) == vim.trim(pdb_line) then
      vim.api.nvim_buf_set_lines(0, current_line - 2, current_line - 1, false, {})
      vim.notify("Breakpoint removed from line " .. (current_line - 1) .. ".", vim.log.levels.INFO)
    else
      vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, {pdb_line})
      vim.notify("Breakpoint added above current line.", vim.log.levels.INFO)
    end
  end
end

-- Enhanced debugging and breakpoint shortcuts
keymap('n', '<leader>db', toggle_pdb_above, { desc = "Toggle PDB breakpoint" })
keymap('n', '<F9>', toggle_pdb_above, { desc = "Toggle breakpoint" })
keymap('n', '<leader>dB', function()
  -- Remove all breakpoints in current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local new_lines = {}
  local removed_count = 0
  
  for _, line in ipairs(lines) do
    if not line:match("import pdb; pdb%.set_trace%(%)") then
      table.insert(new_lines, line)
    else
      removed_count = removed_count + 1
    end
  end
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
  vim.notify("Removed " .. removed_count .. " breakpoints.", vim.log.levels.INFO)
end, { desc = "Remove all breakpoints" })

-- Terminal mappings
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Windows (fixed to avoid conflicts)
keymap("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
keymap("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
keymap("n", "<leader>ws", "<C-W>s", { desc = "Split window below", remap = true })
keymap("n", "<leader>wv", "<C-W>v", { desc = "Split window right", remap = true })

-- Quick quit (fixed to avoid conflicts with session management)
keymap("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Enhanced diagnostics navigation
keymap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
keymap("n", "]e", function() vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR}) end, { desc = "Next Error" })
keymap("n", "[e", function() vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR}) end, { desc = "Prev Error" })
keymap("n", "]w", function() vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN}) end, { desc = "Next Warning" })
keymap("n", "[w", function() vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN}) end, { desc = "Prev Warning" })

-- ===========================
-- ENHANCED UI STYLING
-- ===========================

-- Set up enhanced highlight groups for better UI
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Enhanced float windows with dark grey background
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2d2d2d", fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#2d2d2d", fg = "#7c6f64" })
    
    -- Enhanced completion menu
    vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#2d2d2d", fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "CmpSel", { bg = "#504945", fg = "#ffffff", bold = true })
    vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#1d2021", fg = "#ebdbb2" })
    
    -- Enhanced diagnostic virtual text
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", italic = true })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#fabd2f", italic = true })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#83a598", italic = true })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#8ec07c", italic = true })
  end,
})

-- ===========================
-- FINAL SETUP
-- ===========================

-- Load local config if exists
local local_config = vim.fn.stdpath("config") .. "/local_init.lua"
if vim.loop.fs_stat(local_config) then
  dofile(local_config)
end

-- Final notification
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.notify(" Neovim configuration loaded successfully!", vim.log.levels.INFO)
  end,
})

-- Test command for font icons
vim.api.nvim_create_user_command('TestIcons', function()
  local icons = {
    " Folder closed",
    " Folder open", 
    " File",
    " Git branch",
    " Modified",
    " Error",
    " Warning",
    " Info",
    " Hint",
    " Search",
    " Settings",
    " Terminal"
  }
  
  print("Testing Nerd Font icons:")
  for _, icon_text in ipairs(icons) do
    print(icon_text)
  end
end, { desc = "Test Nerd Font icons" })
