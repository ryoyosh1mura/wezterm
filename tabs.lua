-- ~/.config/wezterm/tabs.lua
-- タブの見た目。wezterm.lua から require("tabs").apply(config) で読む。

local wezterm = require("wezterm")

-- このファイルを編集したときも自動リロードが効くよう監視対象に加える。
wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/tabs.lua")

--------------------------------------------------------------------
-- 1. 色  
----------------------------------------------------------------------
-- 6 個とも "#rrggbb" の文字列。増やしたり減らしたりはしないこと。
local BAR_BG      = "#0f1117" -- タブバーの地（タブが無い部分）
local ACTIVE_BG   = "#F8B400" -- 選択中のタブの背景
local ACTIVE_FG   = "#161821" -- 選択中のタブの文字
local INACTIVE_BG = "#161825" -- 選択していないタブの背景
local INACTIVE_FG = "#6b7089" -- 選択していないタブの文字
local HOVER_FG    = "#c6c8d1" -- マウスを乗せたときの文字

--------------------------------------------------------------------
-- 2. 表示の好み  
--------------------------------------------------------------------
local MAX_WIDTH   = 32        -- タブ1個の最大幅（文字数）
local SHOW_INDEX  = true      -- "1: " のような番号を付けるか
local BOLD_ACTIVE = true      -- 選択中のタブを太字にするか

--------------------------------------------------------------------
-- 3. 描画  ★ここから下は仕組み。基本さわらない★
--------------------------------------------------------------------

-- 斜めの正体は「◤」(U+E0BC) というグリフ 1 文字。
-- 左上半分が前景色、右下半分が背景色で塗られるので、
--   前景色 = 左隣の色 / 背景色 = 自分の色
-- を指定すると、境界が "/" に斜めに切れる。これをタブの間に 1 個ずつ
-- 挟むことで、タブが平行四辺形に見える。
--   BAR ◤ tab1 ◤ tab2 ◤ BAR
local SLANT = utf8.char(0xe0bc)

-- タブ1個の背景色。ホバーでは背景を変えない（変えると隣のタブが描く
-- 仕切りグリフの色とズレて、継ぎ目が 1 セルだけ欠けて見えるため）。
local function bg_of(tab)
  return tab.is_active and ACTIVE_BG or INACTIVE_BG
end

-- タブに出す文字列を組み立てる。max_width に収まるよう末尾を切る。
local function title_of(tab, max_width)
  -- 明示的に付けた名前（tab:set_title）があればそれを優先
  local title = tab.tab_title
  if title == nil or #title == 0 then
    title = tab.active_pane.title
  end
  title = title:gsub("^%s+", ""):gsub("%s+$", "")

  local prefix = SHOW_INDEX and string.format(" %d: ", tab.tab_index + 1) or " "
  -- 仕切り 1 セル + prefix + 末尾の空白 1 セルを引いた残りが本文に使える幅
  local avail = max_width - 1 - #prefix - 1
  return prefix .. wezterm.truncate_right(title, math.max(avail, 1)) .. " "
end

-- ★注意★ この引数リストは WezTerm 側が決めている。名前は変えてよいが、
-- 順番と個数は変えてはいけない。使わない引数も _ を付けて残しておくこと。
-- （tab, tabs, panes, config, hover, max_width の 6 個で固定）
wezterm.on("format-tab-title", function(tab, tabs, _panes, _config, hover, max_width)
  local cur = bg_of(tab)

  -- 自分の左隣の色。先頭タブの左隣はタブバーの地。
  -- tab_index は 0 始まり / tabs は 1 始まりなので tabs[tab_index] が左隣。
  local prev = BAR_BG
  if tab.tab_index > 0 then
    prev = bg_of(tabs[tab.tab_index])
  end

  local fg = tab.is_active and ACTIVE_FG or (hover and HOVER_FG or INACTIVE_FG)
  local bold = (BOLD_ACTIVE and tab.is_active) and "Bold" or "Normal"

  local items = {
    -- 左の仕切り: 前景 = 左隣の色、背景 = 自分の色 → 境界が斜めになる
    { Background = { Color = cur } },
    { Foreground = { Color = prev } },
    { Text = SLANT },

    -- 本体
    { Background = { Color = cur } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = bold } },
    { Text = title_of(tab, max_width) },
  }

  -- 最後のタブだけ、右端の仕切りも自分で描いてタブバーの地に戻す
  if tab.tab_index == #tabs - 1 then
    table.insert(items, { Attribute = { Intensity = "Normal" } })
    table.insert(items, { Background = { Color = BAR_BG } })
    table.insert(items, { Foreground = { Color = cur } })
    table.insert(items, { Text = SLANT })
  end

  return items
end)

--------------------------------------------------------------------
-- config への適用
--------------------------------------------------------------------
local M = {}
function M.apply(config)
  config.use_fancy_tab_bar = false -- 斜めタブは文字セル描画（レトロ）でしか作れない
  config.tab_max_width = MAX_WIDTH

  -- color_scheme の上から tab_bar の色だけ差し替える
  config.colors = config.colors or {}
  config.colors.tab_bar = {
    background         = BAR_BG,
    active_tab         = { bg_color = ACTIVE_BG,   fg_color = ACTIVE_FG },
    inactive_tab       = { bg_color = INACTIVE_BG, fg_color = INACTIVE_FG },
    inactive_tab_hover = { bg_color = INACTIVE_BG, fg_color = HOVER_FG },
    new_tab            = { bg_color = BAR_BG,      fg_color = INACTIVE_FG },
    new_tab_hover      = { bg_color = BAR_BG,      fg_color = HOVER_FG },
  }
end

return M
