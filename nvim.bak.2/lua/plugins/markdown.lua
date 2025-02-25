return {
	{
		"iamcco/markdown-preview.nvim",
		-- event = "VeryLazy",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown", "md" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end
	},
	{
		"ellisonleao/glow.nvim",
		-- event = "VeryLazy",
		cmd = "Glow",
		ft = { "markdown", "md" },
		opts = {
			style = "dark",
		},
	},
	{
		"OXY2DEV/markview.nvim",
		lazy = true,
		-- ft = { "markdown", "md" },
		cmd = "Markview",
	},
	{
		"terrastruct/d2-vim",
		enabled = true,
		lazy = true,
		ft = { "d2" },
	},
    {
  "3rd/diagram.nvim",
  dependencies = {
    "3rd/image.nvim",
  },
  opts = { -- you can just pass {}, defaults below
    renderer_options = {
      mermaid = {
        background = nil, -- nil | "transparent" | "white" | "#hex"
        theme = nil, -- nil | "default" | "dark" | "forest" | "neutral"
        scale = 1, -- nil | 1 (default) | 2  | 3 | ...
        width = nil, -- nil | 800 | 400 | ...
        height = nil, -- nil | 600 | 300 | ...
      },
      plantuml = {
        charset = nil,
      },
      d2 = {
        theme_id = nil,
        dark_theme_id = nil,
        scale = nil,
        layout = nil,
        sketch = nil,
      },
      gnuplot = {
        size = nil, -- nil | "800,600" | ...
        font = nil, -- nil | "Arial,12" | ...
        theme = nil, -- nil | "light" | "dark" | custom theme string
      },
    }
  },
}
}
