local Store = require("nougat.store").Store

local store = Store("nougat.bar.store", {
  statusline = {},
  tabline = {},
  winbar = {},
}, {
  clear = function(store)
    for _, val in pairs(store) do
      for k in pairs(val) do
        val[k] = nil
      end
    end
  end,
})

return store
