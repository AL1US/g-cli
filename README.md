
# g-cli

Консольная утилита для упрощения работы с Git.

## Установка

1. Скачиваем
```bash
git clone https://github.com/AL1US/g-cli
cd g-cli
```
2. Запускаем
```bash
chmod +x install.sh
./install.sh
```

## Использование
- `g "текст коммита"` — автоматически выполняет git add ., git commit и git push в текущую ветку.

- `g init <url>` — инициализирует репозиторий, создает README и пушит в origin.

- `g <команда>` — пробрасывает стандартные команды (например, g add . или g push).

- `g help` — дополнительная информация

## Удаление
```bash
./uninstall.sh
```