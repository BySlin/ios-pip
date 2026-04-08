# iOS arm64 NumPy + OpenCV Python Build (GitHub Actions)

本仓库提供 GitHub Actions workflow，用于编译可在 iOS 真机 (`iphoneos arm64`) 使用的 `numpy` 与 `opencv-python`，并输出适配 `Python-Apple-support` 的 `app_packages` 目录结构。

## 1. 触发构建

Workflow 文件：

- `.github/workflows/build-ios-opencv-python.yml`

触发方式：

- 手动触发：GitHub Actions -> `build-ios-opencv-python` -> `Run workflow`
- 或 push 到 `main` 并修改该 workflow 文件

## 2. 产物说明

构建完成后会上传以下 artifacts：

- `ios-python-package-cp314-arm64-iphoneos.tar.gz`（推荐）
- `opencv-python-ios-cp314-arm64-iphoneos.whl`
- 其他中间产物（wheelhouse、numpy 安装目录）

推荐使用 `ios-python-package-cp314-arm64-iphoneos.tar.gz`，其中包含：

- `app_packages/numpy`
- `app_packages/cv2`

这与 `Python-Apple-support` 的 `install_python Python.xcframework app app_packages` 流程兼容。

## 3. 集成到 Xcode 工程

1. 解压 `ios-python-package-cp314-arm64-iphoneos.tar.gz`
2. 将其中的 `app_packages` 内容拷贝到你的 Xcode 项目 `app_packages/` 目录
3. 在 target 的 Build Phase 中调用 `Python.xcframework/build/build_utils.sh` 的 `install_python`

示例：

```bash
set -e
source "$PROJECT_DIR/Python.xcframework/build/build_utils.sh"
install_python Python.xcframework app app_packages
```

`build_utils.sh` 会在打包阶段自动处理 `app_packages` 下的 Python 扩展模块（`.so`）。

## 4. 本 workflow 的额外保护

workflow 已增加以下校验，避免“能编译但真机运行失败”的包：

- 校验 `numpy` 与 `cv2` 二进制均为 iOS arm64 Mach-O
- 校验 `numpy` 扩展后缀归一为 `iphoneos`
- 强制 `cv2` 至少存在 `.so`（因为 `build_utils.sh` 仅处理 `.so`）
- 校验 `cv2` 不依赖与 `build_utils.sh` 流程不兼容的 `opencv_*.libs` 动态库

