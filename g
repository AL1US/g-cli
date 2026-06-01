#!/bin/bash

print_help() {
    echo "Использование утилиты 'g':"
    echo "  g <сообщение>       - Добавить всё, закоммитить и запушить в текущую ветку"
    echo "  g init [<repo_url>] - Инициализировать репозиторий, создать README и запушить"
    echo "  g add ...           - Проброс команды git add"
    echo "  g commit ...        - Проброс команды git commit"
    echo "  g push ...          - Проброс команды git push"
    echo "  g help              - Показать эту справку"
}

# Если аргументов нет, показываем помощь
if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

# Функция подтверждения (Enter или Y/y продолжают, N/n отменяют)
confirm() {
    read -p "$1 [Y/n]: " choice
    case "$choice" in
        n|N) echo "Отменено."; exit 0 ;;
        *) return 0 ;;
    esac
}

CMD=$1

case "$CMD" in
    init)
        REPO_URL=$2
        if [ -z "$REPO_URL" ]; then
            read -p "Введите URL репозитория: " REPO_URL
        fi
        
        if [ -z "$REPO_URL" ]; then
            echo "Ошибка: URL не может быть пустым."
            exit 1
        fi

        confirm "Инициализировать репозиторий и запушить в $REPO_URL?"
        
        # Создаем README, если его нет
        if [ ! -f "README.md" ]; then 
            # Берет название текущей папки в качестве заголовка
            echo "# $(basename "$PWD")" > README.md
        fi
        
        git init
        git add README.md
        git commit -m "first commit"
        git branch -M main
        git remote add origin "$REPO_URL"
        git push -u origin main
        echo "✅ Готово!"
        ;;
    
    add|commit|push)
        # Пробрасываем напрямую в git
        git "$@"
        ;;
        
    help)
        print_help
        ;;
        
    *)
        # Все аргументы собираются в строку коммита
        MESSAGE="$*"
        confirm "Выполнить commit и push с сообщением: '$MESSAGE'?"
        
        git add .
        git commit -m "$MESSAGE"
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git push origin "$BRANCH"
        echo "✅ Готово!"
        ;;
esac