-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'ggandor/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    lazy = false,
    config = function()
      -- Keybinds
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
      vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

      -- Highly recommended: define a preview filter to reduce visual noise
      -- and the blinking effect after the first keypress
      -- (`:h leap.opts.preview`). You can still target any visible
      -- positions if needed, but you can define what is considered an
      -- exceptional case.
      -- Exclude whitespace and the middle of alphabetic words from preview:
      --   foobar[baaz] = quux
      --   ^----^^^--^^-^-^--^
      require('leap').opts.preview = function(ch0, ch1, ch2)
        return not (ch1:match '%s' or (ch0:match '%a' and ch1:match '%a' and ch2:match '%a'))
      end

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group:
      require('leap').opts.equivalence_classes = {
        ' \t\r\n',
        '([{',
        ')]}',
        '\'"`',
      }

      -- Use the traversal keys to repeat the previous motion without
      -- explicitly invoking Leap:
      require('leap.user').set_repeat_keys('<enter>', '<backspace>')
    end,
  },
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  {
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim
    'CopilotC-Nvim/CopilotChat.nvim',
    --  lazy = true,
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    -- build = "make tiktoken",
    opts = {
      model = 'gemini-3-pro-preview', -- or 'gpt-5.1-codex', 'claude-sonnet-4.5' etc (list with $)
      window = {
        width = 0.33, -- 0.25 was a bit too narrow with a terminal alongside
      },
      auto_insert_mode = true, -- Enter insert mode when opening
    },
    -- https://github.com/dusty-phillips/dotfiles/blob/93b14291b258210d30c4aabb876629bca330feb2/.config/nvim/lua/plugins/third-party.lua#L37
    -- (from https://www.reddit.com/r/neovim/comments/1cuzrlw/comment/l4pu0dp/)
    keys = {
      {
        '<Leader>cc',
        ":'<,'>CopilotChat<CR>",
        mode = { 'v' },
        desc = 'Copilot Chat Selection',
      },
      -- {
      --   '<Leader>ch',
      --   ':CopilotChatToggle<CR>',
      --   mode = { 'n' },
      --   desc = 'Toggle Copilot Chat',
      -- },
      {
        '<Leader>cc',
        function()
          local chat = require 'CopilotChat'
          -- 1. Save global split direction
          local current_setting = vim.opt.splitright:get()
          -- 2. Force split to go Left
          vim.opt.splitright = false
          -- 3. Toggle Window
          chat.toggle()
          -- 4. Restore global split direction
          vim.opt.splitright = current_setting
        end,
        mode = { 'n' },
        desc = 'Toggle Copilot Chat (Left)',
      },
    },
    -- Define the config function to apply opts and set up the autocommand
    config = function(_, opts)
      local chat = require 'CopilotChat'
      chat.setup(opts)

      vim.api.nvim_create_autocmd('BufWinEnter', {
        pattern = '*',
        callback = function()
          if vim.bo.filetype == 'copilot-chat' then
            -- vim.schedule ensures this runs AFTER the window is fully drawn
            vim.schedule(function()
              vim.opt_local.number = false
              vim.opt_local.relativenumber = false
              vim.opt_local.signcolumn = 'no'
            end)
          end
        end,
      })
    end,
  },
}
