# Hanzi Brush

Hanzi Brush 是一款规划中的 iPhone-only 原生 iOS App，面向美国 App Store，主题为汉字书法练习与中国文化。

当前阶段：原生 iOS App 已创建，正在做上架前验证。

## 预览效果图

直接在浏览器打开：

`/Users/xxq/Documents/XCodeWorkSpaces/customapp28/mockups/hanzi-brush-ux.html`

## 当前文档

- `docs/ux-design-cn.md`：中文版 UX 方案、用户路径、验收标准、截图假数据模式设计。
- `docs/progress.md`：阶段进度。
- `docs/handoff.md`：交接说明。
- `docs/user-guide.md`：使用文档。
- `docs/test-cases.md`：测试用例。
- `docs/app-store-connect-cn-en.md`：App Store Connect 中英文资料。
- `docs/release-checklist.md`：发版检查清单。

## iOS 工程

打开：

`/Users/xxq/Documents/XCodeWorkSpaces/customapp28/HanziBrush.xcodeproj`

构建：

`xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedData build`
