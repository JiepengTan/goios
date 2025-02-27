# Go to iOS Integration Demo (.xcframework)

这个演示项目展示了如何将Go代码编译成.xcframework格式，以便与iOS应用程序集成。

## 项目结构

```
goios/
├── go/                          # Go源代码
│   ├── main.go                  # 主Go函数
│   ├── ios_adapter.go           # iOS适配器Go代码
│   ├── ios_adapter_complete.c   # iOS适配器C实现
│   ├── ios_adapter_complete.h   # iOS适配器C头文件
│   ├── goios_bridge.c           # C桥接实现
│   ├── goios_bridge.h           # C头文件
│   └── go.mod                   # Go模块文件
├── iosapp/                      # iOS演示应用程序
│   ├── GoIOSDemo/               # 演示应用源文件
│   └── GoIOSDemo.xcodeproj      # Xcode项目
├── build_xcframework.sh         # 构建.xcframework的脚本
└── README.md                    # 本文档
```

## 前提条件

- macOS（iOS开发必需）
- Xcode（建议14.0或更高版本）
- Go（1.17或更高版本）
- 基本的Go和iOS开发知识

## 工作原理

1. **Go代码**：`go/`目录中的Go代码提供了将暴露给iOS的简单函数。
2. **C桥接**：我们使用C桥接来连接Go和iOS，因为Go可以编译成C兼容的库。
3. **XCFramework**：`.xcframework`格式允许分发能在不同架构（模拟器和设备）上运行的二进制库。
4. **iOS适配器**：特殊的适配代码解决了Go在iOS上运行的特殊问题（信号处理、线程限制等）。

## 步骤详解

### 1. 编写Go代码

首先，我们创建想要暴露给iOS的Go函数。我们使用特殊的注释标记（`//export`）导出它们。

### 2. 创建C桥接

我们在`goios_bridge.c`中创建C包装函数，并在`goios_bridge.h`中提供iOS代码将使用的接口。

### 3. 实现iOS适配

使用专用的适配器文件解决Go在iOS上运行时的特殊问题：
- `ios_adapter.go`：处理Go运行时配置和信号
- `ios_adapter_complete.h/c`：提供必要的C函数实现

### 4. 构建XCFramework

`build_xcframework.sh`脚本执行以下步骤：
- 为不同架构（iOS设备arm64，模拟器x86_64和arm64）将Go代码编译为C归档
- 通过合并架构创建"fat"库
- 将库打包成`.framework`包
- 将框架合并为单个`.xcframework`

### 5. 在iOS中使用

iOS演示应用展示了如何：
- 链接到`.xcframework`
- 使用桥接头暴露C函数给Swift
- 创建Swift包装类来调用Go函数

## 构建和运行

1. 构建.xcframework：
```bash
chmod +x build_xcframework.sh
./build_xcframework.sh
```

2. 打开Xcode项目：
```bash
open iosapp/GoIOSDemo.xcodeproj
```

3. 在Xcode中构建和运行iOS应用。

## 演示应用功能

演示iOS应用展示：
- 两个数字的加法（使用Go的`Simple`函数）
- 使用"Say Hello"进行字符串处理（使用Go的`Hello`函数）
- 阶乘计算（使用Go的`CalculateFactorial`函数）

## 适配器说明

我们提供了三个文件，专门解决Go代码在iOS上运行的问题：

- `ios_adapter.go`：处理Go侧的信号和运行时配置
- `ios_adapter_complete.h`：声明C函数接口
- `ios_adapter_complete.c`：实现信号处理和iOS初始化功能

更多详细信息，请参阅`README-iOS-Adapter.md`。

## 故障排除

- **未找到框架**：确保在打开Xcode项目前运行了`build_xcframework.sh`。
- **构建错误**：确保您安装了正确版本的Xcode和Go。
- **代码签名问题**：您可能需要调整Xcode项目中的签名设置。

## 进一步改进

- 添加更复杂的Go函数以演示高级用例
- 在C桥接中添加适当的错误处理
- 为iOS应用添加自动化测试
- 创建用于打包多个Go库的模块系统