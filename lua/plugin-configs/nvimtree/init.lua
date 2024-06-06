local present, nvimtree = pcall(require, 'nvim-tree')

if present then
  require('base46').load_highlight('nvimtree')

  local api = require('nvim-tree.api')
  api.events.subscribe(api.events.Event.FileCreated, function(file)
    vim.cmd('edit ' .. file.fname)
  end)

  local git_add = function()
    local node = api.tree.get_node_under_cursor()
    local gs = node.git_status.file
    if gs == nil then
      gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
        or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
    end
    if gs == '??' or gs == 'MM' or gs == 'AM' or gs == ' M' then
      vim.cmd('silent !git add ' .. node.absolute_path)
    elseif gs == 'M ' or gs == 'A ' then
      vim.cmd('silent !git restore --staged ' .. node.absolute_path)
    end
    api.tree.reload()
  end

  local function on_attach(bufnr)
    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    -- 使用默认的mapping
    api.config.mappings.default_on_attach(bufnr)

    -- 添加自定义的mapping
    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
    -- 水平打开
    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', 'ga', git_add, opts('Git Add'))
  end

  nvimtree.setup({
    	-- needed by project-----
	  sync_root_with_cwd = true,
	  sort_by = "case_sensitive",

    disable_netrw = true,
    hijack_netrw = true,
    open_on_tab = true,
    hijack_cursor = false,
    update_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    on_attach = on_attach,
    view = {
      width = 30,
      side = 'left',
      adaptive_size = false,
      number = false,
      relativenumber = false,
    },
    actions = {
      open_file = {
        resize_window = tree,
        quit_on_open = tree,
      },
    },
    filters = {
      -- 显示.开头的文件
      dotfiles = false,
      -- 不显示 .git 目录中的内容
      custom = { '^.git$' },
      -- 显示 .gitignore,node_modules
      exclude = { 
        'node_modules',
        'gitignore' 
      },
    },
    renderer = {
      root_folder_label = false,
      highlight_git = true,
      indent_markers = {
        enable = false,
        inline_arrows = true,
        icons = {
          corner = "└",
          edge = "│",
          item = "│",
          bottom = "─",
          none = " ",
        },
      },
      icons = {
        webdev_colors = true,
        git_placement = 'before',
        padding = ' ',
        symlink_arrow = ' ➛ ',
        show = {
          file = true,
          folder = true,
          git = true,
          folder_arrow = false,
        },
        glyphs = {
          default = '󰈚',
          symlink = '',
          folder = {
            -- default = '',
            default = '',
            empty = '',
            empty_open = '',
            open = '',
            symlink = '',
            symlink_open = '',
            arrow_open = '',
            arrow_closed = '',
          },
          git = {
            unstaged = '',
            staged = '✓',
            unmerged = '',
            renamed = '➜',
            untracked = '★',
            deleted = '',
            untracked = 'u',
            ignored = '◌',
          },
        },
      },
    },
  })
end
