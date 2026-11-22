# dotfiles

lorf 的个人 dotfiles，用**符号链接**管理：仓库是唯一的真实来源，`$HOME` 下只放指向仓库的链接。

## 布局

每个一级目录是一个“包”，包内相对路径与 `$HOME` 下完全一致（stow 风格），便于按主题增删。

```
dotfiles/
├── install.sh              # 安装脚本：建立符号链接，冲突文件先备份
├── bash/                   # Shell
│   ├── .bashrc             # 交互式 bash 配置（nvm、ble.sh、zoxide 等）
│   ├── .bash_aliases       # 自定义函数/别名
│   ├── .profile            # 登录 shell 配置，会 source .bashrc
│   └── .bash_logout
├── ble/
│   └── .blerc              # ble.sh 配置（abbrev、多终端历史共享）
├── git/
│   └── .gitconfig
├── tmux/
│   └── .tmux.conf          # 前缀键改为 C-a，鼠标、分屏与 vim 风格按键
└── wezterm/
    └── .wezterm.lua        # 字体 JetBrains Mono + 中文 fallback
```

安装后：

```
~/.bashrc      -> ~/dotfiles/bash/.bashrc
~/.tmux.conf   -> ~/dotfiles/tmux/.tmux.conf
~/.wezterm.lua -> ~/dotfiles/wezterm/.wezterm.lua
...
```

## 安装

```bash
git clone <仓库地址> ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # 先看看会动哪些文件
./install.sh             # 正式安装，冲突文件备份到 ~/.dotfiles-backup/<时间戳>/
exec bash -l             # 重新加载 shell 配置
```

脚本是幂等的：重复执行只会跳过已建好的链接；若 `$HOME` 下已有同名真实文件，会先移动到备份目录再建链接。

## 日常用法

- 直接编辑 `$HOME` 下的文件（例如 `vim ~/.bashrc`），因为它是符号链接，实际改的是仓库里的文件。
- 新增一个配置：在对应包里建同路径文件，`./install.sh` 建链接，然后提交。
  例如 `~/.config/foo/bar.conf` → 放进 `dotfiles/<包名>/.config/foo/bar.conf`；如需新包，把它加进 `install.sh` 的 `PACKAGES` 数组。
- 提交：`cd ~/dotfiles && git add -A && git commit -m "..."`。

## 没有纳入的东西

- `~/.config/nvim`：它本身是独立的 git 仓库（LazyVim starter），单独管理，避免嵌套仓库。
- `~/.zshrc`：目前为空，未启用 zsh。
- 隐私与机器相关文件：`.ssh/`、`.gnupg/`、`.bash_history`、`.local/`、各类 token/device 文件、应用缓存。
- `htop`/`btop`/`neofetch` 等会自动重写的生成型配置：暂不跟踪，避免噪声提交。

如果确实要跟踪某个生成型配置，按上面的“新增配置”步骤加进来即可。

## 依赖

`.bashrc` 会按需加载：`nvm`、`ble.sh`（`~/.local/share/blesh/ble.sh`）、`zoxide`；终端使用 WezTerm + tmux。
缺少这些组件不会报错，只是对应功能不生效。

## 备份与回滚

每次安装前的原文件都在 `~/.dotfiles-backup/<时间戳>/`，目录结构与 `$HOME` 一致。
回滚某个文件：删除 `$HOME` 下的符号链接，把备份移回原位。
