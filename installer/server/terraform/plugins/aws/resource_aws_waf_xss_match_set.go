package aws

import (
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/waf"
	"github.com/hashicorp/errwrap"
	"github.com/hashicorp/terraform/helper/schema"
)

func resourceAwsWafXssMatchSet() *schema.Resource {
	return &schema.Resource{
		Create: resourceAwsWafXssMatchSetCreate,
		Read:   resourceAwsWafXssMatchSetRead,
		Update: resourceAwsWafXssMatchSetUpdate,
		Delete: resourceAwsWafXssMatchSetDelete,

		Schema: map[string]*schema.Schema{
			"name": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"xss_match_tuples": &schema.Schema{
				Type:     schema.TypeSet,
				Required: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"field_to_match": {
							Type:     schema.TypeSet,
							Required: true,
							MaxItems: 1,
							Elem: &schema.Resource{
								Schema: map[string]*schema.Schema{
									"data": {
										Type:     schema.TypeString,
										Optional: true,
									},
									"type": {
										Type:     schema.TypeString,
										Required: true,
									},
								},
							},
						},
						"text_transformation": &schema.Schema{
							Type:     schema.TypeString,
							Required: true,
						},
					},
				},
			},
		},
	}
}

func resourceAwsWafXssMatchSetCreate(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn

	log.Printf("[INFO] Creating XssMatchSet: %s", d.Get("name").(string))

	// ChangeToken
	var ct *waf.GetChangeTokenInput

	res, err := conn.GetChangeToken(ct)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error getting change token: {{err}}", err)
	}

	params := &waf.CreateXssMatchSetInput{
		ChangeToken: res.ChangeToken,
		Name:        aws.String(d.Get("name").(string)),
	}

	resp, err := conn.CreateXssMatchSet(params)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error creating XssMatchSet: {{err}}", err)
	}

	d.SetId(*resp.XssMatchSet.XssMatchSetId)

	return resourceAwsWafXssMatchSetUpdate(d, meta)
}

func resourceAwsWafXssMatchSetRead(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn
	log.Printf("[INFO] Reading XssMatchSet: %s", d.Get("name").(string))
	params := &waf.GetXssMatchSetInput{
		XssMatchSetId: aws.String(d.Id()),
	}

	resp, err := conn.GetXssMatchSet(params)
	if err != nil {
		if awsErr, ok := err.(awserr.Error); ok && awsErr.Code() == "WAFNonexistentItemException" {
			log.Printf("[WARN] WAF IPSet (%s) not found, error code (404)", d.Id())
			d.SetId("")
			return nil
		}

		return err
	}

	d.Set("name", resp.XssMatchSet.Name)

	return nil
}

func resourceAwsWafXssMatchSetUpdate(d *schema.ResourceData, meta interface{}) error {
	log.Printf("[INFO] Updating XssMatchSet: %s", d.Get("name").(string))
	err := updateXssMatchSetResource(d, meta, waf.ChangeActionInsert)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error updating XssMatchSet: {{err}}", err)
	}
	return resourceAwsWafXssMatchSetRead(d, meta)
}

func resourceAwsWafXssMatchSetDelete(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn

	log.Printf("[INFO] Deleting XssMatchSet: %s", d.Get("name").(string))
	err := updateXssMatchSetResource(d, meta, waf.ChangeActionDelete)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error deleting XssMatchSet: {{err}}", err)
	}

	var ct *waf.GetChangeTokenInput

	resp, err := conn.GetChangeToken(ct)

	req := &waf.DeleteXssMatchSetInput{
		ChangeToken:   resp.ChangeToken,
		XssMatchSetId: aws.String(d.Id()),
	}

	_, err = conn.DeleteXssMatchSet(req)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error deleting XssMatchSet: {{err}}", err)
	}

	return nil
}

func updateXssMatchSetResource(d *schema.ResourceData, meta interface{}, ChangeAction string) error {
	conn := meta.(*AWSClient).wafconn

	var ct *waf.GetChangeTokenInput

	resp, err := conn.GetChangeToken(ct)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error getting change token: {{err}}", err)
	}

	req := &waf.UpdateXssMatchSetInput{
		ChangeToken:   resp.ChangeToken,
		XssMatchSetId: aws.String(d.Id()),
	}

	xssMatchTuples := d.Get("xss_match_tuples").(*schema.Set)
	for _, xssMatchTuple := range xssMatchTuples.List() {
		xmt := xssMatchTuple.(map[string]interface{})
		xssMatchTupleUpdate := &waf.XssMatchSetUpdate{
			Action: aws.String(ChangeAction),
			XssMatchTuple: &waf.XssMatchTuple{
				FieldToMatch:       expandFieldToMatch(xmt["field_to_match"].(*schema.Set).List()[0].(map[string]interface{})),
				TextTransformation: aws.String(xmt["text_transformation"].(string)),
			},
		}
		req.Updates = append(req.Updates, xssMatchTupleUpdate)
	}

	_, err = conn.UpdateXssMatchSet(req)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error updating XssMatchSet: {{err}}", err)
	}

	return nil
}
