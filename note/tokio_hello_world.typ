// #set document(title: [tokio源码阅读])
= Introduction <intro>
异步运行时tokio，我们需要从以下几个点考虑他的设计
1. 多线程和任务派发
   最朴素的想法是每个任务对应一个线程，但内存消耗和线程切换开销都太大，因此tokio使用了线程池和任务队列来优化性能
2. 惰性执行特性，tokio只有在await的时候才执行该async fn


= Task
1. 观察tokio hello_world example 的执行流程
2. 观察tokio如何分配任务   
3. 观察tokio是如何实现惰性执行(即等到await的时候才执行)
    
== Task3

== Flamegraph 
  #image("../flamegraph.svg")



