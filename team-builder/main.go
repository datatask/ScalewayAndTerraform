package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Employee struct {
	Email     string `json:"email" binding:"required"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	JobTitle  string `json:"jobt_itle" binding:"required"`
}

func (Employee) TableName() string {
	return fmt.Sprintf("%s.%s", DBSchema, DBEmployeesTable)
}

func main() {
	initEnv()
	initDB()

	gin.SetMode(GinMode)

	router := gin.Default()

	router.GET("/employee/list", listEmployees)
	router.POST("/employee/add", addEmployee)

	router.GET("/health", healthCheck)

	router.Run(fmt.Sprintf(":%s", Port))
}

func listEmployees(c *gin.Context) {
	employees := []Employee{}

	err := DBClient.Find(&employees).Error

	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"employees": employees})
}

func addEmployee(c *gin.Context) {
	newEmployee := Employee{}

	if err := c.ShouldBindJSON(&newEmployee); err != nil {
		c.JSON(http.StatusOK, gin.H{
			"error": err.Error(),
		})
		return
	}

	err := DBClient.Table(fmt.Sprintf("%s.%s", DBSchema, DBEmployeesTable)).Create(&newEmployee).Error
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"employee": newEmployee})
}

func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
