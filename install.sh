#!/usr/bin/env bash
# Ставит скиллы и субагентов в ~/.claude через симлинки.
# Симлинки, а не копии: git pull обновляет установленное без переустановки.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

SKILLS=(advisor architect)
AGENTS=(goal-context option-scout codebase-cartographer)

link() {
    local src="$1" dst="$2"

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "  = $dst (уже стоит)"
            return
        fi
        rm "$dst"
    elif [ -e "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$backup"
        echo "  ! $dst существовал, сохранён как $(basename "$backup")"
    fi

    ln -s "$src" "$dst"
    echo "  + $dst"
}

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"

echo "Репозиторий: $REPO_DIR"
echo "Установка в: $CLAUDE_DIR"
echo
echo "Скиллы:"
for s in "${SKILLS[@]}"; do
    link "$REPO_DIR/skills/$s" "$CLAUDE_DIR/skills/$s"
done

echo
echo "Субагенты:"
for a in "${AGENTS[@]}"; do
    link "$REPO_DIR/agents/$a.md" "$CLAUDE_DIR/agents/$a.md"
done

echo
echo "Готово. Перезапусти Claude Code, дальше — /advisor или /architect."
echo "Файл целей: $REPO_DIR/context/GOALS.md (пока пуст — /advisor предложит заполнить)"
