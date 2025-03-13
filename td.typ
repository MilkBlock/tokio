#set heading(numbering: "1.")
= struct 类
现在它应该集成 struct 类 
所谓struct 类就是带有字段的cpp class 
原先我们没有做struct的抽象，把fields下放到了具体的字段
这是不好的

`
class struct<dag f, string _fmt> {
  dag fields= f;
  string fmt = _fmt;
}
`
+ 让所有带字段的 def 都继承 struct 类
+ 让所有带字段的 class 都继承 struct 类
   variant member 肯定要继承 struct 
   enum value 首先 改名成 enum member ，不需要继承 struct 
  
= struct的 fmt字段
  无需让 enum member 带有 fmt 字段，因为我们可以直接用cpp自带的方法生成 

struct 需要有 fmt 字段到时候在backend可以由 tgfmt 生成最终的打印字符串


= 灵活使用 
+ `let xxx = xx in {


}`

+ 在Record之间插入第三者(比如AddOp 和 Op 之间插入一个BinaryOp )



