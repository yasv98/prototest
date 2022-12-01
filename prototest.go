package prototest

import (
	"fmt"

	"github.com/stretchr/testify/assert"
	"google.golang.org/protobuf/proto"
)

// ProtoTest wraps proto.Equal wraps proto.Equal with a detailed diff analysis.
//
// proto.Equal is used to determine if the two proto objects are equal and return a bool if so.
// If not, it makes use of assert.fail func to provided detailed analysis of the diff between
// the expected and the actual.
func ProtoTest(t TestingT, expected proto.Message, actual proto.Message) bool {
	if !proto.Equal(expected, actual) {
		return assert.Fail(t, fmt.Sprintf("Not equal: \n"+
			"expected: %s\n"+
			"actual  : %s", actual, expected))
	}
	return true
}

// TestingT is an interface wrapper around *testing.T
type TestingT interface {
	Errorf(format string, args ...interface{})
}
