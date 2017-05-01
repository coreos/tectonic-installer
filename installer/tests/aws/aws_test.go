package aws

import (
	"reflect"
	"testing"
)


func TestAwsInstancesTypes(t *testing.T) {
	res := getParsedPayload()
	actualInstanceTypes := getActualInstanceTypes(t)
	expectedInstanceTypes := getExpectedInstanceTypes(res)

	if !reflect.DeepEqual(actualInstanceTypes, expectedInstanceTypes) {
		t.Fatalf("The Instances types actual:%+v doesn't match with expected:%+v", actualInstanceTypes, expectedInstanceTypes)
	}

}

func TestAwsVolumeSize(t *testing.T) {
	res := getParsedPayload()
	actualVolumeSize := getActualVolume(t,"size")
	expectedVolumeSize := getExpectedVolumeSizes(res)

	if !reflect.DeepEqual(actualVolumeSize, expectedVolumeSize) {
		t.Fatalf("The Volume sizes actual:%+v doesn't match the expected:%+v", actualVolumeSize, expectedVolumeSize)
	}
}

func TestAwsVolumeIops(t *testing.T) {
	res := getParsedPayload()

	actualVolumeIops := getActualVolume(t,"iops")
	expectedVolumeIops := getExpectedVolumeIops(res)

	if !reflect.DeepEqual(actualVolumeIops, expectedVolumeIops) {
		t.Fatalf("The Volume Iops actual:%+v doesn't match the expected:%+v", actualVolumeIops, expectedVolumeIops)
	}

}

func TestAwsVolumeTypes(t *testing.T) {
	res := getParsedPayload()

	actualVolumeType := getActualVolume(t,"volumeType")
	expectedVolumeType := getExpectedVolumeTypes(res)

	if !reflect.DeepEqual(actualVolumeType, expectedVolumeType) {
		t.Fatalf("The Volume Types actual:%+v doesn't match the expected:%+v", actualVolumeType, expectedVolumeType)
	}

}
