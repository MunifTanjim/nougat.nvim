local completion_store = {
  [""] = { "profile" },
  profile = { "bench", "start", "result", "stop" },
}

vim.api.nvim_create_user_command("Nougat", function(opts)
  local params = vim.split(opts.args, "%s+", { trimempty = true })

  local mod_name, action_name = params[1], params[2]
  if not mod_name then
    print("[Nougat] missing params")
    return
  end

  if mod_name == "profile" then
    if not action_name then
      print("[Nougat] missing params: " .. opts.args)
      return
    end

    local mod = require("nougat.profiler")

    if mod[action_name] then
      mod[action_name]()
      return
    end
  end

  print("[Nougat] unknow params: " .. opts.args)
end, {
  bang = true,
  nargs = "?",
  complete = function(_, cmd_line)
    local has_space = string.match(cmd_line, "%s$")
    local params = vim.split(cmd_line, "%s+", { trimempty = true })

    if #params == 1 then
      return completion_store[""]
    elseif #params == 2 and not has_space then
      return vim.tbl_filter(function(cmd)
        return not not string.find(cmd, "^" .. params[2])
      end, completion_store[""])
    end

    if #params >= 2 and completion_store[params[2]] then
      if #params == 2 then
        return completion_store[params[2]]
      elseif #params == 3 and not has_space then
        return vim.tbl_filter(function(cmd)
          return not not string.find(cmd, "^" .. params[3])
        end, completion_store[params[2]])
      end
    end
  end,
})
