package aws

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/hashicorp/errwrap"
	"github.com/hashicorp/terraform/helper/resource"
	"github.com/hashicorp/terraform/helper/schema"
)

func resourceAwsSsmDocument() *schema.Resource {
	return &schema.Resource{
		Create: resourceAwsSsmDocumentCreate,
		Read:   resourceAwsSsmDocumentRead,
		Update: resourceAwsSsmDocumentUpdate,
		Delete: resourceAwsSsmDocumentDelete,

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
			},
			"content": {
				Type:     schema.TypeString,
				Required: true,
			},
			"document_type": {
				Type:         schema.TypeString,
				Required:     true,
				ValidateFunc: validateAwsSSMDocumentType,
			},
			"created_date": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"default_version": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"description": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"hash": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"hash_type": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"latest_version": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"owner": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"status": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"platform_types": {
				Type:     schema.TypeList,
				Computed: true,
				Elem:     &schema.Schema{Type: schema.TypeString},
			},
			"parameter": {
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Optional: true,
						},
						"default_value": {
							Type:     schema.TypeString,
							Optional: true,
						},
						"description": {
							Type:     schema.TypeString,
							Optional: true,
						},
						"type": {
							Type:     schema.TypeString,
							Optional: true,
						},
					},
				},
			},
			"permissions": {
				Type:     schema.TypeMap,
				Optional: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"type": {
							Type:     schema.TypeString,
							Required: true,
						},
						"account_ids": {
							Type:     schema.TypeString,
							Required: true,
						},
					},
				},
			},
		},
	}
}

func resourceAwsSsmDocumentCreate(d *schema.ResourceData, meta interface{}) error {
	ssmconn := meta.(*AWSClient).ssmconn

	log.Printf("[INFO] Creating SSM Document: %s", d.Get("name").(string))

	docInput := &ssm.CreateDocumentInput{
		Name:         aws.String(d.Get("name").(string)),
		Content:      aws.String(d.Get("content").(string)),
		DocumentType: aws.String(d.Get("document_type").(string)),
	}

	log.Printf("[DEBUG] Waiting for SSM Document %q to be created", d.Get("name").(string))
	err := resource.Retry(5*time.Minute, func() *resource.RetryError {
		resp, err := ssmconn.CreateDocument(docInput)

		if err != nil {
			return resource.NonRetryableError(err)
		}

		d.SetId(*resp.DocumentDescription.Name)
		return nil
	})

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error creating SSM document: {{err}}", err)
	}

	if v, ok := d.GetOk("permissions"); ok && v != nil {
		if err := setDocumentPermissions(d, meta); err != nil {
			return err
		}
	} else {
		log.Printf("[DEBUG] Not setting permissions for %q", d.Id())
	}

	return resourceAwsSsmDocumentRead(d, meta)
}

func resourceAwsSsmDocumentRead(d *schema.ResourceData, meta interface{}) error {
	ssmconn := meta.(*AWSClient).ssmconn

	log.Printf("[DEBUG] Reading SSM Document: %s", d.Id())

	docInput := &ssm.DescribeDocumentInput{
		Name: aws.String(d.Get("name").(string)),
	}

	resp, err := ssmconn.DescribeDocument(docInput)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error describing SSM document: {{err}}", err)
	}

	doc := resp.Document
	d.Set("created_date", doc.CreatedDate)
	d.Set("default_version", doc.DefaultVersion)
	d.Set("description", doc.Description)

	if _, ok := d.GetOk("document_type"); ok {
		d.Set("document_type", doc.DocumentType)
	}

	d.Set("document_version", doc.DocumentVersion)
	d.Set("hash", doc.Hash)
	d.Set("hash_type", doc.HashType)
	d.Set("latest_version", doc.LatestVersion)
	d.Set("name", doc.Name)
	d.Set("owner", doc.Owner)
	d.Set("platform_types", flattenStringList(doc.PlatformTypes))

	d.Set("status", doc.Status)

	gp, err := getDocumentPermissions(d, meta)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error reading SSM document permissions: {{err}}", err)
	}

	d.Set("permissions", gp)

	params := make([]map[string]interface{}, 0)
	for i := 0; i < len(doc.Parameters); i++ {

		dp := doc.Parameters[i]
		param := make(map[string]interface{})

		if dp.DefaultValue != nil {
			param["default_value"] = *dp.DefaultValue
		}
		param["description"] = *dp.Description
		param["name"] = *dp.Name
		param["type"] = *dp.Type
		params = append(params, param)
	}

	if len(params) == 0 {
		params = make([]map[string]interface{}, 1)
	}

	if err := d.Set("parameter", params); err != nil {
		return err
	}

	return nil
}

