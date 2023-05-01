# prototest
prototest is a small library that wraps proto.Equal with t.Log's detailed diff analysis to make comparing proto object easier. It is trying to improve the need to use the following code block "assert.True(t, ProtoObject1, ProtoObject2))", and provide a more detailed analysis when they are not equal.


# Install
go get github.com/yasv98/prototest
