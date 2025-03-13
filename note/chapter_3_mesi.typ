= MESI 
== 什么时候写入store buffer  
 什么时候直接写入cache line 

cacheline modified | exclusive  ->  cache line 
cacheline non-modified and non-exclusive -> store buffer 


== 什么时候mark invalidate queue entry 
smp_rmb  | smp_mb 

== 什么时候send invalidate 
如果一开始是shared 状态当我们尝试写入的时候会先写入 store buffer 
shared ---- send invalidate  &  invalidate AC  ----> exclusive   

==  那我在3的中途load 会发生什么
如果load 之前没有 smp_rmb 
直接优先从store buffer 中读取，不会等待变成 exclusive 
如果有 smp_rmb 
则等待所有invalidate AC  

== 什么时候cpu 不能立即send invalidate 
当cpu的 invalidate queue 已经存在该cacheline 的 entry 
那么说明其他cpu已经写入了该cacheline 且并未把最新副本送到当前cpu
这时候必须要等待 invalidate queue 中的该entry 到达才能send invalidate 


== 举例 cpu 0 w 然后 cpu 1  r 

cpu0 
+ send invalidate 
+ wait ac 也可以不等 ac，因为这里只是单次写入，不要求因果一致性

cpu1
+ invalid ac  -> 把 invalidate 放入 invalidate queue 
+ 取决于这个cacheline 之前是否在cpu1 中，如果已经有那么还是有可能读到旧值
 所以一定要加  smp_rmb ，在fetch 到 cacheline 之后再进行 read 
+ read successfully 

