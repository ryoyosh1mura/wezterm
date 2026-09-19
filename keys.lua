-- ~/.config/wezterm/keys.lua
-- キーバインド定義だけを切り出したモジュール。
-- wezterm.lua 側から `config.keys = require("keys")` で読み込む。

local wezterm = require("wezterm")
local act = wezterm.action

-- このファイルを編集したときも自動リロードが効くよう監視対象に加える。
-- （WezTerm が既定で見張るのは wezterm.lua だけなので明示が必要）
wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/keys.lua")

return {
  -- ペイン分割（SplitHorizontal = 左右に割る / SplitVertical = 上下に割る）
  {
    key = "d", mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" })
  },
  {
    key = "e", mods = "CTRL|SHIFT",
    action = act.SplitPane({ direction = "Down" , size= {Percent = 30} })
  },

  -- ペインを閉じる（vim などが動いていて Ctrl+d が効かない時用）
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

  -- ペイン移動（vim と同じ hjkl 配列）
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

  -- フォントサイズ
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
}
