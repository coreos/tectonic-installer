package aws

import (
	"fmt"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/hashicorp/terraform/helper/acctest"
	"github.com/hashicorp/terraform/helper/resource"
	"github.com/hashicorp/terraform/terraform"
)

func TestAccAWSDBOptionGroup_basic(t *testing.T) {
	var v rds.OptionGroup
	rName := fmt.Sprintf("option-group-test-terraform-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSDBOptionGroupDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSDBOptionGroupBasicConfig(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					testAccCheckAWSDBOptionGroupAttributes(&v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
				),
			},
		},
	})
}

func TestAccAWSDBOptionGroup_basicDestroyWithInstance(t *testing.T) {
	rName := fmt.Sprintf("option-group-test-terraform-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSDBOptionGroupDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSDBOptionGroupBasicDestroyConfig(rName),
			},
		},
	})
}

func TestAccAWSDBOptionGroup_OptionSettings(t *testing.T) {
	var v rds.OptionGroup
	rName := fmt.Sprintf("option-group-test-terraform-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSDBOptionGroupDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSDBOptionGroupOptionSettings(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.#", "1"),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.961211605.option_settings.129825347.value", "UTC"),
				),
			},
			resource.TestStep{
				Config: testAccAWSDBOptionGroupOptionSettings_update(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.#", "1"),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.2422743510.option_settings.1350509764.value", "US/Pacific"),
				),
			},
		},
	})
}

func TestAccAWSDBOptionGroup_sqlServerOptionsUpdate(t *testing.T) {
	var v rds.OptionGroup
	rName := fmt.Sprintf("option-group-test-terraform-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSDBOptionGroupDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSDBOptionGroupSqlServerEEOptions(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
				),
			},

			resource.TestStep{
				Config: testAccAWSDBOptionGroupSqlServerEEOptions_update(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.#", "1"),
				),
			},
		},
	})
}

func TestAccAWSDBOptionGroup_multipleOptions(t *testing.T) {
	var v rds.OptionGroup
	rName := fmt.Sprintf("option-group-test-terraform-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSDBOptionGroupDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSDBOptionGroupMultipleOptions(rName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSDBOptionGroupExists("aws_db_option_group.bar", &v),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "name", rName),
					resource.TestCheckResourceAttr(
						"aws_db_option_group.bar", "option.#", "2"),
				),
			},
		},
	})
}

func testAccCheckAWSDBOptionGroupAttributes(v *rds.OptionGroup) resource.TestCheckFunc {
	return func(s *terraform.State) error {

		if *v.EngineName != "mysql" {
			return fmt.Errorf("bad engine_name: %#v", *v.EngineName)
		}

		if *v.MajorEngineVersion != "5.6" {
			return fmt.Errorf("bad major_engine_version: %#v", *v.MajorEngineVersion)
		}

		if *v.OptionGroupDescription != "Test option group for terraform" {
			return fmt.Errorf("bad option_group_description: %#v", *v.OptionGroupDescription)
		}

		return nil
	}
}

func TestResourceAWSDBOptionGroupName_validation(t *testing.T) {
	cases := []struct {
		Value    string
		ErrCount int
	}{
		{
			Value:    "testing123!",
			ErrCount: 1,
		},
		{
			Value:    "1testing123",
			ErrCount: 1,
		},
		{
			Value:    "testing--123",
			ErrCount: 1,
		},
		{
			Value:    "testing123-",
			ErrCount: 1,
		},
		{
			Value:    randomString(256),
			ErrCount: 1,
		},
	}

	for _, tc := range cases {
		_, errors := validateDbOptionGroupName(tc.Value, "aws_db_option_group_name")

		if len(errors) != tc.ErrCount {
			t.Fatalf("Expected the DB Option Group Name to trigger a validation error")
		}
	}
}

