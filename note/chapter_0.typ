#set page(width: 8.5in, height: 11in, margin: 0.5in)
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
#align(center, text(17pt)[
  *Tokio Async Runtime 
  *
])
#align(center, text(12pt)[
  *2025/3/4 v1.1
  *
])



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
这是因为hello_world代表main线程，而tokio-runtime-w 则是tokio rt线程池中的线程。可以发现tokio-runtime-w中clone3 的调用时间占100%，就是因为clone3是作为线程的最后一个栈帧。
#figure(
  image("./clone3_call_in_rt.png"),
  caption:[clone3作为线程的最后一个栈帧，因此在线程的整个生命周期都存在，并且负责调用exit syscall 通知操作系统回收线程]
)


+ main函数首先调用了一次clone3生成独立的tokio-runtime调度线程
+ tokio-runtime-w调用多次clone3创建线程池
+ 为线程池分配任务

= Concepts 

== Tokio CurrentThread Runtime & MultiThread Runtime <rt_model>
\@_tokio/src/runtime/scheduler/multi_thread/mod.rs_
\@_tokio/src/runtime/scheduler/current_thread/mod.rs_
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
为了初始化tokio，我们在helloworld 中可以看到在main函数上方加入了以下过程宏
#image("./#tokio_main.png",width: 55%)
按照注释的说法会在main函数中添加 runtime 的初始化函数

== Create First Thread 
使用gdb 打断点 clone3 可以捕获到第一次产生线程的过程
#image("./first_clone3.png")


== Thread Pool Init 
+ 初始化首先会生成 cpu个数的线程(如果没有使用环境变量指定要运行的线程数量)。
而cpu个数则通过 sysconf 调用获取。

#image("./spawn_thread.png",width: 75%, fit:"contain")
在这里我们可以看到，会去调用 `rt.inner.blocking_spawner().inner.run(id)`函数，它其实就是
在不断的从队列中拿取所需要执行的任务。
#figure(
image("./thread_run.png",width: 70%) ,caption: [线程不断地从queue中取任务并调用 `task.run`执行，由于task.run的过程中不再需要使用此队列，因此使用drop函数放弃了对queue的独占]
)







