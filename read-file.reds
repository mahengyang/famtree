Red [
	Title:	"测试文件读取"
	Author: "mahengyang"
	File:   %read-file.red
]

test1: function [x] [
	m: 1
	print ["m is" m]
	m: m + 1
	if x < 3 [test1 x + 1]
	return m
]


test2: function [x] [
	m: copy "1"
	print ["m is" m]
	append m "2"
	if x < 3 [test2 x + 1]
	return m
]

test1 1

test2 1