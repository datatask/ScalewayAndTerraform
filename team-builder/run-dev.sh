#!/bin/bash

export PORT=${PORT:=8080}
export GIN_MODE=${GIN_MODE:=debug}

export DB_HOST=${DB_HOST:-localhost}
export DB_PORT=${DB_PORT:-5432}
export DB_USER=${DB_USER:-postgres}
export DB_PASSWORD=${DB_PASSWORD:-postgres}
export DB_NAME=${DB_NAME:-companies}
export DB_SCHEMA=${DB_SCHEMA:-my_company}
export DB_EMPLOYEES_TABLE=${DB_EMPLOYEES_TABLE:-employees}

go run *.go
