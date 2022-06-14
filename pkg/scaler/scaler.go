package scaler

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
	"github.com/mariusmagureanu/downscaler/pkg/logger"
)

var (
	awsConfig    = aws.NewConfig()
	awsSession   *session.Session
	awsASGClient *autoscaling.AutoScaling
	err          error
)

const (
	// Minimum group capacity of the ASG after a scale up.
	scaleUpMinSize = 2

	// Minimum group capacity of the ASG after a scale down.
	scaleDownMinSize = 0

	scaleUpEventType   = "UP"
	scaleDownEventType = "DOWN"
)

type ScaleEvent struct {
	GroupName         string `json:"group_name"`
	Type              string `json:"scale_type"`
	MaxSizeUp         int64  `json:"scale_up_max_size"`
	MaxSizeDown       int64  `json:"scale_down_max_size"`
	ScaleInProtection bool   `json:"scale_in_protection"`
}

func Handler(scaleEvent ScaleEvent) {
	logger.Debug(scaleEvent.GroupName)
	awsSession, err = session.NewSession(awsConfig)

	if err != nil {
		logger.Error(err)
		return
	}

	awsASGClient = autoscaling.New(awsSession)

	var (
		maxSize *int64
		minSize *int64
	)

	switch scaleEvent.Type {
	case scaleUpEventType:
		logger.Debug("scaling up to", scaleEvent.MaxSizeUp)
		maxSize = aws.Int64(scaleEvent.MaxSizeUp)
		minSize = aws.Int64(scaleUpMinSize)
		break
	case scaleDownEventType:
		logger.Debug("scaling down to", scaleEvent.MaxSizeDown)
		maxSize = aws.Int64(scaleEvent.MaxSizeDown)
		minSize = aws.Int64(scaleDownMinSize)
	default:
		logger.Error("unknown scale event type")
		return
	}

	input := &autoscaling.UpdateAutoScalingGroupInput{
		AutoScalingGroupName:             aws.String(scaleEvent.GroupName),
		MaxSize:                          maxSize,
		MinSize:                          minSize,
		NewInstancesProtectedFromScaleIn: aws.Bool(scaleEvent.ScaleInProtection),
	}

	_, err := awsASGClient.UpdateAutoScalingGroup(input)
	if err != nil {
		logger.Error(err)
		return
	}
}
