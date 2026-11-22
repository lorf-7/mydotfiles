local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Noto Sans CJK SC', -- 如果你的系统中文字体名字不同，请替换
}
config.font_size = 12.0

return config
