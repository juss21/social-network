package main

import (
	"log"
	"os"
	"strconv"

	sqlDB "01.kood.tech/git/kasepuu/social-network/backend/database"
)

func main() {
	db, err := sqlDB.OpenDatabase()
	if err != nil {
		log.Fatalf("Error opening database: %v", err)
	}
	defer db.Close()

	sqlDB.DataBase = db
	log.Println("[SERVER] New database created.")
	// Proceed with starting the server
	port := getPort()
	StartServer(port) // server
}

func getPort() string {
	port := os.Getenv("PORT")
	if port != "" {
		return port
	}
	if len(os.Args) > 1 {
		if parsed, err := strconv.Atoi(os.Args[1]); err == nil {
			return strconv.Itoa(parsed)
		}
	}

	// 3. Fallback to default port
	return "8081"
}
