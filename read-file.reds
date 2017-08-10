Red [
	Title:	"测试文件读取"
	Author: "mahengyang"
	File:   %read-file.red
]

test1: function [x] [
	m: 1
	print ["m is" m]
	m: m + 1
	if x < 3 [
		test1 x + 1
		a: x
	]
	print ["a:" a]
	return m
]

test1 1