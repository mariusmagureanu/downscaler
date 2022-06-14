package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
)

func main() {
	svc := autoscaling.New(session.New())
	input := &autoscaling.UpdateAutoScalingGroupInput{
		AutoScalingGroupName:             aws.String("eks-on-demand20220608104204984700000003-20c0a174-1e61-1e15-6e25-9f9bc6f4efcf"),
		MaxSize:                          aws.Int64(1),
		MinSize:                          aws.Int64(0),
		NewInstancesProtectedFromScaleIn: aws.Bool(true),
	}

	result, err := svc.UpdateAutoScalingGroup(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case autoscaling.ErrCodeScalingActivityInProgressFault:
				fmt.Println(autoscaling.ErrCodeScalingActivityInProgressFault, aerr.Error())
			case autoscaling.ErrCodeResourceContentionFault:
				fmt.Println(autoscaling.ErrCodeResourceContentionFault, aerr.Error())
			case autoscaling.ErrCodeServiceLinkedRoleFailure:
				fmt.Println(autoscaling.ErrCodeServiceLinkedRoleFailure, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)
}
