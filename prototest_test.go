package prototest_test

import (
	"testing"

	"github.com/yasv98/prototest"
	"github.com/yasv98/prototest/internal/person"
)

func TestProtoEqual(t *testing.T) {
	personA := &person.Person{
		Name:   "Bob",
		Age:    32,
		Weight: 75.2,
	}

	personB := &person.Person{
		Name:   "Steve",
		Age:    29,
		Weight: 63.1,
	}

	personAClone := &person.Person{
		Name:   "Bob",
		Age:    32,
		Weight: 75.2,
	}

	t.Run("successful_same_proto", func(t *testing.T) {
		t.Parallel()
		prototest.ProtoEqual(t, personA, personAClone)
	})

	t.Run("failure_detailed_diff_output", func(t *testing.T) {
		t.Parallel()
		prototest.ProtoEqual(t, personA, personB)
	})
}
