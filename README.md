# ZenFocus 禅注

开源、无广告、完全本地的跨平台专注计时器。

Open-source, ad-free, fully offline cross-platform focus timer built with Flutter.

## 功能 Features

- **番茄钟** - 专注/休息循环，自动切换，可自定义时长
- **白噪音** - 内置棕噪音，支持音量调节
- **统计图表** - 最近 7 天专注时长柱状图，连续天数、总时长等数据
- **成就系统** - 7 枚徽章，记录你的专注里程碑
- **Material 3** - 支持动态取色、深色模式
- **中英双语** - 完整的中英文支持
- **完全本地** - 无需账号、无需云同步，数据安全存储在本地

## 下载 Download

前往 [Releases](https://github.com/wangzi5151/zenfocus/releases) 下载最新 APK。

## 构建 Build

前置条件：Flutter SDK >= 3.24

```bash
# 克隆仓库
git clone https://github.com/wangzi5151/zenfocus.git
cd zenfocus

# 生成原生平台文件（android/）
flutter create . --platforms=android --org com.zenfocusapp --project-name zenfocus

# 补丁 AndroidManifest（添加通知权限、设置应用名称）
bash tools/patch_manifest.sh

# 安装依赖
flutter pub get

# 运行
flutter run

# 构建 APK
flutter build apk --release
```

## 技术栈 Tech Stack

| 类别 | 技术 |
|------|------|
| UI 框架 | Flutter + Material 3 |
| 状态管理 | Provider |
| 音频播放 | just_audio |
| 本地通知 | flutter_local_notifications |
| 数据存储 | SharedPreferences (JSON) |
| 图表 | fl_chart |
| CI/CD | GitHub Actions |

## 为什么开源 Why Open Source

专注力是现代人最稀缺的资源。市面上的专注应用要么收费、要么收集数据、要么功能臃肿。ZenFocus 理念：

- **隐私第一** — 所有数据仅存储在你的设备上
- **无广告** — 永远不会加入任何广告
- **简单纯粹** — 只做专注计时这一件事
- **社区驱动** — 欢迎任何人贡献代码或提出建议

## 路线图 Roadmap

- [ ] iOS / macOS / Windows / Linux 平台支持
- [ ] 更多环境音效（雨声、森林、海浪）
- [ ] 主屏幕小组件
- [ ] Wear OS 手表端
- [ ] 数据导入/导出
- [ ] 深色主题动画优化

## 贡献 Contributing

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建一个 Pull Request

## 许可证 License

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE)。

---

如果对你有帮助，欢迎点个 Star!
