#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
= Introduction <intro>
大家好，今天我们来读 tokio 源码
// 异步运行时tokio，我们需要从以下几个点考虑他的设计
// 1. 多线程和任务派发
//    最朴素的想法是每个任务对应一个线程，但内存消耗和线程切换开销都太大，因此tokio使用了线程池和任务队列来优化性能
// 2. 惰性执行特性，tokio只有在await的时候才执行该async fn

= syscall 
有三个syscall非常用要
#table( 
  columns: 2,
  [syscall], [简述],
  [clone3],[用于创建线程，需要指定线程使用栈空间、指令启动地址等等],
  [futex_wait],[判断资源是否被占用，如若占用则休眠否则继续执行],
  [futex_wake],[唤醒由于该资源被占用而一直等待的线程],
)

= Task
+ 运行 tokio hello_world example
+ 观察tokio hello_world example 的执行流程
+ 观察tokio如何分配任务   
+ 观察tokio是如何实现惰性执行(即等到await的时候才执行)

= Flamegraph 
#figure(
  image("../flamegraph.svg",),
  caption:[运行命令 `cargo flamegraph --no-inline --example hello_world` 可得],
)
首先阅读 flamegraph 图了解大概的执行hello_world流程，可以观察到 整个程序的运行总时间被分割成了两个部分
+ hello_world
+ tokio-runtime-w
这是因为hello_world代表main线程，而tokio-runtime-w 则是独立出去的调度线程，在这个调度线程的基础上再创建线程池，因此可以发现tokio-runtime-w中clone3 的运行次数很多。

+ main函数首先调用了一次clone3生成独立的tokio-runtime调度线程
+ tokio-runtime-w调用多次clone3创建线程池
+ 为线程池分配任务

= Concepts 

== Tokio CurrentThread Runtime & MultiThread Runtime <rt_model>
存在两种Runtime 模型
#table( columns:2,
[Runtime],[简述],
[CurrentThread],
[单线程调度无并行，但好处是支持!Send任务，\ 也可以避免线程池创建的开销],
[MultiThread],
[多线程调度，支持多核CPU的并行性并抢占式调度]
)

// == Tokio LocalSet & LocalRuntime 
// 其中 LocalSet 是单线程调度，不会利用多核CPU的并行性
== Blocking Pool & Thread Pool



== Builder
\@_tokio/src/runtime/builder.rs_ \
Builder设计模式是为了应对当 new函数中存在大量选项的情况和解耦合的考虑
比如 A的创建必须通知 B ，那么最好引出一个Builder作为中间协调方操作B，而不是把B的引用直接传给
A的new函数。 同时由于tokio可以支持不同的调度模型(@rt_model)，我们也需要考虑Builder去静态分发不同的调度模型。

= Tokio Runtime Init

== Thread Pool Init 
+ 初始化首先会生成 cpu个数的线程(如果没有使用环境变量指定要运行的线程数量)。
而cpu个数则通过 sysconf 调用获取。

#image("./spawn_thread.png",width: 75%, fit:"contain")
在这里我们可以看







