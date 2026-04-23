# Timestamp Converter

一个可直接导入 Alfred 的 workflow，用关键字 `ts` 做时间和 Unix 时间戳双向转换。

## 导入

1. 打开 Alfred Workflow 编辑器。
2. 将 [timestamp-converter/info.plist](/Users/andrew/workspace/alfred/timestamp-converter/info.plist) 所在目录作为 workflow 导入，或直接导入 [output/timestamp-converter.alfredworkflow](/Users/andrew/workspace/alfred/output/timestamp-converter.alfredworkflow)。
3. 如果自行打包，压缩包根目录必须直接包含 `info.plist`、`convert.sh`、`README.md`，不能外面再包一层目录。
4. 确保 [timestamp-converter/convert.sh](/Users/andrew/workspace/alfred/timestamp-converter/convert.sh) 有可执行权限。

## 用法

- `ts`
  返回当前时间的毫秒时间戳。
- `ts 2026-04-23 18:00:00`
  返回格式化时间、秒级时间戳、毫秒级时间戳。
- `ts 1713849600`
  自动识别为秒级时间戳。
- `ts 1713849600000`
  自动识别为毫秒级时间戳，并返回秒级 datetime 和毫秒级 datetime。

## 规则

- 输入纯数字时，自动判断为时间戳。
- 时间戳绝对值大于等于 `1000000000000` 时，按毫秒处理，否则按秒处理。
- 毫秒时间戳输入时，会额外输出 `YYYY-MM-DD HH:MM:SS.SSS` 格式的毫秒级 datetime。
- 输入非纯数字时，按 `YYYY-MM-DD HH:MM:SS` 解析。
- 输入为空时，直接返回当前时间的毫秒时间戳。
