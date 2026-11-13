#!/usr/bin/env bash
# Ставит скиллы и субагентов в ~/.claude через симлинки.
# Симлинки, а не копии: git pull обновляет установленное без переустановки.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

SKILLS=(mentor architect)
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
echo "Инициализация локального контекста:"
if [ ! -f "$REPO_DIR/context/GOALS.md" ] && [ -f "$REPO_DIR/context/GOALS.template.md" ]; then
    cp "$REPO_DIR/context/GOALS.template.md" "$REPO_DIR/context/GOALS.md"
    echo "  + Создан context/GOALS.md из шаблона"
fi
if [ ! -f "$REPO_DIR/context/PRINCIPLES.md" ] && [ -f "$REPO_DIR/context/PRINCIPLES.template.md" ]; then
    cp "$REPO_DIR/context/PRINCIPLES.template.md" "$REPO_DIR/context/PRINCIPLES.md"
    echo "  + Создан context/PRINCIPLES.md из шаблона"
fi

echo
echo "Готово. Перезапусти Claude Code, дальше — /mentor или /architect."
echo "Файл целей: $REPO_DIR/context/GOALS.md (пока пуст — /mentor предложит заполнить)"

