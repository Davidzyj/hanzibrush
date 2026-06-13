# 测试用例

## 构建与配置

- Debug 模拟器构建通过。
- Release 模拟器构建通过。
- generic iOS Release 构建当前受 Apple Developer Team 签名配置阻塞，需在 Xcode/Apple Developer 后台设置团队后再 archive。
- `CFBundleShortVersionString` 为 `1.0.0`。
- Bundle ID 为 `com.zhouyajie.hanzibrush`。
- `TARGETED_DEVICE_FAMILY` 为 `1`，只支持 iPhone。
- `UIUserInterfaceStyle` 为 `Light`。
- AppIcon 包含 1024x1024 PNG，且没有 alpha 通道。

## 已执行验证

- `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedData build` 通过。
- iPhone 17 模拟器安装并启动 `com.zhouyajie.hanzibrush` 成功。
- `xcodebuild -project HanziBrush.xcodeproj -scheme HanziBrush -configuration Release -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath build/DerivedDataReleaseSim build` 通过。
- `scripts/preflight_release_check.sh` 通过。

## 今日闭环

1. 启动 App，进入“今日”。
2. 点击“开始临摹”。
3. 在画布写至少一笔。
4. 点击“保存练习”。
5. 返回首页后确认：
   - 今日状态显示完成。
   - 已练汉字数量增加。
   - 最近练习列表出现该字。
6. 关闭并重启 App，状态仍保留。

## 练习闭环

1. 从“练习”进入任一汉字详情。
2. 查看部首、笔画、主题和笔顺提示。
3. 进入临摹页。
4. 验证无笔迹时保存按钮禁用且文字可读。
5. 写一笔后保存按钮可用。
6. 点击撤销、清空、格线、对照，确认状态变化有效。
7. 保存后返回，字库和首页状态刷新。

## 作品闭环

1. 进入“作品”。
2. 选择汉字和模板。
3. 输入署名。
4. 点击“保存作品”。
5. 确认出现保存反馈。
6. 确认作品列表出现新作品。
7. 点击分享，系统分享面板出现。
8. 删除作品后列表立即刷新。

## 字库闭环

1. 进入“字库”。
2. 输入拼音、英文含义或汉字进行搜索。
3. 切换主题筛选。
4. 收藏一个汉字。
5. 返回字库，确认收藏图标出现。
6. 切换“收藏”筛选，确认刚收藏的字存在。
7. 搜索无结果时，点击“显示全部汉字”恢复列表。

## 设置闭环

1. 进入“设置”。
2. 选择 English、简体中文、日本語。
3. 确认 App 文案立即切换。
4. 重启 App 后选择仍保留。
5. 点击隐私政策和支持页面，确认只在用户点击后打开网页。
6. 点击邮件支持，确认系统邮件入口打开。
7. 清除本地数据后，练习、收藏、作品清空。

## 截图假数据模式

1. 正常 Debug 启动不传参数，不出现演示收藏、演示作品或演示进度。
2. Debug 启动传入 `--screenshot-demo-data`，显示稳定演示数据。
3. 截图模式不写入生产本地存储。
4. Release 构建中截图参数无效。
5. `scripts/preflight_release_check.sh` 通过。

## 可读性

- 在 iOS 深色模式设备上启动 App，界面仍保持浅色。
- 浅色背景上的主文字、说明文字、placeholder 和禁用按钮文字均可读。
- 按钮文字不溢出容器。
