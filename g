#!/bin/bash

print_help() {
    echo "Использование утилиты 'g':"
    echo "  g <сообщение>       - Добавить всё (add .), закоммитить и запушить в текущую ветку"
    echo "  g init [<repo_url>] - Инициализировать репозиторий, создать README и запушить"
    echo "  g <команда>         - Проброс стандартных команд git (status, pull, clone, log и др.)"
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
            # В качестве заголовка берем название текущей папки
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
    
    # Белый список всех основных команд Git
    add|commit|push|pull|status|clone|checkout|branch|merge|rebase|stash|log|reset|fetch|tag|rm|mv|show|diff|grep)
        # Пробрасываем аргументы напрямую в git
        git "$@"
        ;;
        
    help)
        print_help
        ;;
        
    *)
        # Если команда не из белого списка, собираем все аргументы в строку коммита
        MESSAGE="$*"
        confirm "Выполнить commit и push с сообщением: '$MESSAGE'?"
        
        git add .
        git commit -m "$MESSAGE"
        
        # Определяем текущую ветку и пушим в неё
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git push origin "$BRANCH"
        echo "✅ Готово!"
        ;;
esac