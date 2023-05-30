package prototest

import (
	"fmt"

	"github.com/google/go-cmp/cmp"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/testing/protocmp"
)

// TestingT is an interface wrapper around *testing.T.
type TestingT interface {
	Errorf(format string, args ...interface{})
}

// Equal implements cmp.Equal with nice test output for debugging.
//
// cmp.Diff is used to determine if the two proto objects are equal and returns a string
// representation of the diff if they are not. If Diff fails, the output is logged to test
// output, with a location of where the comparison failed.
//
// Options SHOULD be provided by the protocmp package. The protocmp.Transform() option does
// NOT need to be provided, it is supplied for you. EG:
//
//	prototest.Equal(t, message1, message2, protocmp.IgnoreFields(message2, "my_field"))
func Equal(t TestingT, expected proto.Message, actual proto.Message, opts ...cmp.Option) bool {
	opts = append(opts, protocmp.Transform())
	if diff := cmp.Diff(expected, actual, opts...); diff != "" {
		return fail(t, fmt.Sprintf("Not equal: \n"+diff))
	}
	return true
}
