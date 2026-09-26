-- Show hidden (dot) files in the file explorer and file picker.
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { hidden = true },
          files = { hidden = true },
        },
      },
    },
  },
}
