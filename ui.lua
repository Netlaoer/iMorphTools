function InitUI()
    -- 主界面
    local iMorphToolsMainFrame = CreateFrame("Frame", "iMorphToolsMainFrame", UIParent, "BasicFrameTemplate")
    iMorphToolsMainFrame:SetWidth(360)
    iMorphToolsMainFrame:SetHeight(575)
    iMorphToolsMainFrame.TitleText:SetText("|cff40C7EBiMorphTools")
    iMorphToolsMainFrame:SetMovable(true)
    iMorphToolsMainFrame:SetClampedToScreen(true)

    -- 设置框架的鼠标事件，使其可以拖动
    iMorphToolsMainFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    iMorphToolsMainFrame:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)

iMorphToolsMainFrame:SetPropagateKeyboardInput(true)

-- 设置OnKeyDown脚本
iMorphToolsMainFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        self:Hide() -- 如果按下了ESC键，隐藏框架
    end
end)

    -- 设置框架层级
    iMorphToolsMainFrame:SetFrameStrata("LOW")

    -- 设置框架的位置，使其出现在小地图的右下角
    iMorphToolsMainFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -20)

    -- 显示框架
    iMorphToolsMainFrame:Hide()


-- 创建小地图按钮
    iMorphToolsMiniMapButton = CreateiMorphToolsMiniMapButton(iMorphToolsMainFrame)


    -- 重置所有
    local button = CreateFrame("Button", "Frame", iMorphToolsMainFrame, "UIPanelButtonTemplate");
    button:SetSize(330, 25)
    button:SetPoint("TOP", iMorphToolsMainFrame, "TOP", 0, -28);
    button:SetText("重置初始模型");
    button:Show()
    button:SetScript("OnClick", function()
        ResetIds();
    end);
    preWidget = button


-- 便捷改模
local bjzlCommandSets = {
  ["主手风剑"] = function() SetItem(16, 19019) end,
  ["副手风剑"] = function() SetItem(17, 19019) end,
  ["主手堕落灰烬"] = function() SetItem(16, 22691) end,
  ["副手堕落灰烬"] = function() SetItem(17, 22691) end,
  ["晴空万里"] = function() SetWeather(0, 0) end, 
  ["蛋盾"] = function() SetItem(17, 32375) end,
  ["橙弓"] = function() SetItem(18, 34334) end,
  ["主手霜之哀伤"] = function() SetItem(16, 33350) end,
  ["副手霜之哀伤"] = function() SetItem(17, 33350) end,
  ["主手瓦王筷子"] = function() SetItem(16, 45899) end,
  ["副手瓦王筷子"] = function() SetItem(17, 45899) end,
  ["主手血吼"] = function() SetItem(16, 30414) end,
  ["副手血吼"] = function() SetItem(17, 30414) end,
  ["主手灰烬使者"] = function() SetItem(16, 50442) end,
  ["副手灰烬使者"] = function() SetItem(17, 50442) end,
  ["双风剑"] = function() SetItem(16, 19019); SetItem(17, 19019) end,
  ["双哀伤"] = function() SetItem(16, 33350); SetItem(17, 33350) end,
  ["双灰烬"] = function() SetItem(16, 50442); SetItem(17, 50442) end,
  ["双瓦王筷子"] = function() SetItem(16, 45899); SetItem(17, 45899) end,
  ["红色战刃"] = function() SetItem(16, 18583); SetItem(17, 18584) end,
  ["双蛋刀"] = function() SetItemSet(699) end,
  ["双堕灰"] = function() SetItem(16, 22691); SetItem(17, 22691) end,
  ["板甲大元帅"] = function() SetItemSet(384) end,
  ["板甲督军"] = function() SetItemSet(383) end,
  ["骑士绿伪T2"] = function() SetItemSet(784) end,
  ["法师督军"] = function() SetItemSet(387) end,
  ["炎魔的珠宝"] = function() SetItem(1, 95474) end,
  ["永冬之冠"] = function() SetItem(1, 95475) end,
  ["骑士紫伪T2"] = function()
  SetItem(1, 27790);
  SetItem(3, 27539);
  SetItem(5, 27897);
  SetItem(10, 27457);
  SetItem(6, 27548);
  SetItem(7, 27748);
  SetItem(8, 28221);
  SetItem(9, 27489);
end,
  ["骑士264T10"] = function()
  SetItem(1, 51167);
  SetItem(3, 51166);
  SetItem(5, 51165);
  SetItem(10, 51169);
  SetItem(7, 51168);
  SetItem(6, 50010);
end,
  ["战士277T10"] = function()
  SetItem(1, 51227);
  SetItem(3, 51229);
  SetItem(5, 51225);
  SetItem(10, 51226);
  SetItem(7, 51228);
end,
  ["观星清除DPS地板技能"] = function()
  SetSpell(49938,48982);
  SetSpell(49067,48982);
  SetSpell(48819,48982);
  SetSpell(42926,48982);
  SetSpell(42925,48982);
  SetSpell(425777,48982);
end,
  ["主手影之哀伤"] = function() SetItem(16, 51303) end,
  ["副手影之哀伤"] = function() SetItem(17, 51303) end,
  ["双影之哀伤"] = function() SetItem(16, 51303); SetItem(17, 51303) end,
  ["主手米锤"] = function() SetItem(16, 22805) end,
  ["主手灾变之刃"] = function() SetItem(16, 32373) end,
  ["主手辛洛斯"] = function() SetItem(16, 19921) end,
  ["主手绝世"] = function() SetItem(16, 19323) end,
  ["主手龙之召唤"] = function() SetItem(16, 10847) end,
  ["主手沙赫拉姆黑剑"] = function() SetItem(16, 12590) end,
  ["骑士黄金挑战套"] = function()
  SetItem(1, 90100);
  SetItem(3, 90102);
  SetItem(5, 90098);
  SetItem(6, 90096);
  SetItem(7, 90101);
  SetItem(8, 90097);
  SetItem(9, 90103);
  SetItem(10, 90099);
end,
}


--命令顺序
local cmdOrder = {
    "主手风剑", "副手风剑", "主手堕落灰烬", "副手堕落灰烬", 
    "晴空万里", "蛋盾", "橙弓", "主手霜之哀伤", "副手霜之哀伤",
    "主手瓦王筷子", "副手瓦王筷子", "主手血吼", "副手血吼",
    "主手灰烬使者", "副手灰烬使者", "双风剑", "双哀伤", 
    "双灰烬", "双瓦王筷子", "红色战刃", "双蛋刀", "双堕灰",
    "板甲大元帅", "板甲督军", "骑士绿伪T2", "法师督军",
    "炎魔的珠宝", "永冬之冠", "骑士紫伪T2", "骑士264T10", 
    "战士277T10", "观星清除DPS地板技能",
    "主手影之哀伤", "副手影之哀伤", "双影之哀伤", "主手米锤", 
    "主手灾变之刃", "主手辛洛斯", "主手绝世", "主手龙之召唤", 
    "主手沙赫拉姆黑剑", "骑士黄金挑战套"
}


-- 创建主按钮（与重置按钮同尺寸）
local cmdBtn = CreateFrame("Button", "CmdBtn", iMorphToolsMainFrame, "UIPanelButtonTemplate")
cmdBtn:SetSize(330, 25)
cmdBtn:SetPoint("TOP", preWidget, "BOTTOM", 0, -5)  -- 紧接在重置按钮下方
cmdBtn:SetText("便捷改模指令集")
cmdBtn:Show()

-- 创建下拉菜单框架
local cmdMenu = CreateFrame("Frame", "CmdMenu", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
cmdMenu:Hide()

-- 初始化菜单
UIDropDownMenu_Initialize(cmdMenu, function(self)
    local info = UIDropDownMenu_CreateInfo()
    -- 按 cmdOrder 顺序遍历
    for _, cmdName in ipairs(cmdOrder) do
        if bjzlCommandSets[cmdName] then  -- 检查命令是否存在
            info.text = cmdName
            info.func = function() 
                bjzlCommandSets[cmdName]()  -- 执行对应函数
            end
            UIDropDownMenu_AddButton(info)
        end
    end
end)

-- 按钮交互
cmdBtn:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, cmdMenu, self, 0, 0)
end)

-- 悬停提示
cmdBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击选择需要执行的改模指令", 1, 1, 1)
    GameTooltip:AddLine("选中后立即生效", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)

cmdBtn:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

preWidget = cmdBtn 

-- 定义映射表
local setMapping = {
  ZST1 = 209,
  ZST2 = 218,
  ZST3 = 523,
  ZST4 = 654,
  ZST5 = 657,
  ZST6 = 672,
  ZSS1 = 765,
  ZST7 = 787,
  ZST8 = 830,
  ZSLMT9 = 869,
  ZSBLT9 = 807,
  ZST10 = 896,
  QST1 = 208,
  QST2 = 217,
  QST3 = 528,
  QST4 = 625,
  QST5 = 627,
  QST6 = 679,
  QSS1 = 766,
  QST7 = 790,
  QST8 = 822,
  QSLMT9 = 875,
  QSBLT9 = 880,
  QST10 = 899,
  LRT1 = 206,
  LRT2 = 215,
  LRT3 = 530,
  LRT4 = 651,
  LRT5 = 652,
  LRT6 = 669,
  LRS1 = 772,
  LRT7 = 794,
  LRT8 = 838,
  LRLMT9 = 859,
  LRBLT9 = 860,
  LRT10 = 891,
  DZT1 = 204,
  DZT2 = 213,
  DZT3 = 524,
  DZT4 = 621,
  DZT5 = 622,
  DZT6 = 668,
  DZS1 = 776,
  DZT7 = 801,
  DZT8 = 826,
  DZLMT9 = 857,
  DZBLT9 = 858,
  DZT10 = 890,
  MST1 = 202,
  MST2 = 211,
  MST3 = 525,
  MST4 = 664,
  MST5 = 666,
  MST6 = 674,
  MSS1 = 777,
  MST7 = 805,
  MST8 = 833,
  MSLMT9 = 849,
  MSBLT9 = 850,
  MST10 = 885,
  SMT1 = 207,
  SMT2 = 216,
  SMT3 = 527,
  SMT4 = 632,
  SMT5 = 635,
  SMT6 = 684,
  SMT7 = 796,
  SMT8 = 825,
  SMLMT9 = 861,
  SMBLT9 = 862,
  SMT10 = 893,
  SMS1 = 771,
  FST1 = 201,
  FST2 = 210,
  FST3 = 526,
  FST4 = 648,
  FST5 = 649,
  FST6 = 671,
  FSS1 = 779,
  FST7 = 803,
  FST8 = 836,
  FSLMT9 = 843,
  FSBLT9 = 844,
  FST10 = 883,
  SST1 = 203,
  SST2 = 212,
  SST3 = 529,
  SST4 = 645,
  SST5 = 646,
  SST6 = 670,
  SSS1 = 780,
  SST7 = 802,
  SST8 = 837,
  SSLMT9 = 846,
  SSBLT9 = 845,
  SST10 = 884,
  XDT1 = 205,
  XDT2 = 214,
  XDT3 = 521,
  XDT4 = 639,
  XDT5 = 643,
  XDT6 = 677,
  XDS1 = 773,
  XDT7 = 800,
  XDT8 = 827,
  XDLMT9 = 855,
  XDBLT9 = 856,
  XDT10 = 887,
}
-- 保存上次输入的文本
iMorphToolsDBC = iMorphToolsDBC or {}
-- 确保iMorphToolsDBC是一个表
if type(iMorphToolsDBC) ~= "table" then
    iMorphToolsDBC = {} -- 创建一个新的空表
