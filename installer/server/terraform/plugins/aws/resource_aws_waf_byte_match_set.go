package aws

import (
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/waf"
	"github.com/hashicorp/errwrap"
	"github.com/hashicorp/terraform/helper/schema"
)

func resourceAwsWafByteMatchSet() *schema.Resource {
	return &schema.Resource{
		Create: resourceAwsWafByteMatchSetCreate,
		Read:   resourceAwsWafByteMatchSetRead,
		Update: resourceAwsWafByteMatchSetUpdate,
		Delete: resourceAwsWafByteMatchSetDelete,

		Schema: map[string]*schema.Schema{
			"name": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"byte_match_tuples": &schema.Schema{
				Type:     schema.TypeSet,
				Optional: true,
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
						"positional_constraint": &schema.Schema{
							Type:     schema.TypeString,
							Required: true,
						},
						"target_string": &schema.Schema{
							Type:     schema.TypeString,
							Optional: true,
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

func resourceAwsWafByteMatchSetCreate(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn

	log.Printf("[INFO] Creating ByteMatchSet: %s", d.Get("name").(string))

	// ChangeToken
	var ct *waf.GetChangeTokenInput

	res, err := conn.GetChangeToken(ct)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error getting change token: {{err}}", err)
	}

	params := &waf.CreateByteMatchSetInput{
		ChangeToken: res.ChangeToken,
		Name:        aws.String(d.Get("name").(string)),
	}

	resp, err := conn.CreateByteMatchSet(params)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error creating ByteMatchSet: {{err}}", err)
	}

	d.SetId(*resp.ByteMatchSet.ByteMatchSetId)

	return resourceAwsWafByteMatchSetUpdate(d, meta)
}

func resourceAwsWafByteMatchSetRead(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn
	log.Printf("[INFO] Reading ByteMatchSet: %s", d.Get("name").(string))
	params := &waf.GetByteMatchSetInput{
		ByteMatchSetId: aws.String(d.Id()),
	}

	resp, err := conn.GetByteMatchSet(params)
	if err != nil {
		if awsErr, ok := err.(awserr.Error); ok && awsErr.Code() == "WAFNonexistentItemException" {
			log.Printf("[WARN] WAF IPSet (%s) not found, error code (404)", d.Id())
			d.SetId("")
			return nil
		}

		return err
	}

	d.Set("name", resp.ByteMatchSet.Name)

	return nil
}

func resourceAwsWafByteMatchSetUpdate(d *schema.ResourceData, meta interface{}) error {
	log.Printf("[INFO] Updating ByteMatchSet: %s", d.Get("name").(string))
	err := updateByteMatchSetResource(d, meta, waf.ChangeActionInsert)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error updating ByteMatchSet: {{err}}", err)
	}
	return resourceAwsWafByteMatchSetRead(d, meta)
}

func resourceAwsWafByteMatchSetDelete(d *schema.ResourceData, meta interface{}) error {
	conn := meta.(*AWSClient).wafconn

	log.Printf("[INFO] Deleting ByteMatchSet: %s", d.Get("name").(string))
	err := updateByteMatchSetResource(d, meta, waf.ChangeActionDelete)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error deleting ByteMatchSet: {{err}}", err)
	}

	var ct *waf.GetChangeTokenInput

	resp, err := conn.GetChangeToken(ct)

	req := &waf.DeleteByteMatchSetInput{
		ChangeToken:    resp.ChangeToken,
		ByteMatchSetId: aws.String(d.Id()),
	}

	_, err = conn.DeleteByteMatchSet(req)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error deleting ByteMatchSet: {{err}}", err)
	}

	return nil
}

func updateByteMatchSetResource(d *schema.ResourceData, meta interface{}, ChangeAction string) error {
	conn := meta.(*AWSClient).wafconn

	var ct *waf.GetChangeTokenInput

	resp, err := conn.GetChangeToken(ct)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error getting change token: {{err}}", err)
	}

	req := &waf.UpdateByteMatchSetInput{
		ChangeToken:    resp.ChangeToken,
		ByteMatchSetId: aws.String(d.Id()),
	}

	ByteMatchTuples := d.Get("byte_match_tuples").(*schema.Set)
	for _, ByteMatchTuple := range ByteMatchTuples.List() {
		ByteMatch := ByteMatchTuple.(map[string]interface{})
		ByteMatchUpdate := &waf.ByteMatchSetUpdate{
			Action: aws.String(ChangeAction),
			ByteMatchTuple: &waf.ByteMatchTuple{
				FieldToMatch:         expandFieldToMatch(ByteMatch["field_to_match"].(*schema.Set).List()[0].(map[string]interface{})),
				PositionalConstraint: aws.String(ByteMatch["positional_constraint"].(string)),
				TargetString:         []byte(ByteMatch["target_string"].(string)),
				TextTransformation:   aws.String(ByteMatch["text_transformation"].(string)),
			},
		}
		req.Updates = append(req.Updates, ByteMatchUpdate)
	}

	_, err = conn.UpdateByteMatchSet(req)
	if err != nil {
		return errwrap.Wrapf("[ERROR] Error updating ByteMatchSet: {{err}}", err)
	}

	return nil
}

func expandFieldToMatch(d map[string]interface{}) *waf.FieldToMatch {
	return &waf.FieldToMatch{
		Type: aws.String(d["type"].(string)),
		Data: aws.String(d["data"].(string)),
	}
}

func flattenFieldToMatch(fm *waf.FieldToMatch) map[string]interface{} {
	m := make(map[string]interface{})
	m["data"] = *fm.Data
	m["type"] = *fm.Type
	return m
}
