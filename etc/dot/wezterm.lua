-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = 's3r0 modified (terminal.sexy)'
-- config.color_scheme = 'Sakura (base16)'
-- config.color_scheme = 'Solarized (light) (terminal.sexy)'
-- config.color_scheme = 'Solarized Light (Gogh)'
-- config.color_scheme = 'Neon'
-- config.color_scheme = 'Neon (terminal.sexy)'
-- config.color_scheme = 'Neon Night (Gogh)'


-- config.font = wezterm.font {
--   family = 'Monaspace Neon',
--   -- weight = 'DemiBold',
--   -- line_height = 0.8
-- }
config.font = wezterm.font {
  family = 'Hack Nerd Font Mono',
  -- weight = 'DemiBold'
}
config.harfbuzz_features = { 'calt', 'dlig', 'liga', 'SS03', 'SS04' }
-- config.font_shaper = Allsorts
config.font_shaper = Harfbuzz

config.window_decorations = "RESIZE"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane_title = tab.active_pane.title
  local user_title = tab.active_pane.user_vars.panetitle

  if user_title ~= nil and #user_title > 0 then
    pane_title = user_title
  end

  return {
    {Text=" " .. pane_title .. " "},
  }
end)

wezterm.on('gui-startup', function()
  local _, first_pane, window = mux.spawn_window {cwd = '/Users/byron/dev/github.com/builditdev/buildit-cli'}
  local _, second_pane, _ = window:spawn_tab {cwd = '/Users/byron/dev/github.com/builditdev/buildit-server'}
  local _, third_pane, _ = window:spawn_tab {cwd = '/Users/byron/dev/github.com/Byron/gitoxide'}
  local _, fourth_pane, _ = window:spawn_tab {cwd = '/Users/byron/dev/github.com/git/git'}
  local _, other_pane, _ = window:spawn_tab {}

  first_pane:send_text "rename_title buildit-cli\n"
  second_pane:send_text "rename_title buildit-server\n"
  third_pane:send_text "rename_title gitoxide\n"
  fourth_pane:send_text "rename_title git\n"
  other_pane:send_text "rename_title other\n"
end)

config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.text_background_opacity = 1.0
config.window_background_opacity = 0.918
config.macos_window_background_blur = 40
config.tab_max_width = 999
config.max_fps = 120

config.quick_select_patterns = {
  -- match filenames
  '[a-zA-Z0-9-_/]+\\.\\w+',
}

-- and finally, return the configuration to wezterm
return config
