package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		printHelp()
		return
	}

	cmd := os.Args[1]

	// Обрабатываем базовые команды или запускаем "быстрый коммит"
	switch cmd {
	case "init":
		handleInit()
	case "add", "commit", "push":
		runGit(os.Args[1:]...)
	case "help":
		printHelp()
	default:
		// Если команда не стандартная, считаем весь ввод текстом коммита.
		// Это позволяет писать как g "текст", так и g текст без кавычек.
		handleQuickCommit(strings.Join(os.Args[1:], " "))
	}
}

func printHelp() {
	fmt.Println("Использование утилиты 'g':")
	fmt.Println("  g <сообщение>       - Добавить всё (add .), закоммитить и запушить в текущую ветку")
	fmt.Println("  g init [<repo_url>] - Инициализировать репозиторий, создать README, привязать origin и запушить")
	fmt.Println("  g add ...           - Проброс команды git add")
	fmt.Println("  g commit ...        - Проброс команды git commit")
	fmt.Println("  g push ...          - Проброс команды git push")
}

func handleInit() {
	repoURL := ""
	
	// Проверяем, передан ли URL аргументом (g init <url>)
	if len(os.Args) >= 3 {
		repoURL = os.Args[2]
	} else {
		// Если нет, запрашиваем через input
		fmt.Print("Введите URL репозитория (например, https://github.com/user/repo.git): ")
		reader := bufio.NewReader(os.Stdin)
		input, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println("Ошибка чтения ввода:", err)
			return
		}
		repoURL = strings.TrimSpace(input)
	}

	if repoURL == "" {
		fmt.Println("Ошибка: URL репозитория не может быть пустым.")
		return
	}

	// Создаем README.md, если его не существует, чтобы было что коммитить
	if _, err := os.Stat("README.md"); os.IsNotExist(err) {
		os.WriteFile("README.md", []byte("# Мой Проект\n"), 0644)
	}

	fmt.Println("Инициализация репозитория...")
	runGit("init")
	runGit("add", "README.md")
	runGit("commit", "-m", "first commit")
	runGit("branch", "-M", "main")
	runGit("remote", "add", "origin", repoURL)
	runGit("push", "-u", "origin", "main")
	fmt.Println("Готово! Репозиторий успешно инициализирован и отправлен на GitHub.")
}

func handleQuickCommit(message string) {
	fmt.Printf("Выполняем быстрый коммит с сообщением: '%s'\n", message)
	
	// 1. Добавляем все файлы
	runGit("add", ".")
	
	// 2. Делаем коммит
	runGit("commit", "-m", message)

	// 3. Получаем название текущей ветки
	out, err := exec.Command("git", "rev-parse", "--abbrev-ref", "HEAD").Output()
	if err != nil {
		fmt.Println("Ошибка: Не удалось определить текущую ветку.", err)
		return
	}
	branch := strings.TrimSpace(string(out))

	// 4. Пушим в текущую ветку
	runGit("push", "origin", branch)
}

// Вспомогательная функция для запуска git-команд
func runGit(args ...string) {
	cmd := exec.Command("git", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Printf("-> Ошибка при выполнении 'git %s'\n", strings.Join(args, " "))
	}
}