end
local savedText = iMorphToolsDBC.EditBox2Text or ""

-- 编辑框2
local editBox2 = CreateFrame("EditBox", "editBox2", iMorphToolsMainFrame, "BJ_InputBoxTemplate");
editBox2:SetSize(165, 30);
editBox2:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 10, -3);
editBox2:SetText(savedText); -- 从保存的文本恢复
editBox2:Show();



-- 设置当按下Esc键时失去焦点
if editBox2:IsAutoFocus() then
    editBox2:SetAutoFocus(false)
end

-- 修改套装按钮
local buttonSetChange = CreateFrame("Button", "buttonSetChange", iMorphToolsMainFrame, "UIPanelButtonTemplate");
buttonSetChange:SetSize(125, 30);
buttonSetChange:SetPoint("LEFT", editBox2, "RIGHT", 30, 0);
buttonSetChange:SetText("修改套装");
buttonSetChange:Show();

-- 添加按钮的鼠标悬停提示
buttonSetChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:AddLine("编辑框直接输入DKT3、QST6，PVP系列仅采集了S1，T9系列分BL/LM（例“QSLMT9”）。也可自行查询编号手动输入", 1, 1, 1);
    GameTooltip:Show();
end);

buttonSetChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

buttonSetChange:SetScript("OnClick", function()
    local inputText = editBox2:GetText(); -- 获取文本框中的文本

    -- 首先检查inputText是否为数字
    local setId;
    if tonumber(inputText) then
        setId = tonumber(inputText); -- 如果是数字，直接转换为数字类型
    else
        setId = setMapping[inputText:upper()]; -- 否则，查找映射表
    end

    if setId then
        SetItemSet(setId); -- 如果找到映射或输入的是数字，执行修改套装函数
    else

    end

    -- 保存当前的输入文本
    iMorphToolsDBC.EditBox2Text = inputText;
end);

preWidget = editBox2

-- 定义模型ID与名称的映射表，仅保留数字ID
local modelIDs = {
  ["不死海盗"] = 3494,
  ["暴风城卫兵男"] = 3167,
  ["暴风城卫兵女"] = 5446,
  ["白色瓦格里"] = 26101,
  ["黑色瓦格里"] = 25517,
  ["希尔瓦娜斯（新版）"] = 28213,
  ["希尔瓦娜斯（经典）"] = 11657,
  ["泰兰德"] = 7274,
  ["罗宁"] = 16024,
  ["吉安娜（经典）"] = 2970,
  ["吉安娜（新版）"] = 30865,
  ["范克里夫"] = 2029,
  ["怀特迈恩"] = 2043,
  ["铁矮人"] = 26212,
  ["祖格老虎BOSS"] = 15214,
  ["麻风侏儒"] = 6922,
  ["伊利丹"] = 27571,
  ["奈法人形态"] = 9472,
  ["瓦里安"] = 28127,
  ["机械侏儒（小）"] = 28282,
  ["机械侏儒（大）"] = 28112,
  ["小小机械侏儒"] = 26341,
  ["SS恶魔形态"] = 25277,
  ["诺格弗格药剂"] = 7550,
  ["巫妖王"] = 24191,
  ["红龙女王"] = 28227,
  ["鲜血女王"] = 31093,
  ["血月狼人"] = 26787,
  ["烈焰舞娘"] = 23732,
  ["食人魔"] = 17273,
  ["兜帽黑暗游戏"] = 30686,
  ["护肩黑暗游戏"] = 30687,
  ["火猫"] = 131379,
  ["凯尔萨斯"] = 20063,
  ["瓦丝琪女士"] = 20748,
  ["阿克蒙德"] = 17886,
  ["基尔加丹"] = 25350,
  ["萨尔"] = 27275,
  ["加尔鲁什"] = 28195,
  ["阿尔萨斯（人类）"] = 29958,
  ["小地狱咆哮"] = 30399,
  ["大工匠梅卡托克"] = 28130,
}


local modelOrder = {
    "不死海盗", "暴风城卫兵男", "暴风城卫兵女", "白色瓦格里", "黑色瓦格里",
    "希尔瓦娜斯（新版）", "希尔瓦娜斯（经典）", "泰兰德", "罗宁", 
    "吉安娜（经典）", "吉安娜（新版）", "范克里夫", "怀特迈恩", "铁矮人",
    "祖格老虎BOSS", "麻风侏儒", "伊利丹", "奈法人形态", "瓦里安",
    "机械侏儒（小）", "机械侏儒（大）", "小小机械侏儒", "SS恶魔形态",
    "诺格弗格药剂", "巫妖王", "红龙女王", "鲜血女王", "血月狼人",
    "烈焰舞娘", "食人魔", "兜帽黑暗游戏", "护肩黑暗游戏", "火猫",
    "凯尔萨斯", "瓦丝琪女士", "阿克蒙德", "基尔加丹", "萨尔",
    "加尔鲁什", "阿尔萨斯（人类）", "小地狱咆哮", "大工匠梅卡托克"
}

iMorphToolsDBC = iMorphToolsDBC or {}

-- 创建模型选择按钮
local selectModelBtn = CreateFrame("Button", "SelectModelBtn", iMorphToolsMainFrame, "UIPanelButtonTemplate")
selectModelBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -17 , -3)
selectModelBtn:SetSize(121, 30)
selectModelBtn:SetText("点击角色改模")

-- 悬停提示
selectModelBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击选择模型直接生效", 1, 1, 1)
    GameTooltip:Show()
end)

-- 创建下拉菜单框架
local menuFrame = CreateFrame("Frame", "ModelSelectMenu", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
menuFrame:Hide()

-- 安全变形函数
local function SafeMorph(id)
    if type(id) == "number" then
        Morph(id)
    else

    end
end

-- 菜单点击处理
local function OnMenuSelect(button)
    SafeMorph(button.value)
end

-- 初始化菜单
UIDropDownMenu_Initialize(menuFrame, function(self)
    local info = UIDropDownMenu_CreateInfo()
    
    -- 按 modelOrder 顺序遍历
    for _, name in ipairs(modelOrder) do
        local id = modelIDs[name]
        if id then
            -- 验证ID类型
            if type(id) ~= "number" then

            end
            
            info.text = name
            info.value = id
            info.func = OnMenuSelect
            info.arg1 = id
            UIDropDownMenu_AddButton(info)
        end
    end
end)


-- 绑定按钮点击显示菜单
selectModelBtn:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, menuFrame, self, 0, 0)
end)

-- 文本框8
local editBox8 = CreateFrame("EditBox", "editBox8", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
editBox8:SetSize(85, 30)
editBox8:SetPoint("LEFT", selectModelBtn, "RIGHT", 8, 0)
editBox8:SetText(iMorphToolsDBC.ModelID or "7550")
editBox8:SetAutoFocus(false)

editBox8:SetScript("OnTextChanged", function(self)
    iMorphToolsDBC.ModelID = self:GetText()
end)

-- 改模型按钮
local buttonModelChange = CreateFrame("Button", "buttonModelChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonModelChange:SetSize(121, 30)
buttonModelChange:SetPoint("LEFT", editBox8, "RIGHT", 1, 0)
buttonModelChange:SetText("手动角色改模")

-- 悬停提示
buttonModelChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("输入模型ID后点击修改", 1, 1, 1)
    GameTooltip:Show()
end)

buttonModelChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- 新的点击逻辑（仅使用编辑框内容）
buttonModelChange:SetScript("OnClick", function()
    local inputID = tonumber(editBox8:GetText())
    if inputID then
        Morph(inputID)
    else

    end
end)

preWidget = selectModelBtn  

-- 定义宠物ID与名称的映射表
local petmodelIDs = {
    ["幽灵虎"] = 21974,
    ["幽灵狼"] = 21114,
    ["吉安娜"] = 30865,
    ["巫妖王"] = 24191,
    ["瓦王"] = 28127,
    ["伊利丹"] = 27571,
    ["祖格老虎BOSS"] = 15214,
    ["大脚"] = 31094,
    ["逐日"] = 29673,
    ["洛卡纳哈"] = 28010,
    ["小洛卡纳哈"] = 28649,
    ["古德利亚"] = 28871,
    ["小古德利亚"] = 28873,
    ["血月狼人"] = 26787,
    ["烈焰舞娘"] = 23732,
	["诺格弗格药剂"] = 7550,
	["火猫"] = 131379,
	["萨尔"] = 27275,
	["加尔鲁什"] = 28195,
	["凯尔萨斯"] = 20063,
	["阿尔萨斯（人类）"] = 29958,
}

local petmodelOrder = {
    "幽灵虎","幽灵狼","吉安娜","巫妖王","瓦王","伊利丹","祖格老虎BOSS","大脚","逐日","洛卡纳哈","小洛卡纳哈","古德利亚","小古德利亚","血月狼人","烈焰舞娘","诺格弗格药剂","火猫","萨尔","加尔鲁什","凯尔萨斯","阿尔萨斯（人类）"
}

iMorphToolsDBC = iMorphToolsDBC or {}

-- 创建宠物选择按钮
local selectPetBtn = CreateFrame("Button", "SelectPetBtn", iMorphToolsMainFrame, "UIPanelButtonTemplate")
selectPetBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
selectPetBtn:SetSize(121, 30)
selectPetBtn:SetText("点击宠物改模")

-- 悬停提示
selectPetBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击选择宠物模型直接生效", 1, 1, 1)
    GameTooltip:Show()
end)

