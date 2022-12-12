# prototest
prototest is a small library that wraps proto.Equal with t.Log's detailed diff analysis to make comparing proto object easier. It is trying to improve the need to use the following code block "assert.True(t, ProtoObject1, ProtoObject2))", and provide a more detailed analysis when they are not equal.


# Install
go get github.com/yasv98/prototest

# Scope and Limitations

> List what is in-scope and out-of-scope in the module.

# How to use

> List of common example usages
> 
> Examples can be
> - pointing to a file in the module directory
> - code snippet

## Example scenario A (Init)
> When initialising the module, use the following code.

## Example scenario B (Use)
> When using module to do X, use the following code. 

# Unit testing 
> Explain how to easily mock the module functions for local tests. 