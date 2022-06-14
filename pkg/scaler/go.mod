module github.com/mariusmagureanu/downscaler/pkg/scaler

go 1.18

replace github.com/mariusmagureanu/downscaler/pkg/logger => ../logger

require (
	github.com/aws/aws-sdk-go v1.44.32
	github.com/mariusmagureanu/downscaler/pkg/logger v0.0.0-00010101000000-000000000000
)

require github.com/jmespath/go-jmespath v0.4.0 // indirect
