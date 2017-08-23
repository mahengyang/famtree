Red [
	Title:	"生成家谱树"
	Author: "mahengyang"
	File:   %famtree.red
]

width: 800
height: 800
edge: 24 ;边距
gap: 24
word-gap: 5
word-width: 24
word-height: 24 ;20号字体，大小约为24px
half-word-width: word-width / 2
default-line-height: 10
default-line-width: 2
small: make font! [size: 20 name: "Consolas" style: 'bold]

#include %data.red

; 名字作为主键，方便查找
users: #()
genarations: #()
; 画板
my-draw: []

foreach node nodes [
	put users node/2 node
]

append my-draw compose [font small]
append my-draw compose [line-width (default-line-width) pen black]

no-sun: function ["检查有没有子代" name "姓名"] [
	user: select users name
	either user = none [true] [false]
]

calculate-x: function ["根据格子编号计算x左边" grid "x轴方向的格子编号"] [
	grid * gap - half-word-width + (edge * 3)
]

calculate-y: function [ "计算竖向格子的上边界坐标 上下两根竖线，字间距加字高，再加边距" 
						grid-y "距离上边界的格子数" ] [
	(grid-y - 1) * calculate-y-grid-height + edge
]

calculate-y-grid-height: function ["计算竖向格子的长度"] [
	word-count: 3
	(default-line-height * 2) + ((word-gap + word-height) * word-count)
]

calculate-middle-grid: function [
	"计算中间的格子"
	left-grid "最左边的格子"
	right-grid "最右边的格子"
] [
	left-grid + ((right-grid - left-grid) / 2)
]

draw-generation: function [ "画辈字" grid-y generation] [
	is-draw: select genarations generation
	if is-draw <> none [ return 1 ]
	x: edge / 2
	y: (calculate-y grid-y) + word-height + (default-line-height * 2)
	append my-draw reduce ['text as-pair x y (to string! generation)]
	put genarations generation 1
]

draw-all: function [
	"绘制指定用户及其所有后代"
	username "姓名"
	grid-x "x格子序号"
	grid-y "y格子序号"
	height "最大代数"
] [
	tab: copy ""
	loop (grid-y - 1) * 3 [ append tab " " ]
	print [tab ">>" username "grid-x:" grid-x "  grid-y:" grid-y "  height:" height]
	user: select users username
	suns: user/3
	sun-grid-y: grid-y + 1
	if height < sun-grid-y [ height: sun-grid-y ] ; 记录最大代数
	first-grid: grid-x
	last-grid: grid-x
	if suns <> none [
		append tab "  "
		i: 1
		foreach sun suns [
			vline-x: calculate-x grid-x
			either no-sun sun [
				print [tab "=" sun " grid-x:" grid-x "  grid-y:" sun-grid-y "  first" first-grid "  last" last-grid ]
				y: calculate-y sun-grid-y
				append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-height)]
				temp-y: y + default-line-height + word-gap
				sun-x: vline-x - half-word-width
				foreach w sun [
					append my-draw reduce ['text as-pair sun-x temp-y (to string! w)]
					temp-y: temp-y + word-height + word-gap
				]
				last-grid: grid-x
				grid-x: grid-x + 1 ; 当前格子后移一格
			] [
				result: draw-all sun grid-x sun-grid-y height
				grid-x: result/2
				last-grid: result/3 ;result/3 代表递归返回的父节点的grid-x
				height: result/4
				if i = 1 [
					; 如果第一个子节点递归返回的，重置first grid为此父节点的格子
					first-grid: last-grid
				]
			]
			grid-x: grid-x + 1 ; 间隔一格空白
			i: i + 1
		]
		grid-x: grid-x - 1 ; 去掉for循环里多加的最后一个空格
		tab: skip tab 2
	]
	; 上短竖线
	father-grid: calculate-middle-grid first-grid last-grid
	vline-x: calculate-x father-grid
	y: calculate-y grid-y
	print [tab "<<" username "父节点 grid-x" grid-x "  grid-y" grid-y "  first" first-grid "  last" last-grid "  middle" father-grid "  x" vline-x "  y" y]
	if grid-y > 1 [
		append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-height)]
	]
	y: y + default-line-height + word-gap
	; 名字
	x: vline-x - half-word-width
	foreach w username [
		append my-draw reduce ['text as-pair x y (to string! w)]
		y: y + word-height + word-gap
	]
	y: y - word-gap
	; 下短竖线
	either suns <> none [
		append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-height)]
		y: y + default-line-height
		; 横线
		hline-start: calculate-x first-grid
		hline-end: calculate-x last-grid
		append my-draw compose [line-cap flat line (as-pair hline-start y) (as-pair hline-end y)]
	] [
		grid-x: grid-x + 1
	]
	draw-generation grid-y user/1
	return reduce [username grid-x father-grid height]
]

result: draw-all nodes/1/2 1 1 1
width: (gap * result/2) + (edge * 3)
height: (calculate-y result/4) + (edge * 2)
print ["图片尺寸" width "x" height]
save %family-tree.png draw as-pair width height my-draw