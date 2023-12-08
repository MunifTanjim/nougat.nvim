_G.__nougat_bar_util_deprecation_notice_disabled = true
local bu = require("nougat.bar.util")
package.loaded["nougat.bar.util"] = nil
_G.__nougat_bar_util_deprecation_notice_disabled = nil

local mod = {
  set_statusline = bu.set_statusline,
  refresh_statusline = bu.refresh_statusline,
  set_tabline = bu.set_tabline,
  refresh_tabline = bu.refresh_tabline,
  set_winbar = bu.set_winbar,
  refresh_winbar = bu.refresh_winbar,
}

return mod
