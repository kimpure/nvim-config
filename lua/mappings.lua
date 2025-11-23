local keymap = vim.keymap

keymap.set({ "n", "v" }, "d", '"_d', { noremap = true })
keymap.set("n", "dd", '"_dd', { noremap = true })
keymap.set("v", "D", '"_D', { noremap = true })

keymap.set("n", "<A-Right>", ":wincmd l<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-Left>", ":wincmd h<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-Down>", ":wincmd j<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-Up>", ":wincmd k<CR>", { noremap = true, silent = true })

keymap.set("n", "<A-l>", ":wincmd l<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-h>", ":wincmd h<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-j>", ":wincmd j<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-k>", ":wincmd k<CR>", { noremap = true, silent = true })

keymap.set("n", "<C-Right>", "w", { noremap = true, silent = true })
keymap.set("n", "<C-Left>", "b", { noremap = true, silent = true })

keymap.set("n", "<S-Up>", "<C-u>", { noremap = true, silent = true })
keymap.set("n", "<S-Down>", "<C-d>", { noremap = true, silent = true })

keymap.set("v", "<", "<gv", { noremap = true, silent = true })
keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