-- 创建宠物菜单框架
local petMenuFrame = CreateFrame("Frame", "PetSelectMenu", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
petMenuFrame:Hide()

-- 安全宠物变形函数
local function SafeMorphPet(id)
    if type(id) == "number" then
        MorphPet(id)
    else

    end
end

-- 修正后的宠物菜单点击处理
local function OnPetMenuSelect(button)
    SafeMorphPet(button.value)
end


-- 初始化菜单
UIDropDownMenu_Initialize(petMenuFrame, function(self)
    local info = UIDropDownMenu_CreateInfo()
    
    -- 按 petmodelOrder 顺序遍历
    for _, name in ipairs(petmodelOrder) do
        local id = petmodelIDs[name]
        if id then
            -- 验证ID类型
            if type(id) ~= "number" then
                print("|cFFFF0000宠物配置错误：["..name.."]的ID不是数字|r")
            end
            
            info.text = name
            info.value = id
            info.func = OnPetMenuSelect
            info.arg1 = id
            UIDropDownMenu_AddButton(info)
        end
    end
end)

-- 绑定宠物按钮点击
selectPetBtn:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, petMenuFrame, self, 0, 0)
end)

-- 宠物ID输入框
local editBox9 = CreateFrame("EditBox", "editBox9", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
editBox9:SetSize(85, 30)
editBox9:SetPoint("LEFT", selectPetBtn, "RIGHT", 8, 0)
editBox9:SetText(iMorphToolsDBC.PetModelID or "21974")
editBox9:SetAutoFocus(false)

editBox9:SetScript("OnTextChanged", function(self)
    iMorphToolsDBC.PetModelID = self:GetText()
end)

-- 手动改宠物按钮
local buttonPetChange = CreateFrame("Button", "buttonPetChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonPetChange:SetSize(121, 30)
buttonPetChange:SetPoint("LEFT", editBox9, "RIGHT", 1, 0)
buttonPetChange:SetText("手动宠物改模")

-- 悬停提示
buttonPetChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("输入宠物模型ID后点击修改", 1, 1, 1)
    GameTooltip:Show()
end)

buttonPetChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- 新的点击逻辑
buttonPetChange:SetScript("OnClick", function()
    local inputID = tonumber(editBox9:GetText())
    if inputID then
        MorphPet(inputID)
    else

    end
end)

preWidget = selectPetBtn  -- 为后续元素提供定位参考


-- 定义坐骑ID与名称的映射表，只保留数字ID
local mountIDs = {
  ["幽灵狮鹫"] = 26691,
  ["魔法公鸡"] = 29344,
  ["爱心火箭"] = 30989,
  ["黑龙妹"] = 30346,
  ["冰龙"] = 31154,
  ["飞机头"] = 28890,
  ["蓝火箭"] = 23656,
  ["红火箭"] = 23647,
  ["蓝飞毯"] = 28063,
  ["红飞毯"] = 28060,
  ["紫飞毯"] = 28061,
  ["飞升化气"] = 28065,
  ["迷失始祖龙"] = 28045,
  ["红始祖龙"] = 28044,
  ["紫始祖龙"] = 28043,
  ["白始祖龙"] = 28042,
  ["蓝始祖龙"] = 28041,
  ["黑始祖龙"] = 28040,
  ["绿始祖龙"] = 28053,
  ["蓝色幼龙"] = 28046,
  ["碧蓝幼龙"] = 28080,
  ["角斗士虚空龙"] = 27507,
  ["骸骨狮鹫"] = 28108,
  ["直升机"] = 22720,
  ["阿曼尼战熊"] = 22464,
  ["午夜"] = 19250,
  ["黑甲虫"] = 15676,
  ["幽灵虎"] = 21974,
  ["乌鸦"] = 21473,
  ["星骓"] = 31958,
  ["摩托"] = 25870,
  ["海龟"] = 17158,
  ["暴雪巨熊"] = 27567,
  ["无头"] = 25159,
  ["无敌"] = 31007,
  ["ZG龙"] = 15289,
  ["ZG老虎"] = 15290,
  ["凤凰"] = 17890,
  ["DK马"] = 10718,
  ["大螺丝"] = 23872,
  ["海象人风筝"] = 106974,
  ["梦魇翡翠龙"] = 113466,
  ["腐溃翡翠龙"] = 110171,
  ["S8龙"] = 31047,
  ["S7龙"] = 29794,
  ["S6龙"] = 25593,
  ["S5龙"] = 25511,
  ["生肖坐骑兔"] = 109216,
  ["大螺丝坐骑"] = 114286,
  ["金色凤凰"] = 121416,
  ["祥云火鹰"] = 126079,
  ["BL飞艇"] = 129771,
  ["LM飞船"] = 129769,
  ["碧海浮舟"] = 131619,
  ["染煞幼龙"] = 131986,
  ["大天使战马"] = 39530,
  ["新幽灵狮鹫"] = 39546,
  ["幽灵双足飞龙"] = 39547,
  ["黑曜石之翼"] = 42498,
  ["琥珀石蜥蜴"] = 30259,
  ["碧蓝石脊龙"] = 29988,
  ["夜翼缚地者"] = 39603,
  ["红色幼龙"] = 28047,
  ["时光迷失元龙"] = 31268,
  ["虚空鳐"] = 23240,
  ["远古角蛙"] = 43906,
  ["犀牛"] = 29260,
  ["黑色猛犸象"] = 28761,
  ["红色魁麟"] = 46620,
  ["炉石天马"] = 45254,
  ["灵翼幼龙"] = 21333,
}

local mountOrder = {
    "幽灵狮鹫",
    "魔法公鸡",
    "爱心火箭",
    "黑龙妹",
    "冰龙",
    "飞机头",
    "蓝火箭",
    "红火箭",
    "蓝飞毯",
    "红飞毯",
    "紫飞毯",
    "飞升化气",
    "迷失始祖龙",
    "红始祖龙",
    "紫始祖龙",
    "白始祖龙",
    "蓝始祖龙",
    "黑始祖龙",
    "绿始祖龙",
    "蓝色幼龙",
    "碧蓝幼龙",
    "角斗士虚空龙",
    "骸骨狮鹫",
    "直升机",
    "阿曼尼战熊",
    "午夜",
    "黑甲虫",
    "幽灵虎",
    "乌鸦",
    "星骓",
    "摩托",
    "海龟",
    "暴雪巨熊",
    "无头",
    "无敌",
    "ZG龙",
    "ZG老虎",
    "凤凰",
    "DK马",
    "大螺丝",
    "海象人风筝",
    "梦魇翡翠龙",
    "腐溃翡翠龙",
    "S5龙",
    "S6龙",
    "S7龙",
    "S8龙",
    "生肖坐骑兔",
    "大螺丝坐骑",
    "金色凤凰",
    "祥云火鹰",
    "BL飞艇",
    "LM飞船",
    "碧海浮舟",
    "染煞幼龙",
    "大天使战马",
    "新幽灵狮鹫",
    "幽灵双足飞龙",
    "黑曜石之翼",
    "琥珀石蜥蜴",
    "碧蓝石脊龙",
    "夜翼缚地者",
    "红色幼龙",
    "时光迷失元龙",
    "虚空鳐",
    "远古角蛙",
    "犀牛",
    "黑色猛犸象",
    "红色魁麟",
    "炉石天马",
    "灵翼幼龙"
}

iMorphToolsDBC = iMorphToolsDBC or {}

-- 创建坐骑选择按钮
local selectMountBtn = CreateFrame("Button", "SelectMountBtn", iMorphToolsMainFrame, "UIPanelButtonTemplate")
selectMountBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
selectMountBtn:SetSize(121, 30)
selectMountBtn:SetText("点击坐骑改模")

-- 悬停提示
selectMountBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击选择坐骑模型直接生效", 1, 1, 1)
    GameTooltip:Show()
end)

-- 创建坐骑菜单框架
local mountMenuFrame = CreateFrame("Frame", "MountSelectMenu", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
mountMenuFrame:Hide()

-- 安全坐骑设置函数
local function SafeSetMount(id)
    if type(id) == "number" then
        SetMount(id)
    else

    end
end

-- 修正后的坐骑菜单点击处理
local function OnMountMenuSelect(button)
    SafeSetMount(button.value)
end



-- 初始化菜单
UIDropDownMenu_Initialize(mountMenuFrame, function(self)
    local info = UIDropDownMenu_CreateInfo()
    
    -- 按 mountOrder 顺序遍历
    for _, name in ipairs(mountOrder) do
        local id = mountIDs[name]
        if id then
            -- 验证ID类型
            if type(id) ~= "number" then
                print("|cFFFF0000宠物配置错误：["..name.."]的ID不是数字|r")
            end
            
            info.text = name
            info.value = id
            info.func = OnMountMenuSelect
            info.arg1 = id
            UIDropDownMenu_AddButton(info)
        end
    end
end)


-- 绑定点击事件
selectMountBtn:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, mountMenuFrame, self, 0, 0)
end)

