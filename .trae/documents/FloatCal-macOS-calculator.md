# FloatCal 开发计划

## 项目概述

开发一个 macOS 悬浮计算器应用，支持一键全局呼出（默认 `Cmd+1`），支持自定义快捷键。

## 功能需求

### 1. 核心功能
- **全局快捷键呼出**: 使用全局热键呼出/隐藏计算器窗口
- **自定义快捷键**: 用户可在设置中自定义呼出快捷键
- **基础计算功能**: 支持加减乘除、括号、百分号等基础运算
- **悬浮窗口**: 计算器以浮动窗口形式显示，始终置顶

### 2. 用户交互
- **点击外部隐藏**: 点击窗口外部区域自动隐藏（可选）
- **按键响应**: 支持键盘输入数字和运算符
- **结果复制**: 支持一键复制计算结果

### 3. 系统集成
- **菜单栏图标**: 可选在菜单栏显示图标
- **设置面板**: 用于自定义快捷键和其他选项
- **启动项**: 支持开机自启动（可选）

## 技术方案

### 框架选择
- **UI Framework**: AppKit + SwiftUI（混合使用）
- **快捷键处理**: 使用 `HotKey` 库或 Carbon API
- **窗口管理**: NSWindow 浮动窗口

### 项目结构
```
FloatCal/
├── App/
│   ├── AppDelegate.swift
│   └── FloatCalApp.swift
├── Features/
│   ├── Calculator/
│   │   ├── CalculatorView.swift       # 计算器 UI
│   │   ├── CalculatorViewModel.swift # 计算逻辑
│   │   └── CalculatorEngine.swift     # 表达式解析
│   ├── Settings/
│   │   └── SettingsView.swift         # 设置面板
│   └── HotKey/
│       └── HotKeyManager.swift        # 全局快捷键管理
├── Models/
│   └── AppSettings.swift              # 设置模型
└── Resources/
    └── Assets.xcassets
```

## 实现步骤

### 阶段一：基础框架搭建
1. 配置项目结构，添加必要依赖
2. 创建浮动窗口，设置窗口属性（置顶、无标题栏、始终浮动）
3. 实现基本的计算器 UI 布局

### 阶段二：计算器核心功能
1. 实现 CalculatorEngine：表达式解析和计算
2. 实现 CalculatorViewModel：ViewModel 层
3. 实现 CalculatorView：UI 层
4. 添加键盘事件监听

### 阶段三：全局快捷键
1. 集成快捷键管理模块
2. 实现全局热键注册和响应
3. 实现快捷键自定义功能
4. 添加设置面板

### 阶段四：完善与优化
1. 添加菜单栏图标
2. 实现设置持久化（UserDefaults）
3. 优化窗口动画效果
4. 测试与 bug 修复

## 依赖库

- **HotKey** (SPM): https://github.com/soffes/HotKey - 用于全局快捷键处理

## 预期效果

- 应用启动后，计算器窗口默认隐藏
- 按下 `Cmd+1`（或自定义快捷键）呼出浮动窗口
- 再次按下快捷键或点击外部隐藏窗口
- 支持键盘直接输入进行计算
