#ifndef IOS_ADAPTER_COMPLETE_H
#define IOS_ADAPTER_COMPLETE_H

/*
 * iOS适配器头文件 - 用于Go在iOS上的C函数桥接和初始化
 *
 * 此文件包含在iOS上运行Go代码所需的所有C级适配代码
 * 包括信号处理、线程配置和iOS初始化
 *
 * 作者: Codeium
 * 日期: 2025-02-27
 */

#include <signal.h>
#include <pthread.h>
#include <stdlib.h>

// 信号处理函数 - 忽略可能导致Go程序崩溃的信号
static inline void disableIOSSignals(void) {
    signal(SIGPIPE, SIG_IGN);
    signal(SIGBUS, SIG_IGN);
    signal(SIGSEGV, SIG_IGN);
    signal(SIGABRT, SIG_IGN);
    signal(SIGILL, SIG_IGN);
    signal(SIGFPE, SIG_IGN);
    signal(SIGTRAP, SIG_IGN);
}

// 声明我们在C文件中实现的函数
int sigaltstack(const stack_t *ss, stack_t *oss);
int pthread_sigmask(int how, const sigset_t *set, sigset_t *oset);
int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);
int sigprocmask(int how, const sigset_t *set, sigset_t *oldset);

// 设置iOS线程属性 - 增加线程栈大小
static inline void setupIOSThreads(void) {
    pthread_attr_t attr;
    if (pthread_attr_init(&attr) == 0) {
        // 设置较大的栈大小(16MB)，防止栈溢出
        pthread_attr_setstacksize(&attr, 16 * 1024 * 1024);
        pthread_attr_destroy(&attr);
    }
}

// 初始化iOS环境 - 在启动时自动执行
static inline void initializeIOSEnvironment(void) {
    disableIOSSignals();
    setupIOSThreads();
}

#endif /* IOS_ADAPTER_COMPLETE_H */
