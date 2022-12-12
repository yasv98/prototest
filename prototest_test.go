package prototest_test

import (
	"fmt"
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
		Name: "Steve",
		Age:  29,
	}
	_ = personB

	personAClone := &person.Person{
		Name:   "Bob",
		Age:    32,
		Weight: 75.2,
	}

	personBClone := &person.Person{
		Name: "Steve",
		Age:  29,
	}

	mockT := new(testing.T)

	cases := []struct {
		expected *person.Person
		actual   *person.Person
		result   bool
	}{
		// Expected to be equal
		{personA, personAClone, true},
		{personB, personBClone, true},

		// Expected to be false
		{personA, personB, false},
		{personAClone, personBClone, false},
	}

	for _, c := range cases {
		t.Run(fmt.Sprintf("prototest.ProtoEqual(%v,%v)", c.expected.GetName(), c.actual.GetName()), func(t *testing.T) {
			res := prototest.ProtoEqual(mockT, c.expected, c.actual)
			if res != c.result {
				t.Errorf("prototest.ProtoEqual(%v,%v) should return %v", c.expected.GetName(), c.actual.GetName(), c.result)
			}
		})
	}

	// t.Run("successful_same_proto", func(t *testing.T) {
	// 	t.Parallel()
	// 	prototest.ProtoEqual(t, personA, personAClone)
	// })

	// t.Run("failure_detailed_diff_output", func(t *testing.T) {
	// 	t.Parallel()
	// 	assert.False(t, prototest.ProtoEqual(t, personA, personB))
	// })
}
