# Handoff

## 当前目标

从空目录开始开发一款 iPhone-only 原生 iOS App，并准备 App Store 上架资料。用户选择的产品方向是“汉字书法 App”。中文版 UX 设计和 HTML/CSS 效果图已完成，用户已要求继续实现原生 iOS App。截图仍按用户要求放在最后。

## 产品约定

- App 英文名：Hanzi Brush
- App 中文名：墨韵汉字
- App 日文名：漢字ブラシ
- Bundle ID：com.zhouyajie.hanzibrush
- 版本号：1.0.0
- 设备：iPhone only
- 架构：本地 App，无账号、无后端、不主动发起网络请求
- 本地化：英语、简体中文、日语
- 语言选择：用户显式选择优先；未选择时按系统/地区推断；兜底英文
- 支持邮箱：jay212315@gmail.com

## 用户特别强调

- 任何功能都必须形成用户闭环：入口清楚、操作有效、状态保存、返回后有反馈。
- 实现前要写用户路径和验收标准；实现后要按真实路径验证。
- SwiftUI 中 `@Published` 字典/数组变更必须确保触发 UI 刷新。
- 截图专用假数据模式必须通过显式启动参数注入演示数据。
- 正式启动和 Release 版本必须不初始化、不显示、不持久化任何假数据。
- 假数据逻辑必须与生产逻辑隔离，并提供截图脚本和发版前校验。
- 先给 UX 设计和 HTML/CSS 效果图，确认后再生成截图。
- 浅色界面必须强制浅色模式，并给所有浅底文字、placeholder、禁用按钮文字设置足够深的显式颜色，避免深色模式审核设备出现白字问题。
- App 设置页不要显示 Bundle ID。

## 当前文件

- `HanziBrush.xcodeproj`：原生 SwiftUI iOS 工程。
- `HanziBrush/App/`：App 主代码。
- `HanziBrush/Resources/`：AppIcon、LaunchBackground、InfoPlist 本地化。
- `scripts/generate_app_icon.py`：确定性生成无 alpha App 图标。
- `scripts/capture_screenshots.sh`：Debug 截图数据启动脚本，截图放最后使用。
- `scripts/preflight_release_check.sh`：发版前校验脚本。
- `pages/`：GitHub Pages 静态隐私政策和支持页面。
- 线上 GitHub Pages：
  - `https://davidzyj.github.io/hanzibrush/`
  - `https://davidzyj.github.io/hanzibrush/privacy/`
  - `https://davidzyj.github.io/hanzibrush/support/`
- `docs/progress.md`：阶段进度。
- `docs/ux-design-cn.md`：中文版 UX 方案、路径和验收标准。
- `mockups/hanzi-brush-ux.html`：HTML/CSS UI 效果图。
- `docs/app-store-connect-cn-en.md`：App Store Connect 英文、简体中文、日文资料。
- `docs/user-guide.md`：使用文档。
- `docs/test-cases.md`：测试用例。
- `docs/release-checklist.md`：发版检查清单。
- `screenshots/iphone-17-pro-max/en/`：真实 iPhone 17 Pro Max 模拟器英文截图。
- `build/screenshot-previews/contact-sheet.jpg`：截图预览拼图。

## 下一位 agent 建议

继续时先运行发版前校验脚本。GitHub 仓库和 GitHub Pages 已完成，不需要重复创建。不要跳过数据闭环和测试闭环。

重要验证命令：

- `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedData build`
- `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -configuration Release -destination 'generic/platform=iOS' -derivedDataPath build/DerivedDataRelease build`
- `scripts/preflight_release_check.sh`

## 交付状态

- App 主功能已实现并验证。
- 1024x1024 RGB、无 alpha App 图标已生成。
- 真实模拟器截图已生成。
- GitHub 仓库已推送到 `main`。
- GitHub Pages 隐私政策和支持页面已部署。
- App Store 文案、使用文档、测试用例、发版清单都已落盘。
- 还需要用户在 Apple Developer / App Store Connect 后台手动完成 Bundle ID 注册、签名团队、创建 App 记录、定价、上传构建、填写审核信息并提交审核。
