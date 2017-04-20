// Copyright 2017 CoreOS, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package types

import (
	"errors"
	"strings"

	"github.com/coreos/ignition/config/validate/report"
)

var (
	ErrUnknownStrategy = errors.New("unknown reboot strategy")
)

type Locksmith struct {
	RebootStrategy RebootStrategy `yaml:"reboot-strategy"`
}

type RebootStrategy string

func (r RebootStrategy) Validate() report.Report {
	switch strings.ToLower(string(r)) {
	case "reboot", "etcd-lock", "off":
		return report.Report{}
	default:
		return report.ReportFromError(ErrUnknownStrategy, report.EntryError)
	}
}
