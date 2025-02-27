#define _GNU_SOURCE
#include <sys/syscall.h>
#include <stddef.h>
#include <stdatomic.h>
#include <linux/futex.h>
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <syscall.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#define STACK_SIZE (1024 * 1024) // 1MB 的栈空间
#define THREAD_MAX_COUNT 2

atomic_int finish_count= 0;
atomic_int start_count= 0;
atomic_int futex_0= 0;
atomic_int futex_main=0;
int futex_wait(atomic_int *futex, int expected){
    return syscall(SYS_futex, futex, FUTEX_WAIT, expected, NULL,NULL,0);
}
int futex_wake(atomic_int *futex, int num_threads){
    return syscall(SYS_futex, futex, FUTEX_WAKE, num_threads, NULL,NULL,0);
}
// 线程函数
void log_cpu(){
    int cpu = sched_getcpu();
    printf("Current thread is running on CPU %d\n", cpu);
}
void *thread_function(void* ch) {
    atomic_fetch_add(&start_count, 1);
    int i =0;
    printf("futex blocking\n");
    fflush(stdout);
    
    futex_wait(&futex_0,0);
    for(i=0;i<10;i++){
        printf("Thread processing %d\n",i);
    }
    printf("Thread is running with thread_count = %d of %s\n", atomic_load(&finish_count), (char*)ch);
    fflush(stdout);
    atomic_fetch_add(&finish_count, 1);
    while(!futex_wake(&futex_0, 1)&&
        !(atomic_load(&finish_count)==THREAD_MAX_COUNT && futex_wake(&futex_main, 1)));
    // while(!futex_wake(&futex_0, 1));
    
}

pthread_t p1,p2;
int main() {
    cpu_set_t mask;
    CPU_ZERO(&mask);      // 清空掩码
    CPU_SET(0x1, &mask);    // 绑定到 CPU 0
    log_cpu();
    
    void *stack = malloc(STACK_SIZE); // 为线程分配栈空间 
    // 使用 clone() 创建线程

    pthread_create(&p1, NULL, thread_function, (void *)"Hello world1");
        printf("pthread 1");
    fflush(stdout);
    pthread_create(&p2, NULL, thread_function, (void *)"Hello world1");
    printf("pthread 2");
    fflush(stdout);
    // while(atomic_load(&start_count)!=2); // wait all the threads to start 
    // waitid(P_ALL,pid0, NULL, 0);
    // waitid(P_ALL,pid1, NULL, 0);
    while(!futex_wake(&futex_0, 1)&&atomic_load(&finish_count)!=THREAD_MAX_COUNT);
    futex_wait(&futex_main, 0);
    // printf("thread pid is %d and %d\n", pid0, pid1);
    // waitpid(pid1, NULL, 0);
    fflush(stdout);
    printf("current pid is %d\n", getpid());
    printf("Thread has exited with thread_count = %d.\n",atomic_load(&finish_count));
    return 0;
}