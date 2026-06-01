#!/bin/bash

# 1. Создаем сам скрипт утилиты 'g' во временной папке
cat << 'EOF' > /tmp/g_cli
#!/bin/bash

print_help() {
    echo "Использование утилиты 'g':"
    echo "  g <сообщение>       - Добавить всё (add .), закоммитить и запушить в текущую ветку"
    echo "  g init [<repo_url>] - Инициализировать репозиторий, создать README и запушить"
    echo "  g add ...           - Проброс команды git add"
    echo "  g commit ...        - Проброс команды git commit"
    echo "  g push ...          - Проброс команды git push"
}

# Если аргументов нет, показываем помощь
if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

CMD=$1

case "$CMD" in
    init)
        REPO_URL=$2
        # Запрашиваем URL, если он не передан
        if [ -z "$REPO_URL" ]; then
            read -p "Введите URL репозитория (например, https://github.com/user/repo.git): " REPO_URL
        fi

        if [ -z "$REPO_URL" ]; then
            echo "Ошибка: URL не может быть пустым."
            exit 1
        fi

        # Создаем README.md, если его нет
        if [ ! -f "README.md" ]; then
            echo "# Мой Проект" > README.md
        fi

        echo "Инициализация репозитория..."
        git init
        git add README.md
        git commit -m "first commit"
        git branch -M main
        git remote add origin "$REPO_URL"
        git push -u origin main
        echo "✅ Готово!"
        ;;
    add|commit|push)
        # Пробрасываем стандартные команды напрямую в git
        git "$@"
        ;;
    help)
        print_help
        ;;
    *)
        # Если команда нестандартная, считаем все аргументы текстом коммита
        MESSAGE="$*"
        echo "🚀 Выполняем быстрый коммит: '$MESSAGE'"
        
        git add .
        git commit -m "$MESSAGE"
        
        # Получаем текущую ветку и пушим
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git push origin "$BRANCH"
        ;;
esac
EOF

# 2. Делаем скрипт исполняемым
chmod +x /tmp/g_cli

# 3. Перемещаем в системную директорию
echo "🔑 Установка утилиты в /usr/local/bin (может потребоваться пароль)..."
sudo mv /tmp/g_cli /usr/local/bin/g

echo "✅ Установка завершена! Введите 'g help' для проверки."