package aws

import (
	"fmt"
	"testing"

	"github.com/hashicorp/terraform/helper/resource"
	"github.com/hashicorp/terraform/terraform"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/waf"
	"github.com/hashicorp/errwrap"
	"github.com/hashicorp/terraform/helper/acctest"
)

func TestAccAWSWafSizeConstraintSet_basic(t *testing.T) {
	var v waf.SizeConstraintSet
	sizeConstraintSet := fmt.Sprintf("sizeConstraintSet-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSWafSizeConstraintSetDestroy,
		Steps: []resource.TestStep{
			resource.TestStep{
				Config: testAccAWSWafSizeConstraintSetConfig(sizeConstraintSet),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSWafSizeConstraintSetExists("aws_waf_size_constraint_set.size_constraint_set", &v),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "name", sizeConstraintSet),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "size_constraints.#", "1"),
				),
			},
		},
	})
}

func TestAccAWSWafSizeConstraintSet_changeNameForceNew(t *testing.T) {
	var before, after waf.SizeConstraintSet
	sizeConstraintSet := fmt.Sprintf("sizeConstraintSet-%s", acctest.RandString(5))
	sizeConstraintSetNewName := fmt.Sprintf("sizeConstraintSet-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSWafSizeConstraintSetDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccAWSWafSizeConstraintSetConfig(sizeConstraintSet),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSWafSizeConstraintSetExists("aws_waf_size_constraint_set.size_constraint_set", &before),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "name", sizeConstraintSet),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "size_constraints.#", "1"),
				),
			},
			{
				Config: testAccAWSWafSizeConstraintSetConfigChangeName(sizeConstraintSetNewName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSWafSizeConstraintSetExists("aws_waf_size_constraint_set.size_constraint_set", &after),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "name", sizeConstraintSetNewName),
					resource.TestCheckResourceAttr(
						"aws_waf_size_constraint_set.size_constraint_set", "size_constraints.#", "1"),
				),
			},
		},
	})
}

func TestAccAWSWafSizeConstraintSet_disappears(t *testing.T) {
	var v waf.SizeConstraintSet
	sizeConstraintSet := fmt.Sprintf("sizeConstraintSet-%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckAWSWafSizeConstraintSetDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccAWSWafSizeConstraintSetConfig(sizeConstraintSet),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSWafSizeConstraintSetExists("aws_waf_size_constraint_set.size_constraint_set", &v),
					testAccCheckAWSWafSizeConstraintSetDisappears(&v),
				),
				ExpectNonEmptyPlan: true,
			},
		},
	})
}

func testAccCheckAWSWafSizeConstraintSetDisappears(v *waf.SizeConstraintSet) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		conn := testAccProvider.Meta().(*AWSClient).wafconn

		var ct *waf.GetChangeTokenInput

		resp, err := conn.GetChangeToken(ct)
		if err != nil {
			return fmt.Errorf("Error getting change token: %s", err)
		}

		req := &waf.UpdateSizeConstraintSetInput{
			ChangeToken:         resp.ChangeToken,
			SizeConstraintSetId: v.SizeConstraintSetId,
		}

		for _, sizeConstraint := range v.SizeConstraints {
			sizeConstraintUpdate := &waf.SizeConstraintSetUpdate{
				Action: aws.String("DELETE"),
				SizeConstraint: &waf.SizeConstraint{
					FieldToMatch:       sizeConstraint.FieldToMatch,
					ComparisonOperator: sizeConstraint.ComparisonOperator,
					Size:               sizeConstraint.Size,
					TextTransformation: sizeConstraint.TextTransformation,
				},
			}
			req.Updates = append(req.Updates, sizeConstraintUpdate)
		}
		_, err = conn.UpdateSizeConstraintSet(req)
		if err != nil {
			return errwrap.Wrapf("[ERROR] Error updating SizeConstraintSet: {{err}}", err)
		}

		resp, err = conn.GetChangeToken(ct)
		if err != nil {
			return errwrap.Wrapf("[ERROR] Error getting change token: {{err}}", err)
		}

		opts := &waf.DeleteSizeConstraintSetInput{
			ChangeToken:         resp.ChangeToken,
			SizeConstraintSetId: v.SizeConstraintSetId,
		}
		if _, err := conn.DeleteSizeConstraintSet(opts); err != nil {
			return err
		}
		return nil
	}
}

func testAccCheckAWSWafSizeConstraintSetExists(n string, v *waf.SizeConstraintSet) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		rs, ok := s.RootModule().Resources[n]
		if !ok {
			return fmt.Errorf("Not found: %s", n)
		}

		if rs.Primary.ID == "" {
			return fmt.Errorf("No WAF SizeConstraintSet ID is set")
		}

		conn := testAccProvider.Meta().(*AWSClient).wafconn
		resp, err := conn.GetSizeConstraintSet(&waf.GetSizeConstraintSetInput{
			SizeConstraintSetId: aws.String(rs.Primary.ID),
		})

		if err != nil {
			return err
		}

		if *resp.SizeConstraintSet.SizeConstraintSetId == rs.Primary.ID {
			*v = *resp.SizeConstraintSet
			return nil
		}

		return fmt.Errorf("WAF SizeConstraintSet (%s) not found", rs.Primary.ID)
	}
}

func testAccCheckAWSWafSizeConstraintSetDestroy(s *terraform.State) error {
	for _, rs := range s.RootModule().Resources {
		if rs.Type != "aws_waf_byte_match_set" {
			continue
		}

		conn := testAccProvider.Meta().(*AWSClient).wafconn
		resp, err := conn.GetSizeConstraintSet(
			&waf.GetSizeConstraintSetInput{
				SizeConstraintSetId: aws.String(rs.Primary.ID),
			})

		if err == nil {
			if *resp.SizeConstraintSet.SizeConstraintSetId == rs.Primary.ID {
				return fmt.Errorf("WAF SizeConstraintSet %s still exists", rs.Primary.ID)
			}
		}

		// Return nil if the SizeConstraintSet is already destroyed
		if awsErr, ok := err.(awserr.Error); ok {
			if awsErr.Code() == "WAFNonexistentItemException" {
				return nil
			}
		}

		return err
	}

	return nil
}

func testAccAWSWafSizeConstraintSetConfig(name string) string {
	return fmt.Sprintf(`
resource "aws_waf_size_constraint_set" "size_constraint_set" {
  name = "%s"
  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size = "4096"
    field_to_match {
      type = "BODY"
    }
  }
}`, name)
}

func testAccAWSWafSizeConstraintSetConfigChangeName(name string) string {
	return fmt.Sprintf(`
resource "aws_waf_size_constraint_set" "size_constraint_set" {
  name = "%s"
  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size = "4096"
    field_to_match {
      type = "BODY"
    }
  }
}`, name)
}
