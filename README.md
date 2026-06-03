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
└── iMorph/                 # 关联 iMorph 插件目录（预留）
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

## 依赖

- **WOW 版本**：Retail（Interface 120005）
- **iMorph**：提供底层 `/run` 改模能力

---

## 许可

MIT License
