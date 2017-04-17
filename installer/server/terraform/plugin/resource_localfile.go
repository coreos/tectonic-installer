package plugin

import (
	"crypto/sha1"
	"encoding/hex"
	"io/ioutil"
	"os"
	"path"

	"github.com/hashicorp/terraform/helper/schema"
)

// ResourceLocalFile is a resource that allows users to write files locally.
func ResourceLocalFile() *schema.Resource {
	return &schema.Resource{
		Create: resourceLocalFileCreate,
		Read:   resourceLocalFileRead,
		Delete: resourceLocalFileDelete,

		Schema: map[string]*schema.Schema{
			"content": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"destination": {
				Type:        schema.TypeString,
				Description: "Path to the output file",
				Required:    true,
				ForceNew:    true,
			},
		},
	}
}

func resourceLocalFileRead(d *schema.ResourceData, _ interface{}) error {
	// If the output file doesn't exist, mark the resource for creation.
	outputPath := d.Get("destination").(string)
	if _, err := os.Stat(outputPath); os.IsNotExist(err) {
		d.SetId("")
		return nil
	}

	return nil
}

func resourceLocalFileCreate(d *schema.ResourceData, _ interface{}) error {
	content := d.Get("content").(string)
	destination := d.Get("destination").(string)

	destinationDir := path.Dir(destination)
	if _, err := os.Stat(destinationDir); err != nil {
		if err := os.MkdirAll(destinationDir, 0777); err != nil {
			return err
		}
	}

	if err := ioutil.WriteFile(destination, []byte(content), 0777); err != nil {
		return err
	}

	checksum := sha1.Sum([]byte(content))
	d.SetId(hex.EncodeToString(checksum[:]))

	return nil
}

func resourceLocalFileDelete(d *schema.ResourceData, _ interface{}) error {
	os.Remove(d.Get("destination").(string))
	return nil
}
