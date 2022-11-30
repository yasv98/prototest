package prototest

import (
	"fmt"

	"github.com/stretchr/testify/assert"
	"google.golang.org/protobuf/proto"
)

func ProtoTest(t assert.TestingT, expected proto.Message, actual proto.Message) bool {
	if !proto.Equal(expected, actual) {
		return assert.Fail(t, fmt.Sprintf("Not equal: \n"+
			"expected: %s\n"+
			"actual  : %s", actual, expected))
	}
	return true
}
