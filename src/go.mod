module github.com/mariusmagureanu/downscaler/src

replace (
	github.com/mariusmagureanu/downscaler/pkg/logger => ../pkg/logger
	github.com/mariusmagureanu/downscaler/pkg/scaler => ../pkg/scaler
)

go 1.18

require (
	github.com/aws/aws-lambda-go v1.32.0
	github.com/mariusmagureanu/downscaler/pkg/logger v0.0.0-00010101000000-000000000000
	github.com/mariusmagureanu/downscaler/pkg/scaler v0.0.0-00010101000000-000000000000
)

require (
	github.com/aws/aws-sdk-go v1.44.32 // indirect
	github.com/jmespath/go-jmespath v0.4.0 // indirect
)
