local M = {}

local health_start = vim.health.start or vim.health.report_start
local health_ok = vim.health.ok or vim.health.report_ok
local health_warn = vim.health.warn or vim.health.report_warn
local health_error = vim.health.error or vim.health.report_error
local health_info = vim.health.info or vim.health.report_info

function M.check()
  health_start("neoconf.nvim")

  local function info(msg, ...)
    health_info(msg:format(...))
  end

  local function ok(msg, ...)
    health_ok(msg:format(...))
  end

  local function warn(msg, ...)
    health_warn(msg:format(...))
  end

  local function error(msg, ...)
    health_warn(msg:format(...))
  end

  if pcall(vim.treesitter.get_string_parser, "", "jsonc") then
    ok("**jsonc** parser for tree-sitter is installed")
  else
    warn("**jsonc** parser for tree-sitter is not installed. Jsonc highlighting might be broken")
  end

  if pcall(require, "neodev") then
    warn("**neodev.nvim** is installed. lazydev.nvim is a much faster and better replacement for neodev")
  end

  if pcall(require, "lazydev") then
    ok("**lazydev.nvim** is installed")
  else
    warn("**lazydev.nvim** is not installed. You won't get any proper completion for your Neovim config.")
  end

  local _, lspconfig = pcall(require, "lspconfig.util")

  if lspconfig then
    ok("**lspconfig** is installed")
    local available = lspconfig.available_servers()
    if vim.tbl_contains(available, "jsonls") then
      ok("**lspconfig jsonls** is installed")
    else
      warn("**lspconfig jsonls** is not installed? You won't get any auto completion in your settings files")
    end
    if vim.tbl_contains(available, "lua_ls") then
      ok("**lspconfig lua_ls** is installed")
    else
      warn("**lspconfig lua_ls** is not installed? You won't get any auto completion in your lua settings files")
    end
  elseif vim.fn.has("nvim-0.11") == 1 then
    ok("**vim.lsp.config** is available (Neovim 0.11+)")
    local function has_server(name)
      return vim.lsp.config[name] ~= nil
    end
    if has_server("jsonls") then
      ok("**jsonls** is available via vim.lsp.config")
    else
      warn("**jsonls** is not available? You won't get any auto completion in your settings files")
    end
    if has_server("lua_ls") then
      ok("**lua_ls** is available via vim.lsp.config")
    else
      warn("**lua_ls** is not available? You won't get any auto completion in your lua settings files")
    end
  else
    error("**lspconfig** not installed?")
  end
end

function M.check_setup()
  local util = require("neoconf.util")
  if vim.fn.has("nvim-0.7.2") == 0 then
    util.error("**neoconf.nvim** requires Neovim >= 0.7.2")
  end

  if vim.fn.has("nvim-0.11") == 1 then
    -- Check if any configs are already enabled in vim.lsp.config
    local configs = vim.lsp.get_configs({ enabled = true })
    if #configs > 0 then
      util.error(
        [[Setup `require("neoconf").setup()` should be run **BEFORE** enabling any lsp server with vim.lsp.enable()]]
      )
    end
  end

  local lsputil = package.loaded["lspconfig.util"]
  if lsputil then
    if #lsputil.available_servers() == 0 then
      return true
    else
      util.error(
        [[Setup `require("neoconf").setup()` should be run **BEFORE** setting up any lsp server with lspconfig]]
      )
    end
  else
    -- lspconfig has not ben loaded yet
    -- so all is good
    return true
  end
end

return M
