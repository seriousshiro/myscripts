package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

// список БД, которые надо проверять на наличие
var databases = []string{
	"ekd_ekd",
	"ekd_id",
	"ekd_calendar",
	"ekd_file",
}

const (
	host = "127.0.0.1"
	port = 5432
	user = "postgres"
	//	password = "password"
	dbname = "postgres"
)

func main() {
	// Получение значения пароля из переменной окружения
	password := os.Getenv("POSTGRES_PASSWORD")

	// Создание строки для подключения
	psqlConnect := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)

	// Подключение к БД
	db, err := sql.Open("postgres", psqlConnect)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close() // закрываем коннект к БД

	// Проверка существования БДшек

	for _, dbName := range databases {
		// Запрос в БД для получения true/false на предмет существования
		var exists bool
		// Формирование строки запроса
		query := fmt.Sprintf("SELECT EXISTS (SELECT 1 FROM pg_database WHERE datname = '%s')", dbName)
		// Запись запроса в переменную
		err = db.QueryRow(query).Scan(&exists)
		if err != nil {
			log.Fatal(err)
		}

		// Создаем БД, если ее нет
		if !exists {
			_, err = db.Exec(fmt.Sprintf("CREATE DATABASE %s", dbName))
			if err != nil {
				log.Fatal(err)
			}
			fmt.Printf("Database %s created\n", dbName)
		} else {
			fmt.Printf("Database %s already exists\n", dbName)
		}
	}
}
