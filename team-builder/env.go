package main

import (
	"log"
	"os"
)

var Port = "8080"
var GinMode = "release"

var (
	DBHost           = ""
	DBPort           = ""
	DBUser           = ""
	DBPassword       = ""
	DBName           = ""
	DBSchema         = ""
	DBEmployeesTable = ""
)

func initEnv() {
	_port := os.Getenv("PORT")
	if _port != "" {
		Port = _port
	}

	_ginMode := os.Getenv("GIN_MODE")
	if _ginMode != "" {
		GinMode = _ginMode
	}

	DBHost = os.Getenv("DB_HOST")
	if DBHost == "" {
		log.Fatalln("DB_HOST not set")
	}

	DBPort = os.Getenv("DB_PORT")
	if DBPort == "" {
		log.Fatalln("DB_PORT not set")
	}

	DBUser = os.Getenv("DB_USER")
	if DBUser == "" {
		log.Fatalln("DB_USER not set")
	}

	DBPassword = os.Getenv("DB_PASSWORD")
	if DBPassword == "" {
		log.Fatalln("DB_PASSWORD not set")
	}

	DBName = os.Getenv("DB_NAME")
	if DBName == "" {
		log.Fatalln("DB_NAME not set")
	}

	DBSchema = os.Getenv("DB_SCHEMA")
	if DBSchema == "" {
		log.Fatalln("DB_SCHEMA not set")
	}

	DBEmployeesTable = os.Getenv("DB_EMPLOYEES_TABLE")
	if DBEmployeesTable == "" {
		log.Fatalln("DB_EMPLOYEES_TABLE not set")
	}
}
