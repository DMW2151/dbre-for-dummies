package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	log "github.com/sirupsen/logrus"
)

var awsKMSRegion = ""                         // One of us-east-1, eu-cental-1, ap-south-2, etc...
var dbExercisesKeyAlias = "alias/ebs-kms-key" // alias to associate w. the key

func main() {

	// Create AWS Session
	sess := session.Must(session.NewSession(
		&aws.Config{
			Region: aws.String(awsKMSRegion),
		}),
	)

	// From AWS Session Create a KMS Key
	svc := kms.New(sess)

	result, err := svc.CreateKey(&kms.CreateKeyInput{})

	if err != nil {
		log.WithFields(
			log.Fields{"Error": err},
		).Error("Failed to Generate KMS Key")
		return
	}

	log.WithFields(
		log.Fields{
			"resultArn":  *result.KeyMetadata.Arn,
			"keyAccount": *result.KeyMetadata.AWSAccountId,
			"keyId":      *result.KeyMetadata.KeyId,
		},
	).Info("Generated KMS Key")

	_, err = svc.CreateAlias(&kms.CreateAliasInput{
		AliasName:   &dbExercisesKeyAlias,
		TargetKeyId: result.KeyMetadata.KeyId,
	})

	if err != nil {
		log.WithFields(
			log.Fields{"Error": err},
		).Error("Failed to Alias KMS Key")
		return
	}

	// Log Successful Test Key Generation...
	log.WithFields(
		log.Fields{
			"keyId": *result.KeyMetadata.KeyId,
			"alias": dbExercisesKeyAlias,
		},
	).Info("Created New KMS Key Alias")

}