func testAccCheckAWSDBOptionGroupExists(n string, v *rds.OptionGroup) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		rs, ok := s.RootModule().Resources[n]
		if !ok {
			return fmt.Errorf("Not found: %s", n)
		}

		if rs.Primary.ID == "" {
			return fmt.Errorf("No DB Option Group Name is set")
		}

		conn := testAccProvider.Meta().(*AWSClient).rdsconn

		opts := rds.DescribeOptionGroupsInput{
			OptionGroupName: aws.String(rs.Primary.ID),
		}

		resp, err := conn.DescribeOptionGroups(&opts)

		if err != nil {
			return err
		}

		if len(resp.OptionGroupsList) != 1 ||
			*resp.OptionGroupsList[0].OptionGroupName != rs.Primary.ID {
			return fmt.Errorf("DB Option Group not found")
		}

		*v = *resp.OptionGroupsList[0]

		return nil
	}
}

func testAccCheckAWSDBOptionGroupDestroy(s *terraform.State) error {
	conn := testAccProvider.Meta().(*AWSClient).rdsconn

	for _, rs := range s.RootModule().Resources {
		if rs.Type != "aws_db_option_group" {
			continue
		}

		resp, err := conn.DescribeOptionGroups(
			&rds.DescribeOptionGroupsInput{
				OptionGroupName: aws.String(rs.Primary.ID),
			})

		if err == nil {
			if len(resp.OptionGroupsList) != 0 &&
				*resp.OptionGroupsList[0].OptionGroupName == rs.Primary.ID {
				return fmt.Errorf("DB Option Group still exists")
			}
		}

		// Verify the error
		newerr, ok := err.(awserr.Error)
		if !ok {
			return err
		}
		if newerr.Code() != "OptionGroupNotFoundFault" {
			return err
		}
	}

	return nil
}

func testAccAWSDBOptionGroupBasicConfig(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "mysql"
  major_engine_version     = "5.6"
}
`, r)
}

func testAccAWSDBOptionGroupBasicDestroyConfig(r string) string {
	return fmt.Sprintf(`
resource "aws_db_instance" "bar" {
	allocated_storage = 10
	engine = "MySQL"
	engine_version = "5.6.21"
	instance_class = "db.t2.micro"
	name = "baz"
	password = "barbarbarbar"
	username = "foo"


	# Maintenance Window is stored in lower case in the API, though not strictly
	# documented. Terraform will downcase this to match (as opposed to throw a
	# validation error).
	maintenance_window = "Fri:09:00-Fri:09:30"

	backup_retention_period = 0

	option_group_name = "${aws_db_option_group.bar.name}"
}

resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "mysql"
  major_engine_version     = "5.6"
}
`, r)
}

func testAccAWSDBOptionGroupOptionSettings(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "oracle-ee"
  major_engine_version     = "11.2"

  option {
    option_name = "Timezone"
    option_settings {
      name = "TIME_ZONE"
      value = "UTC"
    }
  }
}
`, r)
}

func testAccAWSDBOptionGroupOptionSettings_update(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "oracle-ee"
  major_engine_version     = "11.2"

  option {
    option_name = "Timezone"
    option_settings {
      name = "TIME_ZONE"
      value = "US/Pacific"
    }
  }
}
`, r)
}

func testAccAWSDBOptionGroupSqlServerEEOptions(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "sqlserver-ee"
  major_engine_version     = "11.00"
}
`, r)
}

func testAccAWSDBOptionGroupSqlServerEEOptions_update(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "sqlserver-ee"
  major_engine_version     = "11.00"

  option {
    option_name = "Mirroring"
  }
}
`, r)
}

func testAccAWSDBOptionGroupMultipleOptions(r string) string {
	return fmt.Sprintf(`
resource "aws_db_option_group" "bar" {
  name                     = "%s"
  option_group_description = "Test option group for terraform"
  engine_name              = "oracle-se"
  major_engine_version     = "11.2"

  option {
    option_name = "STATSPACK"
  }

  option {
    option_name = "XMLDB"
  }
}
`, r)
}
