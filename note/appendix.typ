= 一些技巧
+ 用一次 double word load 代替 两次 single word load 并且少了一次 memfence acquire #image("unpack.png")

+ 编译时常量，当我们的结构体内部全是常量(包括函数指针)的时候允许返回值为 &'static 生命周期 #image("./vtable.png")