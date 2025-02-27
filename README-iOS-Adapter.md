# iOS适配器 - Go程序在iOS平台运行的解决方案

此文档提供关于如何使用`ios_adapter.go`文件在iOS平台上运行Go应用程序的指南。

## 背景

Go语言原生并不完全适配iOS平台，主要面临以下挑战：

1. **信号处理冲突** - Go的信号处理机制与iOS不兼容
2. **线程限制** - iOS对线程数量有严格限制，但Go运行时可能创建大量线程
3. **内存管理** - iOS对内存使用有严格要求
4. **启动顺序** - 需要在Go运行时初始化前执行特定的iOS配置

## 解决方案

`ios_adapter.go`文件及其关联的C文件解决了上述问题，提供了一个全面的适配层，允许Go程序在iOS上稳定运行。

## 使用方法

### 1. 将适配器添加到项目中

将以下文件复制到您的Go项目源代码目录中：

- `ios_adapter.go` - Go适配器主文件
- `ios_adapter_complete.h` - C适配函数声明
- `ios_adapter_complete.c` - C适配函数实现

### 2. 确保正确的构建标签

添加适当的构建标签到您的Go源代码文件:

```go
//go:build darwin && (arm64 || amd64) && cgo && ios
```

### 3. 在XCode项目中设置

在您的XCode项目中，确保:

1. 正确链接了必要的框架 (Foundation, UIKit)
2. 启用了Objective-C编译支持
3. 在构建设置中启用了CGO
4. 添加所有C文件到Xcode项目中

### 4. 构建过程

使用如下命令构建您的Go代码为iOS Framework:

```bash
#!/bin/bash
GOARCH=arm64 \
CGO_ENABLED=1 \
GOOS=ios \
go build -buildmode=c-archive -tags="ios" \
         -o libYourApp.a ./path/to/your/package
```

## 工作原理

适配器文件实现了以下关键功能:

1. **信号处理**
   - 在C级别禁用关键信号
   - 在Go级别忽略同样的信号
   - 提供必要的信号处理函数存根

2. **线程管理**
   - 配置更大的线程栈大小
   - 允许Go自行管理线程数量
   - 限制GOMAXPROCS保持资源使用合理

3. **内存配置**
   - 设置更激进的GC行为
   - 重定向stderr/stdout到/dev/null

4. **初始化顺序**
   - 使用C的`constructor`属性确保在Go运行时初始化前执行iOS初始化

## 文件说明

适配器由三个主要文件组成：

1. **ios_adapter.go**：
   - 包含Go侧的信号处理和运行时配置
   - 在init()函数中设置Go运行时参数
   - 提供stderr重定向功能

2. **ios_adapter_complete.h**：
   - 声明所有必要的C适配函数
   - 包含信号处理和线程配置函数

3. **ios_adapter_complete.c**：
   - 实现C侧的初始化和启动代码
   - 包含构造函数确保在Go运行时前执行
   - 提供C桥接函数模板

## 限制

即使使用了适配器，仍有一些限制需要注意:

1. 避免大量使用goroutines，它们可能导致线程耗尽
2. 避免使用依赖Unix信号的Go库
3. 某些网络操作可能在iOS上受限
4. 性能可能不如在其他平台上理想

## 故障排除

如果您遇到问题:

1. **应用崩溃**: 检查信号处理配置是否正确
2. **线程耗尽**: 尝试减少goroutines的使用
3. **内存问题**: 调整GC百分比和内存使用模式
4. **构建失败**: 确保所有构建标签和CGO设置正确

## 支持和贡献

如有问题或改进建议，请联系开发者。如果您改进了适配器，请考虑分享您的修改以帮助社区。
