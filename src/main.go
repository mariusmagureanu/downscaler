package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/mariusmagureanu/downscaler/pkg/logger"
	"github.com/mariusmagureanu/downscaler/pkg/scaler"

	"os"
)

var (
	logLevel = logger.DebugLevel
)

func main() {
	logger.InitNewLogger(os.Stdout, logLevel)

	lambda.Start(scaler.Handler)
}
