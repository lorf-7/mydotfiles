#!/usr/bin/env bash
# 把仓库中的 dotfiles 以符号链接方式安装到 $HOME。
#
# 用法:
#   ./install.sh            安装（同名文件会先备份）
#   ./install.sh --dry-run  只打印将要执行的操作
#   ./install.sh --help     显示帮助
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
HOME_DIR="${HOME:?HOME 未设置}"
BACKUP_ROOT="$HOME_DIR/.dotfiles-backup"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"
DRY_RUN=0

# 每个一级目录都是一个“包”，目录内的相对路径与 $HOME 下的路径一致。
PACKAGES=(bash ble git tmux wezterm)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

usage() {
  cat <<'EOF'
用法: ./install.sh [选项]

把仓库里的 dotfiles 符号链接到 $HOME。重复执行是安全的：
已经指向本仓库的链接会跳过，其他同名文件会先备份到
~/.dotfiles-backup/<时间戳>/ 下（保持原相对路径）。

选项:
  -n, --dry-run   只打印操作，不修改任何文件
  -h, --help      显示本帮助
EOF
}

for arg in "$@"; do
  case "$arg" in
    -n | --dry-run) DRY_RUN=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf '未知参数: %s\n\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

run() {
  if ((DRY_RUN)); then
    printf '    [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

linked=0
skipped=0
backed_up=0

for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$REPO_DIR/$pkg"
  [[ -d "$pkg_dir" ]] || continue
  info "包: $pkg"
  while IFS= read -r -d '' src; do
    rel="${src#"$pkg_dir"/}"
    dest="$HOME_DIR/$rel"
    if [[ -L "$dest" && "$(readlink -- "$dest")" == "$src" ]]; then
      skipped=$((skipped + 1))
      continue
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
      warn "备份 $dest"
      run mkdir -p "$(dirname -- "$BACKUP_DIR/$rel")"
      run mv -- "$dest" "$BACKUP_DIR/$rel"
      backed_up=$((backed_up + 1))
    fi
    run mkdir -p "$(dirname -- "$dest")"
    run ln -s -- "$src" "$dest"
    printf '    链接 %s\n' "$dest"
    linked=$((linked + 1))
  done < <(find "$pkg_dir" -type f -print0 | sort -z)
done

printf '\n完成: 新建 %d 个链接，跳过 %d 个，备份 %d 个。\n' "$linked" "$skipped" "$backed_up"
if ((backed_up > 0)); then
  printf '原文件已备份到: %s\n' "$BACKUP_DIR"
  if ((DRY_RUN == 0)); then
    printf '回滚时把备份文件移回原位置，并删除对应符号链接即可。\n'
  fi
fi
if ((DRY_RUN)); then
  printf '（dry-run：未做任何修改）\n'
fi
