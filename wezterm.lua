-- ~/.config/wezterm/wezterm.lua

local wezterm = require("wezterm")
local config = wezterm.config_builder() -- 設定ミスを起動時に警告してくれるビルダー

--------------------------------------------------------------------
-- font
--------------------------------------------------------------------
-- 並べた順に「その文字を持っているフォント」が使われる（フォールバック）。
-- 1番目: 英数字＋アイコン(Nerd Font)、2番目: 日本語、3番目: 絵文字。
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
  { family = "Noto Sans Mono CJK JP" },
  { family = "Noto Color Emoji" },
})

config.font_size = 10

config.warn_about_missing_glyphs = false -- 豆腐が出ても起動時の警告を出さない

-- 描画の効き方。ぼやける／細すぎると感じたら "Light" ↔ "Normal" を切り替える。
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"

-- リガチャ（-> が → に合体するやつ）が邪魔なら次行のコメントを外す
-- config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

--------------------------------------------------------------------
-- style
--------------------------------------------------------------------
config.color_scheme = "iceberg-dark"
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.hide_tab_bar_if_only_one_tab = false
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

--------------------------------------------------------------------
-- 挙動
--------------------------------------------------------------------
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.default_cursor_style = "BlinkingBlock"
-- config.default_prog = { "/usr/bin/zsh", "-l" }  -- 既定シェルを固定したい場合

--------------------------------------------------------------------
-- キーバインド
--------------------------------------------------------------------
-- 定義の実体は keys.lua。require は package.path の先頭にある
-- ~/.config/wezterm/?.lua から解決されるので拡張子もパスも不要。
config.keys = require("keys")

--------------------------------------------------------------------
-- タブの見た目
--------------------------------------------------------------------
-- 斜め（平行四辺形）タブ。use_fancy_tab_bar = false もこの中で入れている。
require("tabs").apply(config)

return config
