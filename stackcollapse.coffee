fs = require "fs"
Path = require "path"

json = ""
process.stdin.on "data", (chunk) ->
	json += chunk
process.stdin.on "end", () ->
	data = JSON.parse(json)
	printStack data.head

printStack = (stack, prefix) ->
	name = "#{stack.functionName} - #{stack.url}"
	if prefix?
		name = "#{prefix};#{name}"
	console.log name, stack.hitCount
	for child in stack.children
		printStack child, name
