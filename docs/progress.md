# 项目进度

项目名称：Hanzi Brush  
中文显示名：墨韵汉字  
日文显示名：漢字ブラシ  
Bundle ID：com.zhouyajie.hanzibrush  
版本：1.0.0  
目标设备：iPhone only  
当前阶段：Phase 1 - 原生 iOS App 实现与上架资料准备

## Phase 0 - UX 设计与效果图

状态：已完成，用户已确认继续实现

已完成：

- 初始化 git 仓库。
- 创建 `docs/` 与 `mockups/` 目录。
- 明确产品方向：汉字书法练习、每日一字、文化解释、作品生成。
- 确定 App 命名、多语言显示名和 Bundle ID。
- 写出主要用户路径、验收标准、状态保存要求和截图假数据模式原则。
- 生成中文版 UX 设计文档。
- 生成 HTML/CSS 静态 UI 效果图。
- 完成静态检查：HTML/CSS 原型不包含外部 URL、远程图片、远程字体或 `@import`。
- 完成可读性检查：原型声明浅色 `color-scheme`，并使用显式深色文字、禁用文字颜色和浅色背景变量。

确认结果：

- 是否认可整体视觉方向：浅宣纸底、墨色主文字、朱砂强调色、青绿色辅助色。
- 是否认可信息架构：今日、练习、作品、字库、设置。
- 是否认可付费产品定位：免费体验少量汉字，完整字库与高级模板付费解锁。

下一阶段计划：

- 创建原生 iOS SwiftUI 工程。
- 配置 iPhone only、版本号 1.0.0、Bundle ID、多语言 Display Name。
- 建立本地数据、用户设置、收藏、练习记录、作品记录的数据模型。
- 实现首页、练习、作品、字库、设置的完整闭环。
- 加入显式语言选择、系统/地区推断和英文兜底。
- 建立 DEBUG-only 截图假数据模式与发版前校验脚本。

## Phase 1 - 原生 iOS App 与资料准备

状态：实现完成，等待 GitHub/Apple 后台手动事项和最终截图

已完成：

- 创建 `HanziBrush.xcodeproj` 原生 SwiftUI 工程。
- 配置 iPhone-only、版本号 `1.0.0`、Bundle ID `com.zhouyajie.hanzibrush`。
- 配置 `CFBundleDisplayName` 英语、简体中文、日语本地化。
- 配置 `UIUserInterfaceStyle` 为 `Light`，App 根视图强制浅色。
- 实现本地 `AppStore` 状态层，收藏、练习、作品、语言选择都通过 store 方法更新并保存。
- 实现首页、练习、汉字详情、临摹画布、作品生成、字库、设置页面闭环。
- 设置页不展示 Bundle ID。
- 加入 `--screenshot-demo-data` DEBUG-only 截图假数据模式。
- 截图假数据不写入生产存储。
- 提供 `scripts/capture_screenshots.sh` 与 `scripts/preflight_release_check.sh`。
- 生成 1024x1024 RGB App 图标和 AppIcon 资源集。
- 准备 GitHub Pages 静态页面：隐私政策和支持页面，含英语、简体中文、日语。
- 准备 App Store Connect 中英文资料、使用文档、测试用例和发版清单。
- Debug 模拟器构建已通过。
- Release 模拟器构建已通过。
- App 已安装并启动到 iPhone 17 模拟器。
- `scripts/preflight_release_check.sh` 已通过。

待验证：

- 真机或模拟器手动走查。
- 用户确认是否现在创建 GitHub 远程仓库并部署 Pages。
- Apple Developer 团队签名配置完成后，运行 generic iOS Release/archive。
- 最后阶段生成 App Store 截图。已生成英语 iPhone 17 Pro Max 截图，路径为 `screenshots/iphone-17-pro-max/en/`，contact sheet 为 `build/screenshot-previews/contact-sheet.jpg`。
