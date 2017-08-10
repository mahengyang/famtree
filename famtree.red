Red [
	Title:	"生成家谱树"
	Author: "mahengyang"
	File:   %famtree.red
]

width: 800
height: 800
edge: 24
gap: 24
word-gap: 5
word-width: 24
word-height: 24 ;20号字体，大小约为24px
half-word-width: word-width / 2
default-line-height: 10
default-line-width: 2
small: make font! [size: 20 name: "Consolas" style: 'bold]

node1: [
	父: "马中新"
	子: ["马端吉" "马端祥" "马端如" "马端意" "马端少"]
	字: "中"
]

node2: [
	父: "马端如"
	子: ["马泰心" "马泰德" "马泰功" "马泰名"]
	字: "端"
]

node3: [
	父: "马端少"
	子: ["马泰明" "马泰光" "马泰亮"]
	字: "端"
]

node4: [
	父: "马泰光"
	子: ["马守运" "马守伦" "马守礼"]
	字: "泰"
]

node5: [
	父: "马泰亮"
	子: ["马守清"]
	字: "泰"
]

node6: [
	父: "马守运"
	子: ["马文德" "马文才"]
	字: "守"
]

node7: [
	父: "马守礼"
	子: ["马文孝" "马文义" "马文鸿" "马 超" "马 越"]
	字: "守"
]

nodes: reduce [node1 node2 node3 node4 node5 node6 node7]

; 名字作为主键，方便查找
users: make map! []
; 画板
my-draw: make block! 1
node-grid: make map! []

foreach node nodes [
	put users node/父 node
]

append my-draw compose [font small]
append my-draw compose [line-width (default-line-width) pen blue]

no-sun: function ["检查此人有没有子代" username "姓名"] [
	user: select users username
	either user = none [true] [false]
]

middle: function ["计算中间的格子" grid "格子序号，从左往右数"] [
	remainder: grid % 2
	middle: grid / 2
	either remainder = 0 
		[middle] 
		[middle + 1]
]

calculate-x: function ["根据格子编号计算x左边" grid "x轴方向的格子编号"] [
	grid * gap - half-word-width + edge
]

calculate-y: function [
	"计算竖向格子的上边界坐标 上下两根竖线，字间距加字高，再加边距" 
	grid-y "距离上边界的格子数"
] [
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

draw-all: function [
	"绘制指定用户及其所有后代"
	username "姓名"
	grid-x "x格子序号"
	grid-y "y格子序号"
	height "函数递归调用次数"
] [
	tab: copy ""
	loop (grid-y - 1) * 3 [ append tab " " ]
	print [tab ">>" username "x:" grid-x "  y:" grid-y]
	user: select users username
	
	sun-grid-y: grid-y + 1
	first-grid: grid-x
	last-grid: grid-x
	append tab "  "
	i: 1
	foreach sun user/子 [
		vline-x: calculate-x grid-x
		print [tab "=" sun " x:" grid-x "  y:" grid-y "  first" first-grid "  last" last-grid ]
		either no-sun sun [
			y: calculate-y sun-grid-y
			append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-height)]
			temp-y: y + default-line-height + word-gap
			sun-x: vline-x - half-word-width
			foreach w sun [
				append my-draw reduce ['text as-pair sun-x temp-y (to string! w)]
				temp-y: temp-y + word-height + word-gap
			]
			last-grid: grid-x
			; 当前格子后移一格
			grid-x: grid-x + 1
			
		] [
			result: draw-all sun grid-x sun-grid-y sun-grid-y
			height: result/5 + 1
			grid-x: result/2
			if i = 1 [ 
				; 如果第一个子节点递归返回的，重置first grid为此父节点的格子
				first-grid: calculate-middle-grid first-grid grid-x
			]
			last-grid: result/4
		]
		; 间隔一格空白
		grid-x: grid-x + 1
		i: i + 1
	]
	; 去掉for循环里多加的最后一个空格
	grid-x: grid-x - 1
	tab: skip tab 2
	; 上短竖线
	father-grid: calculate-middle-grid first-grid last-grid
	vline-x: calculate-x father-grid
	y: calculate-y grid-y
	print [tab "<<" username "cur" grid-x "  first" first-grid "  last" last-grid "  middle" father-grid "  x" vline-x "  y" y]
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
	append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-height)]
	y: y + default-line-height
	; 横线
	hline-start: calculate-x first-grid
	hline-end: calculate-x last-grid
	append my-draw compose [line-cap flat line (as-pair hline-start y) (as-pair hline-end y)]
	grid-y: grid-y + 1
	return reduce [username grid-x grid-y father-grid height]
]

result: draw-all "马中新" 1 1 1

width: (gap * result/2) + (edge * 2)
height: (calculate-y result/5 + 1) + (edge * 2)
save %family-tree.png draw as-pair width height my-draw