func resourceAwsSsmDocumentUpdate(d *schema.ResourceData, meta interface{}) error {

	if _, ok := d.GetOk("permissions"); ok {
		if err := setDocumentPermissions(d, meta); err != nil {
			return err
		}
	} else {
		log.Printf("[DEBUG] Not setting document permissions on %q", d.Id())
	}

	return resourceAwsSsmDocumentRead(d, meta)
}

func resourceAwsSsmDocumentDelete(d *schema.ResourceData, meta interface{}) error {
	ssmconn := meta.(*AWSClient).ssmconn

	if err := deleteDocumentPermissions(d, meta); err != nil {
		return err
	}

	log.Printf("[INFO] Deleting SSM Document: %s", d.Id())

	params := &ssm.DeleteDocumentInput{
		Name: aws.String(d.Get("name").(string)),
	}

	_, err := ssmconn.DeleteDocument(params)
	if err != nil {
		return err
	}

	log.Printf("[DEBUG] Waiting for SSM Document %q to be deleted", d.Get("name").(string))
	err = resource.Retry(10*time.Minute, func() *resource.RetryError {
		_, err := ssmconn.DescribeDocument(&ssm.DescribeDocumentInput{
			Name: aws.String(d.Get("name").(string)),
		})

		if err != nil {
			awsErr, ok := err.(awserr.Error)
			if !ok {
				return resource.NonRetryableError(err)
			}

			if awsErr.Code() == "InvalidDocument" {
				return nil
			}

			return resource.NonRetryableError(err)
		}

		return resource.RetryableError(
			fmt.Errorf("%q: Timeout while waiting for the document to be deleted", d.Id()))
	})
	if err != nil {
		return err
	}

	d.SetId("")

	return nil
}

func setDocumentPermissions(d *schema.ResourceData, meta interface{}) error {
	ssmconn := meta.(*AWSClient).ssmconn

	log.Printf("[INFO] Setting permissions for document: %s", d.Id())
	permission := d.Get("permissions").(map[string]interface{})

	ids := aws.StringSlice([]string{permission["account_ids"].(string)})

	if strings.Contains(permission["account_ids"].(string), ",") {
		ids = aws.StringSlice(strings.Split(permission["account_ids"].(string), ","))
	}

	permInput := &ssm.ModifyDocumentPermissionInput{
		Name:            aws.String(d.Get("name").(string)),
		PermissionType:  aws.String(permission["type"].(string)),
		AccountIdsToAdd: ids,
	}

	_, err := ssmconn.ModifyDocumentPermission(permInput)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error setting permissions for SSM document: {{err}}", err)
	}

	return nil
}

func getDocumentPermissions(d *schema.ResourceData, meta interface{}) (map[string]interface{}, error) {
	ssmconn := meta.(*AWSClient).ssmconn

	log.Printf("[INFO] Getting permissions for document: %s", d.Id())

	//How to get from nested scheme resource?
	permissionType := "Share"

	permInput := &ssm.DescribeDocumentPermissionInput{
		Name:           aws.String(d.Get("name").(string)),
		PermissionType: aws.String(permissionType),
	}

	resp, err := ssmconn.DescribeDocumentPermission(permInput)

	if err != nil {
		return nil, errwrap.Wrapf("[ERROR] Error setting permissions for SSM document: {{err}}", err)
	}

	var account_ids = make([]string, len(resp.AccountIds))
	for i := 0; i < len(resp.AccountIds); i++ {
		account_ids[i] = *resp.AccountIds[i]
	}

	var ids = ""
	if len(account_ids) == 1 {
		ids = account_ids[0]
	} else if len(account_ids) > 1 {
		ids = strings.Join(account_ids, ",")
	} else {
		ids = ""
	}

	if ids == "" {
		return nil, nil
	}

	perms := make(map[string]interface{})
	perms["type"] = permissionType
	perms["account_ids"] = ids

	return perms, nil
}

func deleteDocumentPermissions(d *schema.ResourceData, meta interface{}) error {
	ssmconn := meta.(*AWSClient).ssmconn

	log.Printf("[INFO] Removing permissions from document: %s", d.Id())

	permInput := &ssm.ModifyDocumentPermissionInput{
		Name:               aws.String(d.Get("name").(string)),
		PermissionType:     aws.String("Share"),
		AccountIdsToRemove: aws.StringSlice(strings.Split("all", ",")),
	}

	_, err := ssmconn.ModifyDocumentPermission(permInput)

	if err != nil {
		return errwrap.Wrapf("[ERROR] Error removing permissions for SSM document: {{err}}", err)
	}

	return nil
}

func validateAwsSSMDocumentType(v interface{}, k string) (ws []string, errors []error) {
	value := v.(string)
	types := map[string]bool{
		"Command":    true,
		"Policy":     true,
		"Automation": true,
	}

	if !types[value] {
		errors = append(errors, fmt.Errorf("CodeBuild: Arifacts Namespace Type can only be NONE / BUILD_ID"))
	}
	return
}
