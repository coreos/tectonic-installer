package aws

import (
	"encoding/json"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/coreos/tectonic-installer/installer/server/aws/cloudforms"
	"io/ioutil"
	"os"
	"path/filepath"
	"strconv"
	"testing"
)

const (
	awsAccessKeyIdEnv     = "AWS_ACCESS_KEY_ID"
	awsSecretAccessKeyEnv = "AWS_SECRET_ACCESS_KEY"
	awsRegionEnv          = "AWS_REGION"
	clusterNameEnv        = "CLUSTER_NAME"
)

// Returns aws api client
func getAWSClient(t *testing.T) *ec2.EC2 {
	awsAccessKeyId := os.Getenv(awsAccessKeyIdEnv)
	awsSecretAccessKey := os.Getenv(awsSecretAccessKeyEnv)
	awsRegion := os.Getenv(awsRegionEnv)

	if awsAccessKeyId == "" || awsSecretAccessKey == "" {
		t.Fatal("AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY env variables are not set")
	}
	sess := session.Must(session.NewSession())
	creds := credentials.NewStaticCredentials(awsAccessKeyId, awsSecretAccessKey, "")
	client := ec2.New(sess, &aws.Config{Region: aws.String(awsRegion), Credentials: creds})
	return client
}

// Makes aws api's describe-instances call. Returns DescribeInstancesOutput
func getAwsInstances(t *testing.T) (*ec2.DescribeInstancesOutput, error) {

	clusterName := os.Getenv(clusterNameEnv)
	client := getAWSClient(t)
	params := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("instance-state-name"),
				Values: []*string{aws.String("running"), aws.String("pending")},
			},
			{
				Name:   aws.String("tag:KubernetesCluster"),
				Values: []*string{aws.String(clusterName)},
			},
		},
	}
	resp, err := client.DescribeInstances(params)
	return resp, err
}

// Makes aws api's describe-volumes call. Returns DescribeVolumesOutput
func getAwsVolumes(t *testing.T) (*ec2.DescribeVolumesOutput, error) {

	clusterName := os.Getenv(clusterNameEnv)
	client := getAWSClient(t)
	volumeParams := &ec2.DescribeVolumesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("status"),
				Values: []*string{aws.String("in-use")},
			},
			{
				Name:   aws.String("tag:KubernetesCluster"),
				Values: []*string{aws.String(clusterName)},
			},
		},
	}

	resp, err := client.DescribeVolumes(volumeParams)
	return resp, err
}

// Reads the aws payload from aws.json file
func readPayload() []byte {
	absPath, _ := filepath.Abs("../../examples/aws.json")
	file, err := ioutil.ReadFile(absPath)
	if err != nil {
		panic(err)
	}
	return file
}

// Unmarshal the json to cloudform config struct
func parsePayload(file []byte) *cloudforms.Config {

	res := cloudforms.Config{}
	//
	//var s struct {
	//	Cluster struct {
	//		Config Config `'json:"config"`
	//	} `json:"cluster"`
	//}

	err := json.Unmarshal([]byte(file), &res)
	if err != nil {
		panic(err)
	}
	return &res
}

// Helper func to read & parse payload
func getParsedPayload() *cloudforms.Config {
	file := readPayload()
	payloadMap := parsePayload(file)
	return payloadMap
}

// Makes aws api's describe-volumes call. Returns a map of count for size,Iops & volume type
func getActualVolume(t *testing.T, volumeT string) map[string]int {

	volume := make(map[string]int)
	var vtype string
	resp, err := getAwsVolumes(t)
	if err != nil {
		t.Fatalf("there was an error listing volumes in %s", err.Error())
	}
	for _, vol := range resp.Volumes {

		if volumeT == "size" {
			vtype = strconv.FormatInt(aws.Int64Value(vol.Size), 10)
		}
		if volumeT == "iops" {
			vtype = strconv.FormatInt(aws.Int64Value(vol.Iops), 10)
		}
		if volumeT == "volumeType" {
			vtype = aws.StringValue(vol.VolumeType)
		}

		if _, ok := volume[vtype]; ok {
			volume[vtype] = volume[vtype] + 1
		} else {
			volume[vtype] = 1
		}

	}
	return volume
}

