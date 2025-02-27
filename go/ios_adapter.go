//go:build darwin && (arm64 || amd64) && cgo && ios

/*
iOS适配器 - 用于解决Go在iOS上运行的各种问题

包含的主要功能：
1. 信号处理 - 防止Go运行时的信号处理导致应用崩溃
2. 线程管理 - 配置合适的线程策略避免线程耗尽
3. 内存管理 - 设置GC参数优化内存使用
4. 初始化顺序 - 确保在Go运行时启动前执行必要的C代码

使用方法：
1. 将此文件及其关联的ios_adapter_complete.h和ios_adapter_complete.c复制到你的Go项目中
2. 确保编译时包含iOS构建标签
3. 在你的应用程序初始化时导入此包

作者: Codeium
日期: 2025-02-27
*/

package main

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework UIKit
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include "ios_adapter_complete.h" // 包含完整的iOS适配函数
*/
import "C"

import (
	"os"
	"os/signal"
	"runtime"
	"runtime/debug"
	"syscall"
)

// init函数，在Go运行时启动时自动执行
func init() {
	// 配置Go运行时
	configureGoRuntime()
	
	// 禁用Go的信号处理
	disableGoSignals()
	
	// 调用C函数禁用C层面的信号
	C.disableIOSSignals()
	
	// 重定向标准错误输出到/dev/null
	redirectStderrToNull()
}

// 配置Go运行时以优化在iOS上的运行
func configureGoRuntime() {
	// 设置垃圾回收更激进地运行，防止内存问题
	debug.SetGCPercent(10)
	
	// 不设置最大线程数，让Go自行管理
	// 但限制用于执行Go代码的OS线程数量
	runtime.GOMAXPROCS(2)
}

// 禁用所有Go的信号处理
func disableGoSignals() {
	// 忽略所有关键信号，防止Go设置信号处理器
	signal.Ignore(
		syscall.SIGBUS,
		syscall.SIGPIPE,
		syscall.SIGSEGV,
		syscall.SIGABRT,
		syscall.SIGILL,
		syscall.SIGFPE,
		syscall.SIGTRAP,
	)
}

// 重定向标准错误输出到/dev/null
func redirectStderrToNull() {
	// 打开/dev/null用于写入
	f, err := os.OpenFile("/dev/null", os.O_WRONLY, 0)
	if err == nil {
		// 重定向stderr
		syscall.Dup2(int(f.Fd()), int(os.Stderr.Fd()))
		// 同时重定向stdout
		syscall.Dup2(int(f.Fd()), int(os.Stdout.Fd()))
	}
}