-- 坐骑ID输入框
local editBox3 = CreateFrame("EditBox", "editBox3", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
editBox3:SetSize(85, 30)
editBox3:SetPoint("LEFT", selectMountBtn, "RIGHT", 8, 0)
editBox3:SetText(iMorphToolsDBC.MountModelID or "21974")
editBox3:SetAutoFocus(false)

editBox3:SetScript("OnTextChanged", function(self)
    iMorphToolsDBC.MountModelID = self:GetText()
end)

-- 手动改坐骑按钮
local buttonMountChange = CreateFrame("Button", "buttonMountChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonMountChange:SetSize(121, 30)
buttonMountChange:SetPoint("LEFT", editBox3, "RIGHT", 1, 0)
buttonMountChange:SetText("手动坐骑改模")

-- 悬停提示
buttonMountChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("输入坐骑模型ID后点击修改", 1, 1, 1)
    GameTooltip:Show()
end)

buttonMountChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- 点击逻辑
buttonMountChange:SetScript("OnClick", function()
    local inputID = tonumber(editBox3:GetText())
    if inputID then
        SetMount(inputID)
    else

    end
end)

preWidget = selectMountBtn  -- 更新定位锚点



-- 调整映射表结构
local raceOptions = {
    ["人类"] = 1,
    ["兽人"] = 2,
    ["矮人"] = 3,
    ["暗夜"] = 4,
    ["亡灵"] = 5,
    ["牛头"] = 6,
    ["侏儒"] = 7,
    ["巨魔"] = 8,
    ["血精灵"] = 10,
    ["德莱尼"] = 11,
}

-- 创建种族选择按钮
local selectRaceBtn = CreateFrame("Button", "SelectRaceBtn", iMorphToolsMainFrame, "UIPanelButtonTemplate")
selectRaceBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
selectRaceBtn:SetSize(170, 30)
selectRaceBtn:SetText("点击修改种族模型")  

-- 悬停提示
selectRaceBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击选择种族直接生效", 1, 1, 1)
    GameTooltip:Show()
end)
selectRaceBtn:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

-- 创建种族菜单框架
local raceMenu = CreateFrame("Frame", "RaceSelectMenu", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
raceMenu:Hide()

-- 安全种族设置函数
local function SafeSetRace(id)
    if type(id) == "number" then
        SetRace(id)
		Customizations()
    else

    end
end

-- 修正后的种族菜单点击处理
local function OnRaceSelect(button)
    local raceName = button.value  -- 获取选择的文本值
    local raceID = raceOptions[raceName]
    if raceID then
        SafeSetRace(raceID)
    else

    end
end

-- 更新种族菜单初始化
UIDropDownMenu_Initialize(raceMenu, function(self)
    local info = UIDropDownMenu_CreateInfo()
    for raceName, raceID in pairs(raceOptions) do
        if type(raceID) ~= "number" then

        end
        
        info.text = raceName
        info.value = raceName  -- 传递文本用于查找
        info.func = OnRaceSelect
        info.arg1 = raceID     -- 直接传递数字ID
        UIDropDownMenu_AddButton(info)
    end
end)

-- 绑定按钮点击
selectRaceBtn:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, raceMenu, self, 0, 0)
end)

preWidget = selectRaceBtn

-- 变性按钮保持不变
local buttonGenderChange = CreateFrame("Button", "buttonGenderChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonGenderChange:SetSize(160, 30)
buttonGenderChange:SetPoint("LEFT", selectRaceBtn, "RIGHT", 8, 0)
buttonGenderChange:SetText("变性")
buttonGenderChange:Show()

buttonGenderChange:SetScript("OnClick", function()
    SetGender() 
	Customizations()
end)

-- 悬停提示
buttonGenderChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("点击改变角色性别", 1, 1, 1)
    GameTooltip:Show()
end)
buttonGenderChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

-- 定义变形形态ID与名称的映射表
local shapeshiftIDs = {
    ["猫"] = 1,
    ["熊"] = 5,
    ["SM狼"] = 16,
    ["树"] = 2,
    ["大飞"] = 27,
    ["旅行"] = 3,
    ["小飞"] = 29,
    ["水栖"] = 4,
    ["枭兽"] = 31,
}

-- 定义变形形态的顺序数组
local shapeshiftOrder = {
    "猫", "熊", "SM狼", "树", "大飞", "旅行", "小飞", "水栖", "枭兽"
}

--iMorphToolsDBC = iMorphToolsDBC or {}

-- 加载时恢复用户选择
local savedShapeshiftSelection = iMorphToolsDBC.shapeshiftSelection or "猎豹形态"
for shapeshiftName, shapeshiftID in pairs(shapeshiftIDs) do
    if shapeshiftName == savedShapeshiftSelection then
        selectedShapeshiftID = shapeshiftID
        break
    end
end
if not selectedShapeshiftID then
    selectedShapeshiftID = nil
end

-- 创建变形形态下拉菜单
local dropdownShapeshifts = CreateFrame("Frame", "WPDemoDropdownShapeshifts", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
dropdownShapeshifts:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -17, -3)
UIDropDownMenu_SetWidth(dropdownShapeshifts, 100)
UIDropDownMenu_SetText(dropdownShapeshifts, "变形形态")

local selectedShapeshiftID = selectedShapeshiftID or nil
local selectedShapeshiftName = savedShapeshiftSelection or "猎豹形态"

