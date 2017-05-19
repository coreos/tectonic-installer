package aws

import (
	"testing"

	"github.com/hashicorp/terraform/helper/acctest"
	"github.com/hashicorp/terraform/helper/resource"
)

func TestAccAWSIAMAccountAlias_importBasic(t *testing.T) {
	resourceName := "aws_iam_account_alias.test"

	rstring := acctest.RandString(5)

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSIAMAccountAliasDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccAWSIAMAccountAliasConfig(rstring),
			},

			{
				ResourceName:      resourceName,
				ImportState:       true,
				ImportStateVerify: true,
			},
		},
	})
}
