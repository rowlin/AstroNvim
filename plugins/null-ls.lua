return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    -- Check supported formatters and linters
    local null_ls = require "null-ls"

    local helpers = require "null-ls.helpers"

    local markdownlint = {
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { "markdown" },
      -- null_ls.generator creates an async source
      -- that spawns the command with the given arguments and options
      generator = null_ls.generator {
        command = "markdownlint",
        args = { "--stdin" },
        to_stdin = true,
        from_stderr = true,
        -- choose an output format (raw, json, or line)
        format = "line",
        check_exit_code = function(code, stderr)
          local success = code <= 1

          if not success then
            -- can be noisy for things that run often (e.g. diagnostics), but can
            -- be useful for things that run on demand (e.g. formatting)
            print(stderr)
          end

          return success
        end,
        -- use helpers to parse the output from string matchers,
        -- or parse it manually with a function
        on_output = helpers.diagnostics.from_patterns {
          {
            pattern = [[:(%d+):(%d+) [%w-/]+ (.*)]],
            groups = { "row", "col", "message" },
          },
          {
            pattern = [[:(%d+) [%w-/]+ (.*)]],
            groups = { "row", "message" },
          },
        },
      },
    }

    null_ls.register(markdownlint)
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.phpcsfixer,
      null_ls.builtins.diagnostics.php,
      null_ls.builtins.completion.spell,
    }
    return config -- return final config table
  end,
}