-- 使用顺序数组初始化菜单
UIDropDownMenu_Initialize(dropdownShapeshifts, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        -- 按顺序遍历
        for _, shapeshiftName in ipairs(shapeshiftOrder) do
            local shapeshiftID = shapeshiftIDs[shapeshiftName]
            if shapeshiftID then
                info.text = shapeshiftName
                info.value = shapeshiftID
                info.checked = shapeshiftID == selectedShapeshiftID
                info.func = function()
                    selectedShapeshiftID = shapeshiftID
                    selectedShapeshiftName = shapeshiftName
                    iMorphToolsDBC.shapeshiftSelection = selectedShapeshiftName
                    self:SetValue(shapeshiftID)
                    UIDropDownMenu_SetText(dropdownShapeshifts, "" .. selectedShapeshiftName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

-- 保存选择的变形形态ID
function dropdownShapeshifts:SetValue(newValue)
    selectedShapeshiftID = newValue
    CloseDropDownMenus()
end
UIDropDownMenu_SetText(dropdownShapeshifts, "" .. (selectedShapeshiftName or "猎豹形态"))

-- 定义形态ID与名称的映射表，仅保留数字ID
local ShapeshiftmodelIDs = {
    ["幽灵虎"] = 21974,
    ["幽灵狼"] = 21114,
    ["吉安娜"] = 30865,
    ["巫妖王"] = 24191,
    ["瓦王"] = 28127,
    ["伊利丹"] = 27571,
    ["祖格老虎BOSS"] = 15214,
    ["大脚"] = 31094,
    ["逐日"] = 29673,
    ["洛卡纳哈"] = 28010,
    ["小洛卡纳哈"] = 28649,
    ["古德利亚"] = 28871,
    ["小古德利亚"] = 28873,
    ["血月狼人"] = 26787,
    ["烈焰舞娘"] = 23732,
    ["诺格弗格药剂"] = 7550,
    ["幽灵狮鹫"] = 26691,
    ["凤凰"] = 17890,
    ["金色凤凰"] = 121416,
    ["祥云火鹰"] = 126079,
    ["火猫"] = 131379,
    ["萨尔"] = 27275,
    ["加尔鲁什"] = 28195,
    ["凯尔萨斯"] = 20063,
    ["阿尔萨斯（人类）"] = 29958,
    ["红色幼龙"] = 28047,
    ["时光迷失元龙"] = 31268,
}

-- 定义形态模型的顺序数组
local shapeshiftModelOrder = {
    "幽灵虎", "幽灵狼", "吉安娜", "巫妖王", "瓦王", "伊利丹", 
    "祖格老虎BOSS", "大脚", "逐日", "洛卡纳哈", "小洛卡纳哈", 
    "古德利亚", "小古德利亚", "血月狼人", "烈焰舞娘", 
    "诺格弗格药剂", "幽灵狮鹫", "凤凰", "金色凤凰", 
    "祥云火鹰", "火猫", "萨尔", "加尔鲁什", "凯尔萨斯", 
    "阿尔萨斯（人类）", "红色幼龙", "时光迷失元龙"
}

-- 加载时恢复用户选择
local savedShapeshiftModelSelection = iMorphToolsDBC.ShapeshiftModelSelection or "幽灵虎"
for ShapeshiftmodelName, ShapeshiftmodelID in pairs(ShapeshiftmodelIDs) do
    if ShapeshiftmodelName == savedShapeshiftModelSelection then
        selectedShapeshiftModelID = ShapeshiftmodelID
        break
    end
end
if not selectedShapeshiftModelID then
    selectedShapeshiftModelID = nil
end

-- 创建形态模型下拉菜单
local dropdownShapeshiftModels = CreateFrame("Frame", "WPDemoDropdownShapeshiftModels", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
dropdownShapeshiftModels:SetPoint("LEFT", dropdownShapeshifts, "RIGHT", -30, 0)
UIDropDownMenu_SetWidth(dropdownShapeshiftModels, 85)
UIDropDownMenu_SetText(dropdownShapeshiftModels, "形态模型")

local selectedShapeshiftModelID = selectedShapeshiftModelID or nil
local selectedShapeshiftModelName = savedShapeshiftModelSelection or "幽灵虎"

-- 使用顺序数组初始化菜单
UIDropDownMenu_Initialize(dropdownShapeshiftModels, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        -- 按顺序遍历模型选项
        for _, ShapeshiftmodelName in ipairs(shapeshiftModelOrder) do
            local ShapeshiftmodelID = ShapeshiftmodelIDs[ShapeshiftmodelName]
            if ShapeshiftmodelID then
                info.text = ShapeshiftmodelName
                info.value = ShapeshiftmodelID
                info.checked = ShapeshiftmodelID == selectedShapeshiftModelID
                info.func = function()
                    selectedShapeshiftModelID = ShapeshiftmodelID
                    selectedShapeshiftModelName = ShapeshiftmodelName
                    iMorphToolsDBC.ShapeshiftModelSelection = selectedShapeshiftModelName
                    self:SetValue(ShapeshiftmodelID)
                    UIDropDownMenu_SetText(dropdownShapeshiftModels, "" .. selectedShapeshiftModelName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end

        -- 手动输入选项（放在最后）
        info.text = "手动输入"
        info.value = nil
        info.checked = selectedShapeshiftModelName == "手动输入"
        info.func = function()
            selectedShapeshiftModelID = nil
            selectedShapeshiftModelName = "手动输入"
            iMorphToolsDBC.ShapeshiftModelSelection = selectedShapeshiftModelName
            self:SetValue(nil)
            UIDropDownMenu_SetText(dropdownShapeshiftModels, "手输")
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- 保存选择的形态模型ID
function dropdownShapeshiftModels:SetValue(newValue)
    selectedShapeshiftModelID = newValue
    CloseDropDownMenus()
end
UIDropDownMenu_SetText(dropdownShapeshiftModels, "" .. (selectedShapeshiftModelName or "幽灵虎"))

-- 文本框10
local editBox10 = CreateFrame("EditBox", "editBox10", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
editBox10:SetSize(45, 30)
editBox10:SetPoint("LEFT", dropdownShapeshiftModels, "RIGHT", -8, 0)

-- 从iMorphToolsDBC中读取保存的形态模型ID
local savedShapeshiftModelID = iMorphToolsDBC.ShapeshiftModelID or "21974"
editBox10:SetText(savedShapeshiftModelID)
editBox10:Show()

if editBox10:IsAutoFocus() then
    editBox10:SetAutoFocus(false)
end

-- 监听编辑框内容的变化
editBox10:SetScript("OnTextChanged", function()
    iMorphToolsDBC.ShapeshiftModelID = editBox10:GetText() -- 当编辑框内容变化时，保存到iMorphToolsDBC
end)

-- 改变形按钮
local buttonShapeshiftChange = CreateFrame("Button", "buttonShapeshiftChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonShapeshiftChange:SetSize(65, 30)
buttonShapeshiftChange:SetPoint("LEFT", editBox10, "RIGHT", 1, 0)
buttonShapeshiftChange:SetText("改形态")
buttonShapeshiftChange:Show()

-- 添加按钮的鼠标悬停提示
buttonShapeshiftChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:AddLine("选择形态和形态模型，点击修改", 1, 1, 1);
    GameTooltip:Show();
end);

buttonShapeshiftChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

buttonShapeshiftChange:SetScript("OnClick", function()
    local shapeshiftID = selectedShapeshiftID
    local ShapeshiftmodelID = selectedShapeshiftModelID or tonumber(editBox10:GetText())

    if shapeshiftID and ShapeshiftmodelID then
        SetShapeshiftForm(shapeshiftID, ShapeshiftmodelID) 
    end
end)

preWidget = dropdownShapeshifts


-- 模型缩放滑块（实时生效）
local scaleSlider = CreateFrame("Slider", "scaleSlider", iMorphToolsMainFrame, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 18, -12)
scaleSlider:SetMinMaxValues(0.5, 3.0)
scaleSlider:SetValueStep(0.1)
scaleSlider:SetValue(1.0)
scaleSlider:SetWidth(330)  
scaleSlider.text = _G[scaleSlider:GetName().."Text"]
scaleSlider.text:SetText("模型缩放: 1.00")

-- 保持原始标签文字
local lowText = _G[scaleSlider:GetName() .. "Low"]
lowText:SetText("缩小") 
local highText = _G[scaleSlider:GetName() .. "High"]
highText:SetText("放大")

-- 实时缩放逻辑
scaleSlider:SetScript("OnValueChanged", function(self)
    local scale = self:GetValue()
    local formatted = string.format("模型缩放: %.2f", scale)
    self.text:SetText(formatted)
    SetScale(scale)  -- 直接生效
end)

preWidget = scaleSlider

-- 宠物模型缩放滑块（实时生效）
local petScaleSlider = CreateFrame("Slider", "petScaleSlider", iMorphToolsMainFrame, "OptionsSliderTemplate")
petScaleSlider:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -18)
petScaleSlider:SetMinMaxValues(0.5, 3.0)
petScaleSlider:SetValueStep(0.1)
petScaleSlider:SetValue(1.0)
petScaleSlider:SetWidth(330)
petScaleSlider.text = _G[petScaleSlider:GetName().."Text"]
petScaleSlider.text:SetText("宠物缩放: 1.00")

-- 保持原始宠物标签
local petLowText = _G[petScaleSlider:GetName() .. "Low"]
petLowText:SetText("缩小")
local petHighText = _G[petScaleSlider:GetName() .. "High"]
petHighText:SetText("放大")

petScaleSlider:SetScript("OnValueChanged", function(self)
    local scale = self:GetValue()
    local formatted = string.format("宠物缩放: %.2f", scale)
    self.text:SetText(formatted)
    SetScalePet(scale)  -- 直接生效
end)

preWidget = petScaleSlider




-- 创建改装备下拉列表
local dropDown = CreateFrame("FRAME", "WPDemoDropDown2", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
dropDown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -18, -14)
UIDropDownMenu_SetWidth(dropDown, 150)

-- 从iMorphToolsDBC中读取已保存的槽位ID
--iMorphToolsDBC = iMorphToolsDBC or {}
local savedSlotID = iMorphToolsDBC.selectedSlotID or 1
selectedSlotID = savedSlotID

local slotIDs = {
  [1] = "头部",
  [3] = "肩部",
  [15] = "背部",
  [5] = "胸部",
  [9] = "手腕",
  [10] = "手部",
  [6] = "腰部",
  [7] = "腿部",
  [8] = "脚部",
  [16] = "主手",
  [17] = "副手",
  [18] = "远程",
}

-- 定义槽位顺序数组
local slotOrder = {1, 3, 15, 5, 9, 10, 6, 7, 8, 16, 17, 18}

-- 下拉列表菜单
UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        -- 按顺序遍历槽位
        for _, slotID in ipairs(slotOrder) do
            local slotName = slotIDs[slotID]
            if slotName then
                info.text = slotName
                info.value = slotID
                info.checked = (slotID == selectedSlotID)
                info.func = function() self:SetValue(slotID) end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

-- 保存选择的选项值
function dropDown:SetValue(newValue)
    selectedSlotID = newValue
    local slotName = slotIDs[newValue] or "未知栏位"
    UIDropDownMenu_SetText(dropDown, "栏位: " .. slotName)
    iMorphToolsDBC.selectedSlotID = newValue -- 将选择保存到iMorphToolsDBC
    CloseDropDownMenus()
end

-- 初始化时设置下拉菜单的文本描述
UIDropDownMenu_SetText(dropDown, "栏位: " .. (slotIDs[selectedSlotID] or "未知栏位"))

-- 创建模型ID文本框
local textFrame = CreateFrame("EditBox", "WPDemoTextFrame", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
textFrame:SetSize(85, 30)
textFrame:SetPoint("LEFT", dropDown, "RIGHT", -8, 0)

-- 从iMorphToolsDBC中读取保存的模型ID
local savedModelID = iMorphToolsDBC.modelID or "物品编号"

textFrame:SetText(savedModelID)
textFrame:SetAutoFocus(false)

-- 监听编辑框内容的变化
textFrame:SetScript("OnTextChanged", function()
    iMorphToolsDBC.modelID = textFrame:GetText() -- 当编辑框内容变化时，保存到iMorphToolsDBC
end)

-- 创建改装备按钮
local buttonFrame = CreateFrame("Button", "WPDemoButtonFrame", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonFrame:SetSize(75, 30)
buttonFrame:SetPoint("LEFT", textFrame, "RIGHT", 1, 0)
buttonFrame:SetText("改装备")

-- 添加按钮的鼠标悬停提示
buttonFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:AddLine("选择装备栏位然后在编辑框填写物品ID，点击修改", 1, 1, 1);
    GameTooltip:Show();
end);

buttonFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

buttonFrame:SetScript("OnClick", function()
    local itemID = tonumber(textFrame:GetText())
    if selectedSlotID and itemID then
        SetItem(selectedSlotID, itemID)
    end
end)

preWidget = dropDown



-- 武器附魔
local mainHandBjfmCommandSets = {
  ["主-无附魔"] = function() SetEnchant(16, 0) end,
  ["主-寒气"] = function() SetEnchant(16, 1) end,
  ["主-蓝光高"] = function() SetEnchant(16, 24) end,
  ["主-烈火武器"] = function() SetEnchant(16, 25) end,
  ["主-风剑特效"] = function() SetEnchant(16, 137) end,
  ["主-冷光"] = function() SetEnchant(16, 27) end,
  ["主-珠光宝气"] = function() SetEnchant(16, 28) end,
  ["主-黄光"] = function() SetEnchant(16, 29) end,
  ["主-黑色闪烁"] = function() SetEnchant(16, 138) end,
  ["主-跳动蓝焰"] = function() SetEnchant(16, 139) end,
  ["主-火焰加闪电"] = function() SetEnchant(16, 140) end,
  ["主-大绿光圈"] = function() SetEnchant(16, 141) end,
  ["主-金色蝴蝶"] = function() SetEnchant(16, 142) end,
  ["主-大蓝光圈"] = function() SetEnchant(16, 143) end,
  ["主-间歇魔气"] = function() SetEnchant(16, 145) end,
  ["主-红光高"] = function() SetEnchant(16, 101) end,
  ["主-黄辉光高"] = function() SetEnchant(16, 102) end,
  ["主-大团烟雾"] = function() SetEnchant(16, 147) end,
  ["主-白光高"] = function() SetEnchant(16, 104) end,
  ["主-紫色高"] = function() SetEnchant(16, 105) end,
  ["主-绿光高"] = function() SetEnchant(16, 106) end,
  ["主-魔法激荡"] = function() SetEnchant(16, 148) end,
  ["主-三黄星"] = function() SetEnchant(16, 149) end,
  ["主-黑辉光高"] = function() SetEnchant(16, 124) end,
  ["主-三蓝星"] = function() SetEnchant(16, 150) end,
  ["主-流淌白光"] = function() SetEnchant(16, 126) end,
  ["主-圣光光团"] = function() SetEnchant(16, 151) end,
  ["主-流淌紫光"] = function() SetEnchant(16, 128) end,
  ["主-流淌黄光"] = function() SetEnchant(16, 129) end,
  ["主-流淌黑光"] = function() SetEnchant(16, 130) end,
  ["主-猫鼬"] = function() SetEnchant(16, 155) end,
  ["主-野蛮"] = function() SetEnchant(16, 156) end,
  ["主-霜魂"] = function() SetEnchant(16, 157) end,
  ["主-特效法术能量"] = function() SetEnchant(16, 159) end,
  ["主-魔法激荡"] = function() SetEnchant(16, 160) end,
  ["主-阳炎"] = function() SetEnchant(16, 158) end,
  ["主-血魄"] = function() SetEnchant(16, 164) end,
  ["主-斩杀"] = function() SetEnchant(16, 165) end,
}

local offHandBjfmCommandSets = {
  ["副-无附魔"] = function() SetEnchant(17, 0) end,
  ["副-寒气"] = function() SetEnchant(17, 1) end,
  ["副-蓝光高"] = function() SetEnchant(17, 24) end,
  ["副-烈火武器"] = function() SetEnchant(17, 25) end,
  ["副-风剑特效"] = function() SetEnchant(17, 137) end,
  ["副-冷光"] = function() SetEnchant(17, 27) end,
  ["副-珠光宝气"] = function() SetEnchant(17, 28) end,
  ["副-黄光"] = function() SetEnchant(17, 29) end,
  ["副-黑色闪烁"] = function() SetEnchant(17, 138) end,
  ["副-跳动蓝焰"] = function() SetEnchant(17, 139) end,
  ["副-火焰加闪电"] = function() SetEnchant(17, 140) end,
  ["副-大绿光圈"] = function() SetEnchant(17, 141) end,
  ["副-金色蝴蝶"] = function() SetEnchant(17, 142) end,
  ["副-大蓝光圈"] = function() SetEnchant(17, 143) end,
  ["副-间歇魔气"] = function() SetEnchant(17, 145) end,
  ["副-红光高"] = function() SetEnchant(17, 101) end,
  ["副-黄辉光高"] = function() SetEnchant(17, 102) end,
  ["副-大团烟雾"] = function() SetEnchant(17, 147) end,
  ["副-白光高"] = function() SetEnchant(17, 104) end,
  ["副-紫色高"] = function() SetEnchant(17, 105) end,
  ["副-绿光高"] = function() SetEnchant(17, 106) end,
  ["副-魔法激荡"] = function() SetEnchant(17, 148) end,
  ["副-三黄星"] = function() SetEnchant(17, 149) end,
  ["副-黑辉光高"] = function() SetEnchant(17, 124) end,
  ["副-三蓝星"] = function() SetEnchant(17, 150) end,
  ["副-流淌白光"] = function() SetEnchant(17, 126) end,
  ["副-圣光光团"] = function() SetEnchant(17, 151) end,
  ["副-流淌紫光"] = function() SetEnchant(17, 128) end,
  ["副-流淌黄光"] = function() SetEnchant(17, 129) end,
  ["副-流淌黑光"] = function() SetEnchant(17, 130) end,
  ["副-猫鼬"] = function() SetEnchant(17, 155) end,
  ["副-野蛮"] = function() SetEnchant(17, 156) end,
  ["副-霜魂"] = function() SetEnchant(17, 157) end,
  ["副-特效法术能量"] = function() SetEnchant(17, 159) end,
  ["副-魔法激荡"] = function() SetEnchant(17, 160) end,
  ["副-阳炎"] = function() SetEnchant(17, 158) end,
  ["副-血魄"] = function() SetEnchant(17, 164) end,
  ["副-斩杀"] = function() SetEnchant(17, 165) end,
}

-- 定义主手附魔顺序数组
local mainHandOrder = {
    "主-无附魔", "主-寒气", "主-蓝光高", "主-烈火武器", "主-风剑特效", 
    "主-冷光", "主-珠光宝气", "主-黄光", "主-黑色闪烁", "主-跳动蓝焰", 
    "主-火焰加闪电", "主-大绿光圈", "主-金色蝴蝶", "主-大蓝光圈", "主-间歇魔气", 
    "主-红光高", "主-黄辉光高", "主-大团烟雾", "主-白光高", "主-紫色高", 
    "主-绿光高", "主-魔法激荡", "主-三黄星", "主-黑辉光高", "主-三蓝星", 
    "主-流淌白光", "主-圣光光团", "主-流淌紫光", "主-流淌黄光", "主-流淌黑光", 
    "主-猫鼬", "主-野蛮", "主-霜魂", "主-特效法术能量", "主-魔法激荡", 
    "主-阳炎", "主-血魄", "主-斩杀"
}

-- 定义副手附魔顺序数组
local offHandOrder = {
    "副-无附魔", "副-寒气", "副-蓝光高", "副-烈火武器", "副-风剑特效", 
    "副-冷光", "副-珠光宝气", "副-黄光", "副-黑色闪烁", "副-跳动蓝焰", 
    "副-火焰加闪电", "副-大绿光圈", "副-金色蝴蝶", "副-大蓝光圈", "副-间歇魔气", 
    "副-红光高", "副-黄辉光高", "副-大团烟雾", "副-白光高", "副-紫色高", 
    "副-绿光高", "副-魔法激荡", "副-三黄星", "副-黑辉光高", "副-三蓝星", 
    "副-流淌白光", "副-圣光光团", "副-流淌紫光", "副-流淌黄光", "副-流淌黑光", 
    "副-猫鼬", "副-野蛮", "副-霜魂", "副-特效法术能量", "副-魔法激荡", 
    "副-阳炎", "副-血魄", "副-斩杀"
}

-- 主手附魔下拉菜单
--iMorphToolsDBC = iMorphToolsDBC or {}
local savedMainHandSelection = iMorphToolsDBC.mainHandbjfmSelection or ""
local selectedMainHandbjfmCommands = mainHandBjfmCommandSets[savedMainHandSelection] or nil
local selectedMainHandbjfmName = savedMainHandSelection

local mainHandbjfmDropDown = CreateFrame("Frame", "WPDemoMainHandbjfmDropDown", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
mainHandbjfmDropDown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, 0)
UIDropDownMenu_SetWidth(mainHandbjfmDropDown, 112.5)
UIDropDownMenu_SetText(mainHandbjfmDropDown, selectedMainHandbjfmName or "请选择")

-- 按顺序初始化主手菜单
UIDropDownMenu_Initialize(mainHandbjfmDropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    if level == 1 then
        -- 按顺序遍历主手附魔
        for _, bjfmName in ipairs(mainHandOrder) do
            local commandFunc = mainHandBjfmCommandSets[bjfmName]
            if commandFunc then
                info.text = bjfmName
                info.value = bjfmName
                info.checked = (bjfmName == selectedMainHandbjfmName)
                info.func = function()
                    selectedMainHandbjfmCommands = commandFunc
                    selectedMainHandbjfmName = bjfmName
                    iMorphToolsDBC.mainHandbjfmSelection = selectedMainHandbjfmName
                    UIDropDownMenu_SetText(mainHandbjfmDropDown, selectedMainHandbjfmName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

-- 添加点击事件处理器，当点击下拉菜单时展开菜单
mainHandbjfmDropDown:SetScript("OnMouseDown", function(self, button)
    UIDropDownMenu_Refresh(self)
end)

-- 副手附魔下拉菜单
local savedOffHandSelection = iMorphToolsDBC.offHandbjfmSelection or ""
local selectedOffHandbjfmCommands = offHandBjfmCommandSets[savedOffHandSelection] or nil
local selectedOffHandbjfmName = savedOffHandSelection

local offHandbjfmDropDown = CreateFrame("Frame", "WPDemoOffHandbjfmDropDown", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
offHandbjfmDropDown:SetPoint("LEFT", mainHandbjfmDropDown, "RIGHT", -30, 0)
UIDropDownMenu_SetWidth(offHandbjfmDropDown, 112.5)
UIDropDownMenu_SetText(offHandbjfmDropDown, selectedOffHandbjfmName or "请选择")

-- 按顺序初始化副手菜单
UIDropDownMenu_Initialize(offHandbjfmDropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    if level == 1 then
        -- 按顺序遍历副手附魔
        for _, bjfmName in ipairs(offHandOrder) do
            local commandFunc = offHandBjfmCommandSets[bjfmName]
            if commandFunc then
                info.text = bjfmName
                info.value = bjfmName
                info.checked = (bjfmName == selectedOffHandbjfmName)
                info.func = function()
                    selectedOffHandbjfmCommands = commandFunc
                    selectedOffHandbjfmName = bjfmName
                    iMorphToolsDBC.offHandbjfmSelection = selectedOffHandbjfmName
                    UIDropDownMenu_SetText(offHandbjfmDropDown, selectedOffHandbjfmName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

-- 添加点击事件处理器，当点击下拉菜单时展开菜单
offHandbjfmDropDown:SetScript("OnMouseDown", function(self, button)
    UIDropDownMenu_Refresh(self)
end)

-- 武器附魔按钮
local bjfmButton = CreateFrame("Button", "bjfmButton", iMorphToolsMainFrame, "UIPanelButtonTemplate")
bjfmButton:SetSize(75, 30)
bjfmButton:SetPoint("LEFT", offHandbjfmDropDown, "RIGHT", -16, 3)
bjfmButton:SetText("武器附魔")
bjfmButton:Show()

-- 添加按钮的鼠标悬停提示
bjfmButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:AddLine("选择主副手附魔效果，点击修改", 1, 1, 1);
    GameTooltip:Show();
end);

bjfmButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
end);

bjfmButton:SetScript("OnClick", function()
    if selectedMainHandbjfmCommands then
        selectedMainHandbjfmCommands() -- 执行主命令函数
    end
    if selectedOffHandbjfmCommands then
        selectedOffHandbjfmCommands() -- 执行副命令函数
    end
end)

-- 确保初始化时下拉菜单显示正确
if selectedMainHandbjfmName then
    UIDropDownMenu_SetText(mainHandbjfmDropDown, selectedMainHandbjfmName)
end
if selectedOffHandbjfmName then
    UIDropDownMenu_SetText(offHandbjfmDropDown, selectedOffHandbjfmName)
end

preWidget = mainHandbjfmDropDown

--iMorphToolsDBC = iMorphToolsDBC or {}

-- 技能ID与名称的映射表
local spellNames = {
	["------近战AOE类------"] = 0,
    ["------BUFF特效类------"] = 0,
    ["------弹道技能类------"] = 0,
    ["------远程AOE类------"] = 0,
    ["神圣风暴"] = 53385,
    ["混乱之箭"] = 59172,
    ["旋风斩"] = 50622,
    ["熔岩爆裂"] = 60043,
    ["炎爆"] = 42891,
    ["火焰漩涡"] = 59183,
    ["雷霆一击"] = 47502,
    ["小红人"] = 19574,
    ["狂暴（手红光）"] = 20572,
    ["光明使者（金光闪耀）"] = 73326,
    ["暗影形态"] = 15473,
    ["橙斧鬼影"] = 72523,
    ["鬼眼标记"] = 64465,
    ["大型虫群冲击"] = 34240,
    ["小型虫群冲击"] = 37779,
    ["凋零缠绕"] = 49895,
    ["复仇之怒"] = 31884,
    ["旋风"] = 21992,
    ["猴子球气泡"] = 48332,
    ["守护之魂翅膀"] = 47788,
    ["急奔"] = 33357,
    ["疾跑"] = 11305,
    ["回血歌（音符环绕）"] = 64843,
    ["回蓝歌"] = 64901,
    ["落雷"] = 48467,
    ["火雨"] = 47820,
    ["暴风雪"] = 42940,
    ["箭雪"] = 58434,
    ["多重暗影箭"] = 49617,
}

-- 定义技能顺序数组
local spellOrder = {
    "------近战AOE类------", "神圣风暴", "雷霆一击", "旋风斩", 
    "------BUFF特效类------", "光明使者（金光闪耀）", "暗影形态", "橙斧鬼影", "鬼眼标记", "守护之魂翅膀", "旋风", "复仇之怒", "猴子球气泡", "急奔", "疾跑", "回血歌（音符环绕）", "小红人", "火焰漩涡", "狂暴（手红光）", "回蓝歌", 
    "------弹道技能类------", "大型虫群冲击", "小型虫群冲击", "凋零缠绕", "熔岩爆裂", "炎爆", "混乱之箭", "多重暗影箭", 
    "------远程AOE类------", "暴风雪", "落雷", "箭雪", "火雨"
}



-- 从iMorphToolsDBC中读取已保存的数据
iMorphToolsDBC = iMorphToolsDBC or {}
local savedSelectedSpellName = iMorphToolsDBC.selectedSpellName or "神圣风暴"
local savedEditBoxContent = iMorphToolsDBC.editBoxContent
local savedDynamicSpellName = iMorphToolsDBC.dynamicSpellName or nil
local savedDynamicSpellID = iMorphToolsDBC.dynamicSpellID or nil

---------- 新增的动态法术下拉列表 ----------
local dynamicSpellDropdown = CreateFrame("Frame", "DynamicSpellDropdown", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
dynamicSpellDropdown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, 0)
UIDropDownMenu_SetWidth(dynamicSpellDropdown, 82.5)
UIDropDownMenu_SetText(dynamicSpellDropdown, savedDynamicSpellName or "动态选择法术")

-- 初始化动态法术下拉菜单
local function InitializeDynamicSpellDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo()
    local foundAny = false

    if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
        -- Retail: 使用 C_SpellBook API
        local numSkillLines = C_SpellBook.GetNumSpellBookSkillLines()
        for i = 1, numSkillLines do
            local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
            if skillLineInfo and skillLineInfo.name ~= "综合" then
                local offset = skillLineInfo.itemIndexOffset
                local numSpells = skillLineInfo.numSpellBookItems
                for j = offset + 1, offset + numSpells do
                    local spellInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
                    if spellInfo and spellInfo.itemType == Enum.SpellBookItemType.Spell and spellInfo.spellID then
                        local spellName = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
                        if spellName then
                            info.text = spellName
                            info.arg1 = spellInfo.spellID
                            info.checked = spellName == savedDynamicSpellName
                            info.func = function(_, arg1)
                                savedDynamicSpellName = spellName
                                savedDynamicSpellID = arg1
                                iMorphToolsDBC.dynamicSpellName = savedDynamicSpellName
                                iMorphToolsDBC.dynamicSpellID = savedDynamicSpellID
                                UIDropDownMenu_SetText(dynamicSpellDropdown, spellName)
                            end
                            UIDropDownMenu_AddButton(info)
                            foundAny = true
                        end
                    end
                end
            end
        end
    else
        -- Classic: 使用旧版 API
        local numTabs = GetNumSpellTabs()
        for tab = 1, numTabs do
            local name, _, offset, numSpells = GetSpellTabInfo(tab)
            if name and name ~= "综合" then
                for i = offset + 1, offset + numSpells do
                    local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
                    if spellType == "SPELL" and spellID then
                        local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                        if spellName then
                            info.text = spellName
                            info.arg1 = spellID
                            info.checked = spellName == savedDynamicSpellName
                            info.func = function(_, arg1)
                                savedDynamicSpellName = spellName
                                savedDynamicSpellID = arg1
                                iMorphToolsDBC.dynamicSpellName = savedDynamicSpellName
                                iMorphToolsDBC.dynamicSpellID = savedDynamicSpellID
                                UIDropDownMenu_SetText(dynamicSpellDropdown, spellName)
                            end
                            UIDropDownMenu_AddButton(info)
                            foundAny = true
                        end
                    end
                end
            end
        end
    end
    
    -- 如果没有找到法术，显示提示
    if not foundAny then
        info.text = "未找到可用法术"
        info.disabled = true
        UIDropDownMenu_AddButton(info)
    end
end

UIDropDownMenu_Initialize(dynamicSpellDropdown, InitializeDynamicSpellDropdown)

-- 技能ID编辑框
local editBox1 = CreateFrame("EditBox", "editBox1", iMorphToolsMainFrame, "BJ_InputBoxTemplate")
editBox1:SetSize(50, 30)
editBox1:SetPoint("LEFT", dynamicSpellDropdown, "RIGHT", -8, 0) 
editBox1:SetText(savedEditBoxContent or "")
editBox1:Show()
editBox1:SetAutoFocus(false)

-- 改技能按钮
local buttonSpellChange = CreateFrame("Button", "buttonSpellChange", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonSpellChange:SetSize(80, 30)  -- 加宽以适应新文字
buttonSpellChange:SetPoint("LEFT", editBox1, "RIGHT", 0, 0)
buttonSpellChange:SetText("》改技能》")  -- 修改按钮文字
buttonSpellChange:Show()

-- 技能效果修改结果下拉列表
local dropdownSpells = CreateFrame("Frame", "WPDemoDropdownSpells", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
dropdownSpells:SetPoint("LEFT", buttonSpellChange, "RIGHT", -15, 0)
UIDropDownMenu_SetWidth(dropdownSpells, 82.5)
UIDropDownMenu_SetText(dropdownSpells, "" .. savedSelectedSpellName)

--按顺序初始化技能效果下拉菜单
UIDropDownMenu_Initialize(dropdownSpells, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    if level == 1 then
        -- 按顺序遍历技能选项
        for _, spellName in ipairs(spellOrder) do
            local spellID = spellNames[spellName]
            if spellID then
                info.text = spellName
                info.value = spellID
                info.checked = spellName == savedSelectedSpellName
                info.func = function()
                    savedSelectedSpellName = spellName
                    iMorphToolsDBC.selectedSpellName = savedSelectedSpellName
                    UIDropDownMenu_SetText(dropdownSpells, "" .. savedSelectedSpellName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end)

-- 修改按钮提示文本
buttonSpellChange:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("技能显示效果修改：", 1, 1, 1)
    GameTooltip:AddLine("编辑框可填写触发类饰品，ID自己查询填入即可", 1, 1, 1)
    GameTooltip:AddLine("若编辑框填写了ID则忽略左侧选择框", 1, 1, 1)
    GameTooltip:Show()
end)

buttonSpellChange:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- 按钮点击逻辑
buttonSpellChange:SetScript("OnClick", function()
    local param
    local selectedSpellID = spellNames[savedSelectedSpellName]
    
    -- 无论编辑框是否有内容都保存当前值
    iMorphToolsDBC.editBoxContent = editBox1:GetText() -- 保存当前文本，可能是空字符串
    
    -- 参数选择优先级：
    -- 1. 编辑框内容（可能是空字符串）
    -- 2. 动态选择的法术ID
    -- 3. 预设下拉菜单选择的法术ID
    if editBox1:GetText() and editBox1:GetText() ~= "" then
        param = tonumber(editBox1:GetText())
    elseif savedDynamicSpellID then
        param = savedDynamicSpellID
    elseif selectedSpellID then
        param = selectedSpellID
    end
    
    if param then
        SetSpell(param, selectedSpellID)
    else

    end
end)

preWidget = dynamicSpellDropdown


-- 全局配置
local FEATURE_MAP = {
    -- [iMorph输出的中文特征] = "API特征键",
    ["发型"]    = "发型",
    ["脸型"]    = "脸型",
    ["发色"]    = "发色",
    ["肤色"]    = "肤色",
    ["亡灵特征"] = "特征",
    ["暗夜面纹"] = "面纹",
    ["犄角形状"] = "犄角形状",
    ["各族胡须"] = "胡须",
    ["犄角颜色"] = "犄角颜色",
    ["刺环"]     = "刺环",
    ["母牛头发"] = "头发",
    ["耳环"] = "耳环"
}

local PATTERN = "%.cust (%S+) %d+ %| .- %| (%d+)%-(%d+)$"

-- 数据管理器
local CustomizationManager = {
    cache = {},
    eventFrame = CreateFrame("Frame")
}

function CustomizationManager:ParseMessage(msg)
    if type(msg) ~= "string" then return end
    local chiFeature, minVal, maxVal = string.match(msg, PATTERN)
    local feature = FEATURE_MAP[chiFeature] or chiFeature
    
    if feature and minVal and maxVal then
        self.cache[feature] = {
            min = tonumber(minVal),
            max = tonumber(maxVal)
        }
        

    end
end

CustomizationManager.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
CustomizationManager.eventFrame:SetScript("OnEvent", function(_, _, msg)
    if msg then
        CustomizationManager:ParseMessage(msg)
    end
end)

-- 动态下拉菜单
local function CreateDynamicDropdown(buttonName, title, featureType, currentValueVar, tooltipText)
    local dropdown = CreateFrame("Frame", buttonName.."Dropdown", iMorphToolsMainFrame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", _G[buttonName], "BOTTOMLEFT", -16, -5)
    dropdown:Hide()
    
    -- 初始化当前值
    _G[currentValueVar] = math.max(1, _G[currentValueVar] or 1)

    -- 更新范围核心逻辑
    function dropdown:UpdateRange()
        local range = CustomizationManager.cache[featureType] or {min=1, max=13}
        self.minVal = range.min
        self.maxVal = range.max
        
        -- 越界修正
        if _G[currentValueVar] > self.maxVal then
            _G[currentValueVar] = self.maxVal
        end
        
        UIDropDownMenu_Initialize(self, self.initialize)
        UIDropDownMenu_SetSelectedValue(self, _G[currentValueVar])
    end

    -- 下拉菜单初始化
    dropdown.initialize = function(self)
        local info = UIDropDownMenu_CreateInfo()
        for i = self.minVal or 1, self.maxVal or 13 do
            info.text = format("%s %d", title, i)
            info.arg1 = i
            info.func = function(_, arg)
                if arg >= (self.minVal or 1) and arg <= (self.maxVal or 13) then
                    _G[currentValueVar] = arg
                    -- 注意：魔兽API参数是0-based，所以要减1
                    Customizations(featureType, arg - 1) 
                    UIDropDownMenu_SetSelectedValue(dropdown, arg)
                else

                end
            end
            info.checked = (i == _G[currentValueVar])
            UIDropDownMenu_AddButton(info)
        end
    end

    -- 按钮点击处理
    _G[buttonName]:SetScript("OnClick", function(self)
        -- 主动刷新数据
        dropdown:UpdateRange()
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
    end)

    -- 提示信息
    _G[buttonName]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(tooltipText, 1, 1, 1)
        GameTooltip:Show()
    end)

    return dropdown
end

-- 当前值初始化（完整列表）
local currentValues = {
    currentHairValue        = 1,  -- 发型
    currentFaceValue        = 1,  -- 脸型
    currentHaircolorValue   = 1,  -- 发色
    currentSkincolorValue   = 1,  -- 肤色
    currentUndeadfeatureValue = 1,  -- 亡灵特征
    currentNightelfmarkValue = 1,  -- 暗夜面纹
    currentHornshapeValue   = 1,  -- 犄角形状
    currentBeardValue       = 1,  -- 各族胡须
    currentHorncolorValue   = 1,  -- 犄角颜色
    currentSpineringsValue  = 1,  -- 刺环
    currentCowhairValue     = 1,  -- 母牛头发
    currentEarringValue     = 1   -- 耳环
}


-- 完整按钮配置表
local buttonConfigs = {
    -- 第一行：基础设置
    {
        name = "buttonChangeHairstyle",
        text = "发型",
        featureType = "发型",
        currentVar = "currentHairValue",
        tooltip = "选择发型\n默认1-13修改种族/性别时刷新",
        anchor = {preWidget = "dynamicSpellDropdown", x = 18, y = 0}
    },
    {
        name = "buttonChangeFacialType",
        text = "脸型",
        featureType = "脸型",
        currentVar = "currentFaceValue",
        tooltip = "选择脸型\n默认1-13修改种族/性别时刷新",
        anchor = {relativeTo = "buttonChangeHairstyle", x = 0, y = 0}
    },
    {
        name = "buttonChangeHairColor",
        text = "发色",
        featureType = "发色",
        currentVar = "currentHaircolorValue",
        tooltip = "选择发色\n默认1-13修改种族/性别时刷新",
        anchor = {relativeTo = "buttonChangeFacialType", x = 0, y = 0}
    },
    {
        name = "buttonChangeSkinTone",
        text = "肤色",
        featureType = "肤色",
        currentVar = "currentSkincolorValue",
        tooltip = "选择肤色\n默认1-13修改种族/性别时刷新",
        anchor = {relativeTo = "buttonChangeHairColor", x = 1, y = 0}
    },

    -- 第二行：种族特征
    {
        name = "buttonChangeFeature",
        text = "亡灵特征",
        featureType = "特征",
        currentVar = "currentUndeadfeatureValue",
        tooltip = "调整亡灵特征\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {preWidget = "buttonChangeSkinTone", x = -113, y = 0},
        specialAnchor = true
    },
    {
        name = "buttonChangeFacialMarking",
        text = "暗夜面纹",
        featureType = "面纹",
        currentVar = "currentNightelfmarkValue",
        tooltip = "选择暗夜面纹\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeFeature", x = 0, y = 0}
    },
    {
        name = "buttonChangeHornShape",
        text = "犄角形状",
        featureType = "犄角形状",
        currentVar = "currentHornshapeValue",
        tooltip = "调整犄角形状\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeFacialMarking", x = 0, y = 0}
    },
    {
        name = "buttonChangeBeard",
        text = "各族胡须",
        featureType = "胡须",
        currentVar = "currentBeardValue",
        tooltip = "选择胡须样式\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeHornShape", x = 1, y = 0}
    },

    -- 第三行：特殊装饰
    {
        name = "buttonChangeHornColor",
        text = "犄角颜色",
        featureType = "犄角颜色",
        currentVar = "currentHorncolorValue",
        tooltip = "调整犄角颜色\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {preWidget = "buttonChangeBeard", x = -113, y = 0},
        specialAnchor = true
    },
    {
        name = "buttonChangeSpineRing",
        text = "刺环",
        featureType = "刺环",
        currentVar = "currentSpineringsValue",
        tooltip = "调整刺环样式\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeHornColor", x = 0, y = 0}
    },
    {
        name = "buttonChangeCowHair",
        text = "母牛头发",
        featureType = "头发",
        currentVar = "currentCowhairValue",
        tooltip = "选择牛头人发型\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeSpineRing", x = 0, y = 0}
    },
    {
        name = "buttonChangeEarring",
        text = "耳环",
        featureType = "耳环",
        currentVar = "currentEarringValue",
        tooltip = "调整耳环样式\n默认1-13修改种族/性别时刷新（种族限定）",
        anchor = {relativeTo = "buttonChangeCowHair", x = 1, y = 0}
    }
}


-- 界面创建
local prevWidget = dynamicSpellDropdown
for _, config in ipairs(buttonConfigs) do
    local btn = CreateFrame("Button", config.name, iMorphToolsMainFrame, "UIPanelButtonTemplate")
    btn:SetSize(84, 30)
    
    -- 定位逻辑
    if config.anchor.relativeTo then
        btn:SetPoint("LEFT", _G[config.anchor.relativeTo], "RIGHT", config.anchor.x, config.anchor.y)
    else
        btn:SetPoint("TOPLEFT", prevWidget, "BOTTOMLEFT", config.anchor.x, config.anchor.y)
        prevWidget = btn
    end
    
    btn:SetText(config.text)
    btn:Show()
    
    -- 新增：鼠标离开隐藏提示
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- 原有：鼠标悬停显示提示
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(config.tooltip, 1, 1, 1)
        GameTooltip:Show()
    end)
    
    -- 创建动态下拉
    CreateDynamicDropdown(
        config.name,
        config.text,
        config.featureType,
        config.currentVar,
        config.tooltip
    )
end

-- 特殊定位处理
buttonChangeFeature:SetPoint("TOPLEFT", buttonChangeSkinTone, "BOTTOMLEFT", -253, 0)
buttonChangeHornColor:SetPoint("TOPLEFT", buttonChangeBeard, "BOTTOMLEFT", -253, 0)
preWidget = buttonChangeEarring

-- 数据预加载
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    -- 初始化所有特征数据
    for _, config in ipairs(buttonConfigs) do
        Customizations(config.featureType, 0) -- 发送0值触发数据返回
    end
end)


--[[ 快速穷举坐骑模型ID测试用，初始ID设置
local currentMountId = 38000

-- 创建按钮：坐骑切换
local buttonChangeMount = CreateFrame("Button", "buttonChangeMount", iMorphToolsMainFrame, "UIPanelButtonTemplate")
buttonChangeMount:SetSize(64, 30) -- 设置大小
buttonChangeMount:SetPoint("LEFT", preWidget, "RIGHT", 1, 0) -- 根据之前的部件定位，这里使用preWidget作为参照物
buttonChangeMount:SetText("切换坐骑") -- 按钮文本

-- 设置按钮点击事件：坐骑切换
buttonChangeMount:SetScript("OnClick", function()
    -- 调用SetMount函数来切换坐骑
    SetMount(currentMountId)
    
    -- ID增加
    currentMountId = currentMountId + 1

    -- 更新按钮文本显示当前ID
    buttonChangeMount:SetText("切换坐骑 (" .. currentMountId - 1 .. ")")
end)

-- 显示按钮
buttonChangeMount:Show()


preWidget = buttonChangeMount]]


    --文字
    local version = iMorphToolsMainFrame:CreateFontString();
    version:SetPoint("BOTTOM", iMorphToolsMainFrame, "BOTTOM", 0, 8);
    version:SetFontObject(GameFontNormal);
    version:SetText("|cFFA335EEiMorphTools|cFFFF7D0Aby|cFFABD473聖殿十字军");
    version:Show()
end

function CreateiMorphToolsMiniMapButton(mainFrame)
    local iMorphToolsMiniMapButton = CreateFrame("Button", "iMorphToolsMiniMapButton", Minimap, "UICheckButtonTemplate")
    iMorphToolsMiniMapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 15, -110)
    iMorphToolsMiniMapButton:SetSize(26, 26)

    -- 设置按钮图标
    iMorphToolsMiniMapButton:SetNormalTexture("Interface\\AddOns\\iMorphTools\\horror")
    iMorphToolsMiniMapButton:SetPushedTexture("Interface\\AddOns\\iMorphTools\\horror")
	
	iMorphToolsMiniMapButton:Show()

    -- 添加鼠标悬停提示
    iMorphToolsMiniMapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText("iMorphTools\n右键按住拖动\n左键打开界面")
        GameTooltip:Show()
    end)

    iMorphToolsMiniMapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    iMorphToolsMiniMapButton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if mainFrame:IsShown() then
                mainFrame:Hide();
            else
                mainFrame:Show();
            end
        end
    end)

    -- 设置可移动属性
    iMorphToolsMiniMapButton:SetMovable(true)
    iMorphToolsMiniMapButton:RegisterForDrag("RightButton")
    iMorphToolsMiniMapButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    iMorphToolsMiniMapButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    end)


    return iMorphToolsMiniMapButton
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "iMorphTools" then
      InitUI()
      --StartTickers()
    end
end)


SlashCmdList["iMorphTools"] = function()
    if iMorphToolsMainFrame and not iMorphToolsMainFrame:IsVisible() then
        iMorphToolsMainFrame:Show()
    end
end
SLASH_iMorphTools1 = "/imt";
