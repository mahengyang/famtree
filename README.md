# famtree
生成家庭树
### 使用方法
家谱数据存在`data.txt`中，格式为：字 名 后代，空格分隔，示例如下

```
中 马中新 马端吉 马端祥 马端如 马端意 马端少
端 马端如 马泰心 马泰德 马泰功 马泰名 
瑞 马端少 马泰明 马泰光 马泰亮 
泰 马泰光 马守运 马守伦 马守礼 
泰 马泰亮 马守清 
守 马守运 马文德 马文才
守 马守礼 马文孝 马文义 马文鸿 马超 马越 
文 马文义 马瑞德 
瑞 马瑞德
```

安装red之后，直接执行即可
```
$ red famtree.red data.txt
```

执行后会在当前目录下产生一个图片，名字叫做`family-tree.png`，如下图
![家族树](https://github.com/mahengyang/famtree/raw/master/family-tree.png)
