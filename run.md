## 安卓

```zsh
flutter emulators --launch Pixel_9_Pro_XL

export PATH="/Users/a11111/development/flutter/bin:$PATH"

flutter run -d emulator-5554 --hot
```

## ohos 构建步骤

1. 运行 `flutter doctor -v` 检查环境变量配置是否正确，**Futter**与**OpenHarmony**应都为ok标识，若两处提示缺少环境，按提示补上相应环境即可。

2. 创建工程

   ```
    # 创建工程
    flutter create --platforms ohos PiliPlusX
   ```

3. 编译hap包，编译产物在\<projectName\>/ohos/entry/build/default/outputs/default/entry-default-signed.hap下。

   ```
    # 进入工程根目录编译
    # 示例：flutter build hap [--target-platform ohos-arm64] --release
    flutter build hap --release
   ```

4. 安装应用，通过```flutter devices```指令发现真机设备之后，然后安装到OpenHarmony手机中。

   方式一：进入编译产物目录，然后安装到OpenHarmony手机中
   ```sh
   hdc -t <deviceId> install <hap file path>
   ```

   方式二：进入项目目录，直接运行安装到OpenHarmony手机中
   ```sh
   flutter run --debug -d <deviceId>
   ```

5. 构建app包命令：
   ```
    # 示例：flutter build app --release
    flutter build app --release
   ```
