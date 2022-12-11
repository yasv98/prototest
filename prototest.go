package prototest

import (
	"fmt"

	"google.golang.org/protobuf/proto"
)

// ProtoEqual wraps proto.Equal with a detailed diff analysis.
//
// proto.Equal is used to determine if the two proto objects are equal and return a bool if so.
// If not, it makes use of the func Fail to provide a detailed analysis of the diff between
// the expected and the actual output.
func ProtoEqual(t TestingT, expected proto.Message, actual proto.Message) bool {
	if !proto.Equal(expected, actual) {
		return fail(t, fmt.Sprintf("Not equal: \n"+
			"expected: %s\n"+
			"actual  : %s", expected, actual))
	}
	return true
}

// TestingT is an interface wrapper around *testing.T
type TestingT interface {
	Errorf(format string, args ...interface{})
}
