package main

import (
	"bytes"
	"fmt"
	"html/template"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DBClient *gorm.DB

func initDB() error {
	dbConfiguration := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", DBHost, DBPort, DBUser, DBPassword, DBName)

	var err error
	DBClient, err = gorm.Open(postgres.Open(dbConfiguration), &gorm.Config{})
	if err != nil {
		return fmt.Errorf("cannot create db client; %s", err.Error())
	}

	err = createSchemaIfNotExists()
	if err != nil {
		return fmt.Errorf("cannot create schema; %s", err.Error())
	}

	exists, err := checkIfTableExists(DBSchema, DBEmployeesTable)
	if err != nil {
		return fmt.Errorf("cannot check if the table %s.%s exists; %s", DBSchema, DBEmployeesTable, err.Error())
	}

	if !exists {
		err = createEmployeesTable()
		if err != nil {
			return fmt.Errorf("cannot create %s.%s table; %s", DBSchema, DBEmployeesTable, err.Error())
		}
	}

	return nil
}

func createSchemaIfNotExists() error {
	query := fmt.Sprintf(`CREATE SCHEMA IF NOT EXISTS 
		"%s" 
		AUTHORIZATION "%s";`, DBSchema, DBUser)

	if err := DBClient.Exec(
		query).Error; err != nil {
		return err
	}

	return nil
}

func checkIfTableExists(schemaname string, tablename string) (bool, error) {
	var exists bool

	err := DBClient.Raw(`SELECT EXISTS (
		SELECT FROM pg_tables 
		WHERE schemaname = ? 
		AND tablename = ?
	);`, schemaname, tablename).Scan(&exists).Error
	if err != nil {
		return false, err
	}

	return exists, nil
}

func createEmployeesTable() error {
	temp := template.Must(template.ParseFiles("./create-employees-table.sql"))

	type TemplateVars struct {
		DBUser           string
		DBSchema         string
		DBEmployeesTable string
	}

	templateVars := TemplateVars{
		DBUser:           DBUser,
		DBSchema:         DBSchema,
		DBEmployeesTable: DBEmployeesTable,
	}

	var query bytes.Buffer

	err := temp.Execute(&query, templateVars)
	if err != nil {
		return err
	}

	err = DBClient.Exec(query.String()).Error
	if err != nil {
		return err
	}

	return nil
}
