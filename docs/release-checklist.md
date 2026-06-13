# 发版前检查清单

## 自动检查

- 运行 Debug 构建：
  `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedData build`
- 运行 Release 构建：
  `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -configuration Release -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedDataReleaseSim build`
- Apple Developer 团队配置完成后运行 Archive 或 generic iOS Release：
  `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -configuration Release -destination 'generic/platform=iOS' -derivedDataPath build/DerivedDataRelease build`
- 运行发版前校验：
  `scripts/preflight_release_check.sh`
- 确认 1024 图标没有 alpha：
  `python3 -c "from PIL import Image; im=Image.open('HanziBrush/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png'); print(im.mode, im.size)"`

## 手动检查

- 在 iPhone 模拟器中走完今日、练习、作品、字库、设置流程。
- 在系统深色模式下启动，确认 App 仍为浅色且文字可读。
- 检查隐私政策和支持页面是否已部署到 GitHub Pages。
- 在 Apple Developer 后台配置 Bundle ID 和签名能力。
- 在 App Store Connect 创建 App、填写价格、隐私、截图和审核信息。
- 上传 Archive 后检查 App Store Connect 的处理结果。