// Returns a map of volumeSizes and its count
func getExpectedVolumeSizes(res *cloudforms.Config) map[string]int {

	volume := make(map[string]int)
	volume[strconv.Itoa(res.ETCDRootVolumeSize)] = res.ETCDCount

	if _, ok := volume[strconv.Itoa(res.ControllerRootVolumeSize)]; ok {
		volume[strconv.Itoa(res.ControllerRootVolumeSize)] = volume[strconv.Itoa(res.ControllerRootVolumeSize)] + res.ControllerCount
	} else {
		volume[strconv.Itoa(res.ControllerRootVolumeSize)] = res.ControllerCount
	}
	if _, ok := volume[strconv.Itoa(res.WorkerRootVolumeSize)]; ok {
		volume[strconv.Itoa(res.WorkerRootVolumeSize)] = volume[strconv.Itoa(res.WorkerRootVolumeSize)] + res.WorkerCount
	} else {
		volume[strconv.Itoa(res.WorkerRootVolumeSize)] = res.WorkerCount
	}

	return volume
}

// Returns a map of volumeIops and its count
func getExpectedVolumeIops(res *cloudforms.Config) map[string]int {

	volume := make(map[string]int)
	volume[strconv.Itoa(res.ETCDRootVolumeIOPS)] = res.ETCDCount

	if _, ok := volume[strconv.Itoa(res.ControllerRootVolumeIOPS)]; ok {
		volume[strconv.Itoa(res.ControllerRootVolumeIOPS)] = volume[strconv.Itoa(res.ControllerRootVolumeIOPS)] + res.ControllerCount
	} else {
		volume[strconv.Itoa(res.ControllerRootVolumeIOPS)] = res.ControllerCount
	}
	if _, ok := volume[strconv.Itoa(res.WorkerRootVolumeIOPS)]; ok {
		volume[strconv.Itoa(res.WorkerRootVolumeIOPS)] = volume[strconv.Itoa(res.WorkerRootVolumeIOPS)] + res.WorkerCount
	} else {
		volume[strconv.Itoa(res.WorkerRootVolumeIOPS)] = res.WorkerCount
	}

	return volume
}

// Returns a map of volumeTypes and its count
func getExpectedVolumeTypes(res *cloudforms.Config) map[string]int {

	volume := make(map[string]int)
	volume[res.ETCDRootVolumeType] = res.ETCDCount

	if _, ok := volume[res.ControllerRootVolumeType]; ok {
		volume[res.ControllerRootVolumeType] = volume[res.ControllerRootVolumeType] + res.ControllerCount
	} else {
		volume[res.ControllerRootVolumeType] = res.ControllerCount
	}
	if _, ok := volume[res.WorkerRootVolumeType]; ok {
		volume[res.WorkerRootVolumeType] = volume[res.WorkerRootVolumeType] + res.WorkerCount
	} else {
		volume[res.WorkerRootVolumeType] = res.WorkerCount
	}

	return volume
}

// Returns a map of instanceTypes and its count
func getActualInstanceTypes(t *testing.T) map[string]int {

	instance := make(map[string]int)
	var itype string

	resp, err := getAwsInstances(t)
	if err != nil {
		t.Fatalf("there was an error listing instances in %s", err.Error())
	}
	for idx := range resp.Reservations {
		//log.Printf(" Reservation Id: %s and Num Instances: %d ", *res.ReservationId, len(res.Instances))
		for _, inst := range resp.Reservations[idx].Instances {
			//log.Printf(" Instance Type: %s", *inst.InstanceType)
			itype = *inst.InstanceType

			if _, ok := instance[itype]; ok {
				instance[itype] = instance[itype] + 1
			} else {
				instance[itype] = 1
			}
		}
	}
	return instance
}

// Returns a map of instanceTypes and its count
func getExpectedInstanceTypes(res *cloudforms.Config) map[string]int {

	instance := make(map[string]int)
	instance[res.ETCDInstanceType] = res.ETCDCount

	if _, ok := instance[res.ControllerInstanceType]; ok {
		instance[res.ControllerInstanceType] = instance[res.ControllerInstanceType] + res.ControllerCount
	} else {
		instance[res.ControllerInstanceType] = res.ControllerCount
	}
	if _, ok := instance[res.WorkerInstanceType]; ok {
		instance[res.WorkerInstanceType] = instance[res.WorkerInstanceType] + res.WorkerCount
	} else {
		instance[res.WorkerInstanceType] = res.WorkerCount
	}

	return instance
}
