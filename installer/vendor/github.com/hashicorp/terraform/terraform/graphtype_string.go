// Code generated by "stringer -type=GraphType context_graph_type.go"; DO NOT EDIT

package terraform

import "fmt"

const _GraphType_name = "GraphTypeInvalidGraphTypeLegacyGraphTypePlanGraphTypePlanDestroyGraphTypeApply"

var _GraphType_index = [...]uint8{0, 16, 31, 44, 64, 78}

func (i GraphType) String() string {
	if i >= GraphType(len(_GraphType_index)-1) {
		return fmt.Sprintf("GraphType(%d)", i)
	}
	return _GraphType_name[_GraphType_index[i]:_GraphType_index[i+1]]
}
