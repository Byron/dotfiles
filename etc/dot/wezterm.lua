-- Pull in the wezterm API
local wezterm = require 'wezterm'

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

config.hide_tab_bar_if_only_one_tab = true

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

-- and finally, return the configuration to wezterm
return config
