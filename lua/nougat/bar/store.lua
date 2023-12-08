local register_store = require("nougat.util.store").register

local store = register_store("nougat.bar.store", {
  statusline = {},
  tabline = {},
  winbar = {},
}, function(store)
  for _, value in pairs(store) do
    for key in pairs(value) do
      value[key] = nil
    end
  end
end)

return store
