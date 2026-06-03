# iMorphTools

**魔兽世界改模辅助工具**

iMorphTools 是基于 [iMorph](https://www.imorph.dev/download) 的快捷改模工具，提供可视化面板一键切换角色模型、坐骑、附魔、种族、套装等外观。

---

## 目录结构

```
iMorphTools/
├── iMorphTools.toc         # 插件定义 (v1.0.3, Interface 120005)
├── icon.tga                # 小地图按钮图标
├── data.lua                # 数据模块说明
├── ui.lua                  # 主界面（2313行，暗色主题UI组件+功能面板）
│
├── data/
│   ├── core.lua            # IMT 命名空间 + BuildIDTable 辅助函数
│   ├── commands.lua        # 便捷改模指令集（~40条预设）
│   ├── sets.lua            # 职业套装数据（9职业 T1-T10）
│   ├── models.lua          # 角色模型（32个）+ 宠物模型（13个）
│   ├── mounts.lua          # 坐骑数据（经典+地心+巨龙+角斗士 ~410个）
│   ├── races.lua           # 种族数据（44个种族选项）
│   ├── shapeshifts.lua     # 变形形态（10种）+ 形态模型（43个）
│   ├── enchants.lua        # 武器附魔（经典60/CTM/MoP/军团+ ~83个）
│   ├── spells.lua          # 技能效果（近战AOE/BUFF/弹道/远程AOE/其他 ~127个）
│   └── playkit.lua         # 视觉套件（8个）+ 12个装备栏位
│
├── iMorph.lua              # 聊天指令封装层（. 开头快捷命令）
│
└── iMorph/                 # iMorph 核心二进制文件
    ├── RuniMorph.exe        # DLL 注入器
    └── iMorph.dll           # 改模核心 DLL
```

---

## 安装

1. 确保 [iMorph](https://www.imorph.dev/download) 已正确安装
2. 将 `iMorphTools` 文件夹复制到 `Interface/AddOns/` 目录
3. 重启游戏或 `/reload`

---

## 使用

- **小地图按钮**：左键点击打开/关闭主面板，右键拖动按钮位置
- **斜杠命令**：输入 `/imt` 打开主面板
- **主面板**：360x550 暗色主题窗口，包含以下功能区：

| 功能区 | 说明 |
|--------|------|
| 🔄 重置初始模型 | 一键恢复默认外观 |
| ⚡ 便捷指令集 | ~40条预设改模指令（双炎黄、风剑、蛋刀等） |
| 🎽 套装 | 9职业标签页，T1-T10 套装选择 |
| 👤 角色模型 | 32个预设模型（瓦王、女王、伊利丹等） |
| 🐾 宠物模型 | 13个预设宠物模型（幽灵虎、幽灵狼等） |
| 🐴 坐骑 | 4标签页 ~410个坐骑（经典/地心/巨龙/角斗士） |
| 🏷️ 种族 | 44个种族选项 + 变性切换 |
| 🦁 变形形态 | 10种形态 + 43个形态模型（猫/熊/枭兽/旅行等） |
| 📐 缩放 | 模型/宠物缩放滑块 |
| 🎒 装备 | 12个装备栏位单独修改 |
| ✨ 附魔 | 5版本分组 ~83个附魔，支持主副手切换 |
| 💥 技能效果 | 5分组 ~127个技能特效（神圣风暴、混乱之箭等） |
| 🎨 视觉套件 | 8个视觉套件（四圣兽、棱彩装饰等） |

---

## 数据模块说明

### `data/core.lua`
- `IMT` — 全局命名空间
- `BuildIDTable(defs)` — 从 `{name, id}` 列表自动生成查找表和排序列表

### `data/commands.lua`
- `IMT.CmdSets` / `IMT.CmdOrder` — 预设指令集，每条指令包含一条或多条 `/run` 代码

### `data/models.lua`
- `IMT.ModelIDs` — 角色模型映射（32个预设）
- `IMT.PetIDs` — 宠物模型映射（13个预设）

### `data/mounts.lua`
- `IMT.MountGroups` — 按经典/地心之战/巨龙时代/角斗士分组
- 每组包含坐骑名称和对应的 SpellID / MountID

### `data/races.lua`
- `IMT.RaceOptions` — 种族ID映射（含龙希尔两种形态、土灵等新种族）

### `data/shapeshifts.lua`
- `IMT.ShapeshiftIDs` — 形态ID映射
- `IMT.ShapeshiftModelIDs` — 形态模型ID映射

### `data/enchants.lua`
- `IMT.EnchantGroups` — 按版本分组，每组 `{name, ItemVisualID}`

### `data/spells.lua`
- `IMT.SpellGroups` — 按类型分组，每条 `{name, SpellVisualKitID}`

### `data/playkit.lua`
- `IMT.SlotIDs` — 12个装备栏位ID
- `IMT.PlayKitDefs` — 视觉套件定义，包含静态和动态特效配置

### `data/sets.lua`
- `IMT.SetGroups` — 按9职业分组，每组包含 T1-T10 的 `{name, SetID}`

---

## 添加新数据

以添加新坐骑为例：

1. 找到 `data/mounts.lua` 中对应的分组数组（如 `TWWMountDefs`）
2. 添加条目：`{ "坐骑名称", 显示ID, 坐骑ID }`
3. `/reload` 即可在主面板中看到

其他模块同理，数据与 UI 自动关联。

---

## iMorph.lua — 聊天命令封装层

`iMorph.lua` 通过 `hooksecurefunc("ChatEdit_ParseText", ...)` 拦截聊天输入框，将以 `.` 开头的消息解析为 iMorph 指令。

### 命令列表

| 命令 | 参数 | 功能 |
|------|------|------|
| `.morph` | `<display id>` | 修改玩家模型 |
| `.morphpet` | `<display id>` | 修改宠物模型 |
| `.npc` | `<id/name>` | 修改为 NPC 模型 |
| `.race` | `<1-77> <form 0-1>` | 修改种族 |
| `.gender` | — | 切换性别 |
| `.scale` | `<0.5-3.0>` | 缩放玩家模型 |
| `.scalepet` | `<scale>` | 缩放宠物模型 |
| `.item` | `<1-19> <item id> <version> <secondary>` | 修改装备栏位 |
| `.itemset` | `<itemset id> <version>` | 修改套装 |
| `.transmog` | `<transmog id> <version>` | 修改幻化 |
| `.outfit` | `<outfit id> <version>` | 加载配装方案 |
| `.mount` | `<display id> <1/2>` | 修改坐骑 (1=地面,2=飞行) |
| `.enchant` | `<1-2> <enchant id>` | 修改附魔 (1=主手,2=副手) |
| `.shapeshift` | `<form id> <display id>` | 修改变形形态模型 |
| `.spell` | `<spell id> <spell id>` | 修改技能视觉 |
| `.spellvisual` | `<visual id> <visual id>` | 修改技能视觉效果 |
| `.spellvisualkit` | `<kit id> <kit id>` | 修改技能视觉套件 |
| `.spellvisualkitmodelattach` | `<kit model id> <kit model id>` | 修改技能套件模型附件 |
| `.spellmissile` | `<missile id> <missile id>` | 修改技能弹道 |
| `.visualeffect` | `<effect id> <effect id>` | 修改视觉效果 |
| `.playeffect` | `<effect id> <positioner id>` | 播放特效 |
| `.playkit` | `<effect id> <option id>` | 播放视觉套件 |
| `.playpeteffectkit` | `<effect id> <option id>` | 播放宠物特效套件 |
| `.loadingscreen` | `<loading screen id>` | 修改加载画面 |
| `.light` | `<light id>` | 修改光照 |
| `.screeneffect` | `<screen effect id>` | 修改屏幕特效 |
| `.weather` | `<weatherId> <0.0-1.0>` | 修改天气 |
| `.time` | `<hours> <minutes>` | 修改时间 |
| `.title` | `<0-128>` | 修改称号 |
| `.customtitle` | `<title text> <0-1>` | 自定义称号文本 |
| `.medal` | `<0-8>` | 修改勋章 |
| `.class` | `<class id>` | 修改职业模型 |
| `.customization` | `<name> <id>` | 修改角色自定义选项 |
| `.setcustomization` | `<name> <id>` | 设置角色自定义选项 |
| `.itemswap` | `<item id> <item id>` | 物品模型互换 |
| `.mog` | `<name>` | 加载幻化方案 |
| `.mogs` | — | 列出所有幻化方案 |
| `.mogreload` | — | 重载幻化方案 |
| `.reset` | — | 重置所有修改 |
| `.disablesm` / `.enablesm` | — | 禁用/启用运动模糊 |
| `.helmshow` | — | 切换头盔显示 |
| `.exp` | — | 导出当前配置 |
| `.log` | — | 日志控制 |
| `.console` | — | 控制台设置 |
| `.dir` / `.site` / `.discord` | — | 打开目录/官网/Discord |
| `.health` / `.debug` | — | 健康检查/调试模式 |
| `.help` | — | 显示帮助 |

### 架构

```lua
ChatEdit_ParseText (WoW)
    └─→ iMorphChatHandler(msg)  -- 解析 .command args
            └─→ iMorphMiddleware(command, ...)  -- 转发到 DLL
                    └─→ IMorphInfo.call = _G["CloseTrade"]  -- 通过 WoW API 调用
```

> 通过 `string.char(67,108,111,115,101,84,114,97,100,101)` 即 `CloseTrade` 作为 DLL 通信入口。

---

## iMorph 分析

通过分析 `iMorph/` 目录下的两个文件：

### `RuniMorph.exe` — DLL 注入器

**核心行为**（基于导入函数分析）：

| 导入函数 | 用途 |
|----------|------|
| `CreateToolhelp32Snapshot` / `Process32First` / `Process32Next` | 枚举进程，查找 WoW 进程 |
| `OpenProcess` | 打开 WoW 进程句柄 |
| `VirtualAllocEx` | 在 WoW 地址空间分配内存 |
| `WriteProcessMemory` | 写入 DLL 路径到 WoW 内存 |
| `LoadLibraryExA` | 在 WoW 进程中加载 iMorph.dll |
| `CreateRemoteThread` | 创建远程线程执行 DLL 加载 |
| `IsDebuggerPresent` | 反调试检测 |

**运行日志字符串**：
- `[INFO] LoadLibrary Address: %p`
- `[INFO] Remote image already loaded %p`
- `[ERROR] Could not load remote image locally`
- `[ERROR] Failed to allocate remote memory`

**注入流程**：查找 WoW 进程 → 打开进程 → 分配远程内存 → 写入 DLL 路径 → 创建远程线程 → 通过 `LoadLibraryExA` 加载 DLL。

---

### `iMorph.dll` — 改模核心 DLL

**关键导入函数分析**：

| 类别 | 函数 | 用途 |
|------|------|------|
| **Hook/注入** | `VirtualProtect`, `FlushInstructionCache` | 内存保护修改 + 指令缓存刷新 |
| **线程操控** | `CreateThread`, `SuspendThread`, `ResumeThread`, `GetThreadContext`, `SetThreadContext` | 线程创建/挂起/恢复/上下文修改 |
| **进程/模块** | `GetProcAddress`, `GetModuleHandleA`, `FreeLibrary` | 动态函数查找和卸载 |
| **文件操作** | `CreateDirectoryW`, `CreateFileW`, `ReadFile`, `WriteFile`, `FindFirstFileW` | 配置保存/加载 (morphs 文件夹) |
| **UI** | `CreateWindowExA`, `RegisterClassExA`, `DefWindowProcA`, `MessageBoxA` | Windows 原生窗口创建 |
| **网络** | `ShellExecuteA`, `ShellExecuteW` | 打开浏览器（官网/Discord） |
| **版本** | `GetFileVersionInfoA`, `VerQueryValueA` | WoW 版本校验 |

**Hook 框架**：包含 **MinHook** 库特征字符串：
- `MH_Error_*` 系列常量（`MH_ERROR_ALREADY_CREATED`, `MH_ERROR_ENABLED`, `MH_ERROR_MEMORY_PROTECT` 等）
- 表明通过 MinHook 对 WoW API 进行 Inline Hook

**已验证的 WoW API Hook 目标**：
- `ChatEdit_ParseText` — 聊天输入解析函数

**内部指令路由**（DLL 接收并处理的全部命令）：

```
morph, morphpet, race, gender, scale, scalepet,
item, itemset, transmog, outfit, mount,
enchant, class, shapeshift,
spell, spellvisual, spellmissile, visualeffect,
spellvisualkit, spellvisualkitmodelattach,
customization, setcustomization, flag,
loadingscreen, light, screeneffect,
title, medal, customtitle,
playeffect, playeffectkit, playpeteffectkit,
itemswap, weather, time,
debug, health, site, unload, discord, console, logging,
dir, exp, reset, helmshow,
mog, mogs, mogreload
```

**运行时日志**：
- `(info) initializing imorph`
- `(info) initialize setup hook`
- `(error) active player not found!`
- `(warning) active player not cleaned up!`
- `(error) reached max customizations index`
- 详细的参数类型校验错误消息

**版本控制**：
- 字符串 `Web requests disabled in %s version, try iMorphNet` 表明存在功能限制版本

**配置文件目录**：在 WoW 目录下创建 `morphs` 文件夹，存储配装方案（`.mog` 文件）。

---

## 架构总览

```
┌─────────────────────────────────────────────┐
│                    WoW 客户端                 │
│  ┌──────────┐  ┌──────────────────────────┐ │
│  │ iMorphTools│  │     iMorph (C++)        │ │
│  │  (Lua)    │  │                          │ │
│  │           │  │  RuniMorph.exe           │ │
│  │ UI面板    │  │  ├→ DLL注入               │ │
│  │ 数据模块  │  │  └→ iMorph.dll            │ │
│  │           │  │      ├→ MinHook 框架      │ │
│  │ /imt 面板 │  │      ├→ WoW API Hook      │ │
│  │           │  │      └→ 渲染管线修改      │ │
│  └──────────┘  └──────────────────────────┘ │
│         │                    ▲               │
│         │   .command 聊天    │               │
│         └──────────────────→│               │
│              通过 iMorph.lua 转发            │
└─────────────────────────────────────────────┘
```

---

## 依赖

- **WOW 版本**：Retail（Interface 120005）
- **iMorph**：提供底层改模能力（通过 DLL 注入 + MinHook Inline Hook 修改 WoW 渲染管线）
- **运行库**：Visual C++ 2015+ Redistributable (VCRUNTIME140.dll, MSVCP140.dll)

---

## 许可

MIT License
