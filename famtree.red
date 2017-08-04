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
word-heigth: 24 ;20号字体，大小约为24px
half-word-width: word-width / 2
default-line-heigth: 10
default-line-width: 2
small: make font! [size: 20 name: "Consolas" style: 'bold]
base-x: width / 2
base-y: 10

node1: object [
	father: "马中新"
	suns: ["马端吉" "马端祥" "马端如" "马端意" "马端少"]
	generation: "中"
]

node2: object [
	father: "马端如"
	suns: ["马泰心" "马泰德" "马泰功" "马泰名"]
	generation: "端"
]

node3: object [
	father: "马端少"
	suns: ["马泰明" "马泰光" "马泰亮"]
	generation: "端"
]

node4: object [
	father: "马泰光"
	suns: ["马守运" "马守伦" "马守礼"]
	generation: "泰"
]

node5: object [
	father: "马泰亮"
	suns: ["马守清"]
	generation: "泰"
]

node6: object [
	father: "马守运"
	suns: ["马文德" "马文才"]
	generation: "守"
]

node7: object [
	father: "马守礼"
	suns: ["马文孝" "马文义" "马文鸿" "马 超" "马 越"]
	generation: "守"
]

nodes: reduce [node1 node2 node3 node4 node5 node6 node7]

; 名字作为主键，方便查找
users: make map! []
; 画板
my-draw: make block! 1
node-grid: make map! []

foreach node nodes [
	put users node/father node
]

append my-draw compose [font small]
append my-draw compose [line-width (default-line-width) pen blue]

no-sun: function [user-name] [
	user: select users user-name
	either user = none [true] [false]
]

; 计算中间的格子
middle: function [grid] [
	remainder: grid % 2
	middle: grid / 2
	either remainder = 0 
		[middle] 
		[middle + 1]
]

calculate-x: function [grid] [
	grid * gap - half-word-width + edge
]

; 两个字的名字中间加一个空格
format-name: function [name] [
	number: length? name
	either number = 2 
		[ rejoin [first name " " second name] ]
		[ name ]
]

draw-all: function [user-name grid y tab] [
	append tab " "
	append tab " "
	print [tab "函数开始" user-name "grid:" grid "y:" y]
	user: select users user-name
	
	sun-y: y
	foreach w user-name [
		sun-y: sun-y + word-heigth + word-gap
	]
	sun-y: sun-y + (default-line-heigth * 2) + word-gap

	first-grid: grid
	last-grid: grid
	i: 1
	foreach sun user/suns [
		append tab " "
		append tab " "
		vline-x: calculate-x grid
		print [tab "foreach" sun " cur" grid  "  first" first-grid "  last" last-grid]
		either no-sun sun [
			append my-draw compose [line-cap flat line (as-pair vline-x sun-y) (as-pair vline-x sun-y + default-line-heigth)]
			temp-y: sun-y + default-line-heigth + word-gap
			sun-x: vline-x - half-word-width
			foreach w sun [
				append my-draw reduce ['text as-pair sun-x temp-y (to string! w)]
				temp-y: temp-y + word-heigth + word-gap
			]			
			; 当前格子后移一格
			grid: grid + 1
			last-grid: grid
		] [
			result: draw-all sun grid sun-y tab
			grid: result/2
			if i = 1 [ 
				; 如果第一个子节点递归返回的，重置first grid为此父节点的格子
				first-grid: first-grid + ((grid - 1 - first-grid) / 2)
			]

			tab: result/4
			last-grid: result/5
		]
		; 间隔一格空白
		grid: grid + 1
		tab: skip tab 2
		i: i + 1
	]
	; 去掉for循环里多加的最后一个空格
	grid: grid - 1
	
	; 上短竖线
	father-grid: (first-grid + ((last-grid - first-grid) / 2))
	vline-x: calculate-x father-grid
	print [tab "函数结束" user-name "cur" grid "  first" first-grid "  last" last-grid "  middle" father-grid "  x" vline-x]
	if y > 10 [
		append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-heigth)]
	]
	y: y + default-line-heigth + word-gap
	; 名字
	x: vline-x - half-word-width
	foreach w user-name [
		append my-draw reduce ['text as-pair x y (to string! w)]
		y: y + word-heigth + word-gap
	]
	; 下短竖线
	append my-draw compose [line-cap flat line (as-pair vline-x y) (as-pair vline-x y + default-line-heigth)]
	y: y + default-line-heigth
	; 横线
	hline-start: calculate-x first-grid
	hline-end: calculate-x last-grid
	append my-draw compose [line-cap flat line (as-pair hline-start y) (as-pair hline-end y)]
	tab: skip tab 2
	return reduce [none grid y tab father-grid]
]

draw-all "马中新" 1 10 ""
width: (gap * select node-grid "马中新") + (edge * 2)
save %family-tree.png draw as-pair width height my-draw