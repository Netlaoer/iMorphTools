-- iMorphTools UI - Modern Dark Theme
-- 主界面逻辑，使用 IMT 命名空间中的数据

-- ============================================
-- 主题配色
-- ============================================
local T = {
    bg          = {0.06, 0.06, 0.08, 0.94},
    border      = {0.18, 0.18, 0.22, 1},
    titleBg     = {0.08, 0.08, 0.12, 1},
    titleBorder = {0.30, 0.30, 0.36, 1},
    accent      = {0.20, 0.60, 1.00, 1},
    accentDim   = {0.12, 0.35, 0.65, 1},
    btnBg       = {0.14, 0.14, 0.18, 1},
    btnBorder   = {0.35, 0.35, 0.40, 1},
    btnHover    = {0.20, 0.20, 0.25, 1},
    btnPress    = {0.06, 0.06, 0.08, 1},
    btnDisBg    = {0.08, 0.08, 0.10, 0.5},
    btnDisBdr   = {0.20, 0.20, 0.24, 0.5},
    inputBg     = {0.10, 0.10, 0.14, 1},
    inputBdr    = {0.40, 0.40, 0.45, 1},
    inputFocus  = {0.20, 0.60, 1.00, 1},
    ddBg        = {0.50, 0.50, 0.55, 1},
    ddBdr       = {0.65, 0.65, 0.70, 1},
    text        = {0.85, 0.85, 0.90, 1},
    textDim     = {0.45, 0.45, 0.50, 1},
    textAccent  = {0.20, 0.70, 1.00, 1},
    listBg      = {0.04, 0.04, 0.06, 0.8},
    listHover   = {0.20, 0.50, 0.80, 0.3},
    tabActiveBg = {0.10, 0.10, 0.14, 1},
    tabActiveBdr= {0.20, 0.55, 1.00, 1},
}

-- ============================================
-- 辅助函数
-- ============================================

-- 全局弹出框管理器，确保同时只能打开一个
local allPopups = {}
local function RegisterPopup(frame)
    allPopups[frame] = true
end
local function CloseAllPopups(except)
    for f in pairs(allPopups) do
        if f ~= except and f:IsShown() then
            f:Hide()
        end
    end
end

-- 全局下拉菜单状态追踪器，解决多处 HookScript("OnHide") 互相干扰的问题
local activeMenuID = nil
local activeMenuBtn = nil

local function OpenMenu(menuID, btn, menuFrame)
    if activeMenuID == menuID then
        CloseDropDownMenus()
        activeMenuID = nil
        activeMenuBtn = nil
    else
        activeMenuID = menuID
        activeMenuBtn = btn
        ToggleDropDownMenu(1, nil, menuFrame, btn, 0, 0)
    end
end

-- 只注册一次全局 OnHide
local ddHookRegistered = false
local function RegisterDDOnHide()
    if ddHookRegistered then return end
    ddHookRegistered = true
    DropDownList1:HookScript("OnHide", function()
        if activeMenuBtn and not activeMenuBtn:IsMouseOver() then
            activeMenuID = nil
            activeMenuBtn = nil
        end
    end)
end

-- 创建关闭按钮（X按钮）
local function CreateCloseButton(parent, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(18, 18)
    btn:SetPoint("TOPRIGHT", -4, -4)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(0.12, 0.12, 0.15, 1)
    btn:SetBackdropBorderColor(0.28, 0.28, 0.32, 1)
    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txt:SetAllPoints()
    txt:SetText("X")
    btn:SetFontString(txt)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.7, 0.1, 0.1, 1)
        self:SetBackdropBorderColor(0.9, 0.2, 0.2, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.12, 0.12, 0.15, 1)
        self:SetBackdropBorderColor(0.28, 0.28, 0.32, 1)
    end)
    btn:SetScript("OnClick", onClick)
    return btn
end

-- 安全调用：确保参数为数字才执行
local function SafeCall(func, ...)
    local args = {...}
    for i = 1, #args do
        if type(args[i]) ~= "number" then return end
    end
    func(...)
end

-- 安静调用：抑制函数执行时的 info 输出（如 Customizations）
local function SilentCall(func, ...)
    -- hook 所有聊天帧的 AddMessage
    local hooked = {}
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame and frame.AddMessage then
            hooked[i] = frame.AddMessage
            frame.AddMessage = function() end
        end
    end
    local ok, err = pcall(func, ...)
    -- 恢复所有聊天帧
    for i, orig in pairs(hooked) do
        local frame = _G["ChatFrame" .. i]
        if frame then frame.AddMessage = orig end
    end
    if not ok then DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. tostring(err) .. "|r") end
end

-- 创建 Tooltip
local function SetupTooltip(widget, text)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(text, 1, 1, 1)
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

-- ============================================
-- 现代UI组件工厂
-- ============================================

local function CreateModernButton(name, parent, width, height, text)
    local btn = CreateFrame("Button", name, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(unpack(T.btnBg))
    btn:SetBackdropBorderColor(unpack(T.btnBorder))

    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetAllPoints()
    btn:SetFontString(fs)
    btn:SetText(text)
    btn:SetNormalFontObject("GameFontNormal")
    btn:SetHighlightFontObject("GameFontHighlight")
    btn:SetDisabledFontObject("GameFontDisable")

    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(unpack(T.btnHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(unpack(T.btnBg))
            self:SetBackdropBorderColor(unpack(T.btnBorder))
        end
    end)
    btn:SetScript("OnDisable", function(self)
        self:SetBackdropColor(unpack(T.btnDisBg))
        self:SetBackdropBorderColor(unpack(T.btnDisBdr))
    end)
    btn:SetScript("OnEnable", function(self)
        self:SetBackdropColor(unpack(T.btnBg))
        self:SetBackdropBorderColor(unpack(T.btnBorder))
    end)

    return btn
end

local function CreateModernEditBox(name, parent, width, height)
    local editBox = CreateFrame("EditBox", name, parent, "BackdropTemplate")
    editBox:SetSize(width, height)
    editBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    editBox:SetBackdropColor(unpack(T.inputBg))
    editBox:SetBackdropBorderColor(unpack(T.inputBdr))
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetTextInsets(6, 6, 0, 0)

    editBox:SetScript("OnEscapePressed", EditBox_ClearFocus)
    editBox:SetScript("OnEditFocusGained", function(self)
        EditBox_HighlightText(self)
        self:SetBackdropBorderColor(unpack(T.inputFocus))
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        EditBox_ClearHighlight(self)
        self:SetBackdropBorderColor(unpack(T.inputBdr))
    end)

    return editBox
end

-- 美化下拉菜单（反色+着色）
local function StyleDropdown(frame)
    local name = frame:GetName()
    if not name then return end

    for _, region in ipairs({frame:GetRegions()}) do
        if region:IsObjectType("Texture") then
            region:SetDesaturated(true)
            region:SetVertexColor(unpack(T.ddBg))
        end
    end

    local text = _G[name .. "Text"]
    if text then text:SetTextColor(unpack(T.text)) end

    local button = _G[name .. "Button"]
    if button then
        for _, region in ipairs({button:GetRegions()}) do
            if region:IsObjectType("Texture") then
                region:SetDesaturated(true)
                region:SetVertexColor(0.50, 0.50, 0.55, 1)
            end
        end
        button:SetScript("OnEnter", function(self)
            for _, region in ipairs({self:GetRegions()}) do
                if region:IsObjectType("Texture") then
                    region:SetVertexColor(unpack(T.accent))
                end
            end
        end)
        button:SetScript("OnLeave", function(self)
            for _, region in ipairs({self:GetRegions()}) do
                if region:IsObjectType("Texture") then
                    region:SetVertexColor(0.50, 0.50, 0.55, 1)
                end
            end
        end)
    end

    local label = _G[name .. "Label"]
    if label then label:SetTextColor(unpack(T.textDim)) end
end

-- 美化滑块
local function StyleSlider(slider)
    local name = slider:GetName()
    if not name then return end

    for _, childName in ipairs({"Top", "Middle", "Bottom"}) do
        local child = _G[name .. childName]
        if child then
            child:SetDesaturated(true)
            child:SetVertexColor(0.12, 0.12, 0.15, 1)
        end
    end

    local thumb = _G[name .. "Thumb"]
    if thumb then
        thumb:SetDesaturated(true)
        thumb:SetVertexColor(unpack(T.accent))
    end

    local low = _G[name .. "Low"]
    local high = _G[name .. "High"]
    if low then low:SetTextColor(unpack(T.textDim)) end
    if high then high:SetTextColor(unpack(T.textDim)) end

    local label = _G[name .. "Text"]
    if label then label:SetTextColor(unpack(T.text)) end
end

-- 通用缩放滑块
local function CreateScaleSlider(name, parent, prevWidget, label, onSave, offsetX)
    offsetX = offsetX or 0
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", prevWidget, "BOTTOMLEFT", offsetX, -18)
    slider:SetMinMaxValues(0.5, 3.0)
    slider:SetValueStep(0.1)
    slider:SetValue(1.0)
    slider:SetWidth(330)
    slider.text = _G[slider:GetName() .. "Text"]
    slider.text:SetText(label .. ": 1.00")
    slider.text:SetTextColor(unpack(T.text))
    _G[slider:GetName() .. "Low"]:SetText("缩小")
    _G[slider:GetName() .. "High"]:SetText("放大")
    StyleSlider(slider)
    slider:SetScript("OnValueChanged", function(self)
        local scale = self:GetValue()
        self.text:SetText(format("%s: %.2f", label, scale))
        onSave(scale)
    end)
    return slider
end

-- 创建标题栏（可拖拽）
local function CreateTitleBar(parent, title, onClose)
    local titleBar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    titleBar:SetHeight(28)
    titleBar:SetPoint("TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", -1, -1)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    titleBar:SetBackdropColor(unpack(T.titleBg))
    titleBar:SetBackdropBorderColor(unpack(T.titleBorder))
    titleBar:EnableMouse(true)
    titleBar:SetScript("OnMouseDown", function() parent:StartMoving() end)
    titleBar:SetScript("OnMouseUp", function() parent:StopMovingOrSizing() end)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(title)

    local closeBtn = CreateCloseButton(titleBar, onClose)
    closeBtn:SetSize(20, 20)

    return titleBar
end

-- 创建"选择+手动输入"行（角色/宠物共用）
local function CreateSelectRow(parent, prevWidget, config)
    local selectBtn = CreateModernButton(config.selectName, parent, 121, 28, config.selectLabel)
    selectBtn:SetPoint("TOPLEFT", prevWidget, "BOTTOMLEFT", config.offsetX or 0, config.offsetY or -3)
    SetupTooltip(selectBtn, config.selectTooltip)

    local menuFrame = CreateFrame("Frame", config.menuName, parent, "UIDropDownMenuTemplate")
    menuFrame:Hide()

    local function OnMenuSelect(button)
        SafeCall(config.onSelect, button.value)
    end

    UIDropDownMenu_Initialize(menuFrame, function(self)
        local info = UIDropDownMenu_CreateInfo()
        for _, name in ipairs(config.order) do
            local id = config.data[name]
            if id then
                info.text = name
                info.value = id
                info.notCheckable = true
                info.func = OnMenuSelect
                UIDropDownMenu_AddButton(info)
            end
        end
    end)

    local menuID = config.menuName
    RegisterDDOnHide()

    selectBtn:SetScript("OnClick", function(self)
        OpenMenu(menuID, self, menuFrame)
    end)

    local editBox = CreateModernEditBox(config.editBoxName, parent, config.editBoxSize or 85, 28)
    editBox:SetPoint("LEFT", selectBtn, "RIGHT", 6, 0)
    editBox:SetText(iMorphToolsDBC[config.editBoxSavedVar] or config.editBoxDefault)
    editBox:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC[config.editBoxSavedVar] = self:GetText()
    end)

    local manualBtn = CreateModernButton(config.manualName, parent, 121, 28, config.manualLabel)
    manualBtn:SetPoint("LEFT", editBox, "RIGHT", 4, 0)
    SetupTooltip(manualBtn, config.manualTooltip)

    manualBtn:SetScript("OnClick", function()
        local inputID = tonumber(editBox:GetText())
        if inputID then
            config.onManual(inputID)
        end
    end)

    return selectBtn, editBox, manualBtn, menuFrame
end

-- 分隔线装饰
local function CreateSeparator(parent, anchorWidget)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 5, -2)
    sep:SetPoint("TOPRIGHT", anchorWidget, "BOTTOMRIGHT", -5, -2)
    sep:SetColorTexture(0.20, 0.55, 1.00, 0.25)
    return sep
end

-- ============================================
-- 各功能区块构建函数
-- ============================================

local function BuildResetSection(mainFrame)
    local resetBtn = CreateModernButton(nil, mainFrame, 330, 25, "重置初始模型")
    resetBtn:SetPoint("TOP", mainFrame, "TOP", 0, -32)
    resetBtn:SetScript("OnClick", ResetIds)
    CreateSeparator(mainFrame, resetBtn)
    return resetBtn
end

local function BuildCmdSection(mainFrame, preWidget)
    local cmdBtn = CreateModernButton("CmdBtn", mainFrame, 330, 25, "便捷改模指令集")
    cmdBtn:SetPoint("TOP", preWidget, "BOTTOM", 0, -5)
    SetupTooltip(cmdBtn, "点击选择需要执行的改模指令\n选中后立即生效")

    local cmdMenu = CreateFrame("Frame", "CmdMenu", mainFrame, "UIDropDownMenuTemplate")
    cmdMenu:Hide()

    UIDropDownMenu_Initialize(cmdMenu, function(self)
        local info = UIDropDownMenu_CreateInfo()
        for _, cmdName in ipairs(IMT.CmdOrder) do
            if IMT.CmdSets[cmdName] then
                info.text = cmdName
                info.notCheckable = true
                info.func = function() IMT.CmdSets[cmdName]() end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)

    RegisterDDOnHide()

    cmdBtn:SetScript("OnClick", function(self)
        OpenMenu("CmdMenu", self, cmdMenu)
    end)
    return cmdBtn
end

local function BuildSetSection(mainFrame, preWidget)
    local savedSetText = iMorphToolsDBC.EditBox2Text or ""
    local editBox2 = CreateModernEditBox("editBox2", mainFrame, 165, 28)
    editBox2:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 10, -3)
    editBox2:SetText(savedSetText)

    local buttonSetChange = CreateModernButton("buttonSetChange", mainFrame, 125, 28, "修改套装")
    buttonSetChange:SetPoint("LEFT", editBox2, "RIGHT", 30, 0)
    SetupTooltip(buttonSetChange, "编辑框直接输入DKT3、QST6，PVP系列仅采集了S1，T9系列分BL/LM（例\"QSLMT9\"）。也可自行查询编号手动输入")

    buttonSetChange:SetScript("OnClick", function()
        local inputText = editBox2:GetText()
        local setId = tonumber(inputText) or IMT.SetMapping[inputText:upper()]
        if setId then SetItemSet(setId) end
        iMorphToolsDBC.EditBox2Text = inputText
    end)
    return editBox2
end

local function BuildModelSection(mainFrame, preWidget)
    local selectModelBtn = CreateSelectRow(mainFrame, preWidget, {
        selectName = "SelectModelBtn", selectLabel = "点击角色改模",
        selectTooltip = "点击选择模型直接生效",
        menuName = "ModelSelectMenu",
        data = IMT.ModelIDs, order = IMT.ModelOrder,
        onSelect = Morph,
        editBoxName = "editBox8", editBoxDefault = "7550",
        editBoxSavedVar = "ModelID",
        manualName = "buttonModelChange", manualLabel = "手动角色改模",
        manualTooltip = "输入模型ID后点击修改",
        onManual = Morph,
        offsetX = -17,
    })
    return selectModelBtn
end

local function BuildPetSection(mainFrame, preWidget)
    local selectPetBtn = CreateSelectRow(mainFrame, preWidget, {
        selectName = "SelectPetBtn", selectLabel = "点击宠物改模",
        selectTooltip = "点击选择宠物模型直接生效",
        menuName = "PetSelectMenu",
        data = IMT.PetIDs, order = IMT.PetOrder,
        onSelect = MorphPet,
        editBoxName = "editBox9", editBoxDefault = "21974",
        editBoxSavedVar = "PetModelID",
        manualName = "buttonPetChange", manualLabel = "手动宠物改模",
        manualTooltip = "输入宠物模型ID后点击修改",
        onManual = MorphPet,
    })
    return selectPetBtn
end

local function BuildMountSection(mainFrame, preWidget)
    local selectMountBtn = CreateModernButton("SelectMountBtn", mainFrame, 121, 28, "点击坐骑改模")
    selectMountBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
    SetupTooltip(selectMountBtn, "点击打开坐骑选择列表")

    -- 坐骑选择弹出框
    local mountFrame = CreateFrame("Frame", "IMTMountFrame", UIParent, "BackdropTemplate")
    RegisterPopup(mountFrame)
    mountFrame:SetSize(320, 460)
    mountFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    mountFrame:SetBackdropColor(unpack(T.bg))
    mountFrame:SetBackdropBorderColor(unpack(T.border))
    mountFrame:EnableMouse(true)
    mountFrame:SetMovable(true)
    mountFrame:RegisterForDrag("LeftButton")
    mountFrame:SetScript("OnDragStart", mountFrame.StartMoving)
    mountFrame:SetScript("OnDragStop", mountFrame.StopMovingOrSizing)
    mountFrame:SetFrameStrata("DIALOG")
    mountFrame:Hide()

    CreateTitleBar(mountFrame, "|cff3399FF坐骑改模|r", function() mountFrame:Hide() end)

    local MOUNT_BTN_H = 22
    local MOUNT_BTN_W = 275
    local MOUNT_TAB_TOP = -30
    local MOUNT_LIST_TOP = -56
    local MOUNT_LIST_BOTTOM = 12
    local MOUNT_VISIBLE = math.floor((460 + MOUNT_LIST_TOP - MOUNT_LIST_BOTTOM) / MOUNT_BTN_H)

    local mountSelectedGroup = IMT.MountGroups[1] and IMT.MountGroups[1][1] or ""
    local mountScrollOffset = 0

    local IMTMountScrollFrame_Update

    -- 滚动条
    local mountSlider = CreateFrame("Slider", "IMTMountSlider", mountFrame, "BackdropTemplate")
    mountSlider:SetPoint("TOPRIGHT", -14, MOUNT_LIST_TOP + 10)
    mountSlider:SetPoint("BOTTOMRIGHT", -14, MOUNT_LIST_BOTTOM + 10)
    mountSlider:SetWidth(12)
    mountSlider:SetOrientation("VERTICAL")
    mountSlider:SetMinMaxValues(0, 0)
    mountSlider:SetValueStep(1)
    mountSlider:SetObeyStepOnDrag(true)
    mountSlider:SetValue(0)
    mountSlider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    mountSlider:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
    mountSlider:SetBackdropBorderColor(0.20, 0.20, 0.24, 0.6)
    mountSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
    local thumb = mountSlider:GetThumbTexture()
    thumb:SetSize(10, 30)
    thumb:SetColorTexture(unpack(T.accent))

    -- 上/下滚动按钮（共享样式创建）
    local function CreateScrollButton(pointParent, pointFrom, pointTo, offsetY, arrowChar, onScroll)
        local btn = CreateFrame("Button", nil, mountFrame, "BackdropTemplate")
        btn:SetSize(12, 12)
        btn:SetPoint(pointFrom, pointParent, pointTo, 0, offsetY)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(0.14, 0.14, 0.18, 1)
        btn:SetBackdropBorderColor(0.35, 0.35, 0.40, 1)
        local arrow = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        arrow:SetPoint("CENTER")
        arrow:SetText(arrowChar)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.35, 0.35, 0.40, 1)
        end)
        btn:SetScript("OnClick", onScroll)
        return btn
    end

    CreateScrollButton(mountSlider, "BOTTOM", "TOP", 2, "▲", function()
        local newVal = math.max(0, mountScrollOffset - 3)
        if newVal ~= mountScrollOffset then
            mountScrollOffset = newVal
            IMTMountScrollFrame_Update()
        end
    end)

    CreateScrollButton(mountSlider, "TOP", "BOTTOM", -2, "▼", function()
        local _, maxVal = mountSlider:GetMinMaxValues()
        local newVal = math.min(maxVal, mountScrollOffset + 3)
        if newVal ~= mountScrollOffset then
            mountScrollOffset = newVal
            IMTMountScrollFrame_Update()
        end
    end)

    -- 按钮池
    mountSlider.buttonPool = {}
    for i = 1, MOUNT_VISIBLE do
        local btn = CreateFrame("Button", nil, mountFrame, "BackdropTemplate")
        btn:SetSize(MOUNT_BTN_W, MOUNT_BTN_H)
        btn:SetPoint("TOPLEFT", 12, MOUNT_LIST_TOP - (i - 1) * MOUNT_BTN_H)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.listBg))
        btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        btn:EnableMouseWheel(true)

        local fontStr = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fontStr:SetAllPoints()
        fontStr:SetJustifyH("LEFT")
        fontStr:SetPoint("LEFT", 6, 0)
        btn:SetFontString(fontStr)
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(T.listHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(T.listBg))
            self:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        end)
        btn:SetScript("OnMouseWheel", function(self, delta)
            mountFrame:GetScript("OnMouseWheel")(mountFrame, delta)
        end)
        btn:SetScript("OnClick", function(self)
            if self.mountID then
                SafeCall(SetMount, self.mountID)
            end
        end)
        mountSlider.buttonPool[i] = btn
    end

    -- 核心刷新函数
    IMTMountScrollFrame_Update = function()
        local groupData
        for _, g in ipairs(IMT.MountGroups) do
            if g[1] == mountSelectedGroup then groupData = g[2]; break end
        end
        local count = groupData and #groupData or 0
        local maxScroll = math.max(0, count - MOUNT_VISIBLE)
        mountSlider:SetMinMaxValues(0, maxScroll)
        if mountScrollOffset > maxScroll then
            mountScrollOffset = maxScroll
        end
        mountSlider:SetValue(mountScrollOffset)
        for i = 1, MOUNT_VISIBLE do
            local btn = mountSlider.buttonPool[i]
            local idx = mountScrollOffset + i
            if idx <= count then
                btn:SetText(groupData[idx][1])
                btn.mountID = groupData[idx][2]
                btn:SetBackdropColor(unpack(T.listBg))
                btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
                btn:Show()
            else
                btn:Hide()
            end
        end
    end

    mountSlider:SetScript("OnValueChanged", function(self, value)
        mountScrollOffset = math.floor(value + 0.5)
        IMTMountScrollFrame_Update()
    end)

    mountFrame:SetScript("OnMouseWheel", function(self, delta)
        local _, maxVal = mountSlider:GetMinMaxValues()
        local newVal = math.max(0, math.min(maxVal, mountScrollOffset - delta))
        if newVal ~= mountScrollOffset then
            mountScrollOffset = newVal
            IMTMountScrollFrame_Update()
        end
    end)

    -- 标签按钮
    local mountTabBtns = {}
    local function SetMountTabActive(activeTab)
        for _, t in ipairs(mountTabBtns) do
            if t == activeTab then
                t.isActive = true
                t:SetBackdropColor(unpack(T.tabActiveBg))
                t:SetBackdropBorderColor(unpack(T.tabActiveBdr))
                t:GetFontString():SetTextColor(unpack(T.textAccent))
            else
                t.isActive = false
                t:SetBackdropColor(unpack(T.btnBg))
                t:SetBackdropBorderColor(unpack(T.btnBorder))
                t:GetFontString():SetTextColor(1, 0.85, 0, 1)
            end
        end
    end
    for gi, group in ipairs(IMT.MountGroups) do
        local tab = CreateModernButton(nil, mountFrame, 55, 20, group[1])
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetHighlightFontObject("GameFontHighlightSmall")
        local prevTab = mountTabBtns[#mountTabBtns]
        if prevTab then
            tab:SetPoint("TOPLEFT", prevTab, "TOPRIGHT", 2, 0)
        else
            tab:SetPoint("TOPLEFT", 10, MOUNT_TAB_TOP)
        end
        tab:SetScript("OnClick", function()
            mountSelectedGroup = group[1]
            mountScrollOffset = 0
            SetMountTabActive(tab)
            IMTMountScrollFrame_Update()
            C_Timer.After(0, IMTMountScrollFrame_Update)
        end)
        if group[1] == mountSelectedGroup then
            tab.isActive = true
            tab:SetBackdropColor(unpack(T.tabActiveBg))
            tab:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            tab:GetFontString():SetTextColor(unpack(T.textAccent))
        end
        -- 覆盖 OnEnter/OnLeave 避免覆盖选中样式
        tab:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(unpack(T.btnHover))
                self:SetBackdropBorderColor(unpack(T.accent))
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropColor(unpack(T.tabActiveBg))
                self:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            else
                self:SetBackdropColor(unpack(T.btnBg))
                self:SetBackdropBorderColor(unpack(T.btnBorder))
            end
        end)
        mountTabBtns[#mountTabBtns + 1] = tab
    end

    selectMountBtn:SetScript("OnClick", function(self)
        if mountFrame:IsShown() then
            mountFrame:Hide()
        else
            mountFrame:ClearAllPoints()
            mountFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            mountScrollOffset = 0
            IMTMountScrollFrame_Update()
            CloseAllPopups(mountFrame)
            mountFrame:Show()
        end
    end)

    local editBoxMount = CreateModernEditBox("editBox3", mainFrame, 85, 28)
    editBoxMount:SetPoint("LEFT", selectMountBtn, "RIGHT", 6, 0)
    editBoxMount:SetText(iMorphToolsDBC.MountModelID or "21974")
    editBoxMount:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.MountModelID = self:GetText()
    end)

    local manualMountBtn = CreateModernButton("buttonMountChange", mainFrame, 121, 28, "手动坐骑改模")
    manualMountBtn:SetPoint("LEFT", editBoxMount, "RIGHT", 4, 0)
    SetupTooltip(manualMountBtn, "输入坐骑模型ID后点击修改")

    manualMountBtn:SetScript("OnClick", function()
        local inputID = tonumber(editBoxMount:GetText())
        if inputID then
            SetMount(inputID)
        end
    end)

    return selectMountBtn
end

local function BuildRaceSection(mainFrame, preWidget)
    local selectRaceBtn = CreateModernButton("SelectRaceBtn", mainFrame, 170, 28, "点击修改种族模型")
    selectRaceBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
    SetupTooltip(selectRaceBtn, "点击选择种族直接生效")

    local raceMenu = CreateFrame("Frame", "RaceSelectMenu", mainFrame, "UIDropDownMenuTemplate")
    raceMenu:Hide()

    UIDropDownMenu_Initialize(raceMenu, function(self)
        local info = UIDropDownMenu_CreateInfo()
        for _, raceName in ipairs(IMT.RaceOrder) do
            local raceID = IMT.RaceOptions[raceName]
            if raceID then
                info.text = raceName
                info.value = raceName
                info.notCheckable = true
                info.func = function(button)
                    SafeCall(function(id) SetRace(id); SilentCall(Customizations) end, IMT.RaceOptions[button.value])
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)

    selectRaceBtn:SetScript("OnClick", function(self)
        OpenMenu("RaceSelectMenu", self, raceMenu)
    end)

    -- 变性按钮
    local buttonGenderChange = CreateModernButton("buttonGenderChange", mainFrame, 160, 28, "变性")
    buttonGenderChange:SetPoint("LEFT", selectRaceBtn, "RIGHT", 6, 0)
    SetupTooltip(buttonGenderChange, "点击改变角色性别")
    buttonGenderChange:SetScript("OnClick", function()
        SetGender()
        SilentCall(Customizations)
    end)

    return selectRaceBtn
end

local function BuildShapeshiftSection(mainFrame, preWidget)
    local savedShapeshiftSelection = iMorphToolsDBC.shapeshiftSelection or "猎豹形态"
    local selectedShapeshiftID = IMT.ShapeshiftIDs[savedShapeshiftSelection]
    local selectedShapeshiftName = savedShapeshiftSelection

    local dropdownShapeshifts = CreateFrame("Frame", "WPDemoDropdownShapeshifts", mainFrame, "UIDropDownMenuTemplate")
    dropdownShapeshifts:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -17, -3)
    UIDropDownMenu_SetWidth(dropdownShapeshifts, 100)
    UIDropDownMenu_SetText(dropdownShapeshifts, "变形形态")
    StyleDropdown(dropdownShapeshifts)

    UIDropDownMenu_Initialize(dropdownShapeshifts, function(self, level)
        if level ~= 1 then return end
        local info = UIDropDownMenu_CreateInfo()
        for _, name in ipairs(IMT.ShapeshiftOrder) do
            local id = IMT.ShapeshiftIDs[name]
            if id then
                info.text = name
                info.value = id
                info.checked = (id == selectedShapeshiftID)
                info.func = function()
                    selectedShapeshiftID = id
                    selectedShapeshiftName = name
                    iMorphToolsDBC.shapeshiftSelection = name
                    UIDropDownMenu_SetText(dropdownShapeshifts, name)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)
    UIDropDownMenu_SetText(dropdownShapeshifts, selectedShapeshiftName or "猎豹形态")

    -- 形态模型下拉
    local savedShapeshiftModelSelection = iMorphToolsDBC.ShapeshiftModelSelection or "幽灵虎"
    local selectedShapeshiftModelID = IMT.ShapeshiftModelIDs[savedShapeshiftModelSelection]
    local selectedShapeshiftModelName = savedShapeshiftModelSelection

    local dropdownShapeshiftModels = CreateFrame("Frame", "WPDemoDropdownShapeshiftModels", mainFrame, "UIDropDownMenuTemplate")
    dropdownShapeshiftModels:SetPoint("LEFT", dropdownShapeshifts, "RIGHT", -30, 0)
    UIDropDownMenu_SetWidth(dropdownShapeshiftModels, 85)
    UIDropDownMenu_SetText(dropdownShapeshiftModels, "形态模型")
    StyleDropdown(dropdownShapeshiftModels)

    UIDropDownMenu_Initialize(dropdownShapeshiftModels, function(self, level)
        if level ~= 1 then return end
        local info = UIDropDownMenu_CreateInfo()
        for _, name in ipairs(IMT.ShapeshiftModelOrder) do
            local id = IMT.ShapeshiftModelIDs[name]
            if id then
                info.text = name
                info.value = id
                info.checked = (id == selectedShapeshiftModelID)
                info.func = function()
                    selectedShapeshiftModelID = id
                    selectedShapeshiftModelName = name
                    iMorphToolsDBC.ShapeshiftModelSelection = name
                    UIDropDownMenu_SetText(dropdownShapeshiftModels, name)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
        -- 手动输入选项
        info.text = "手动输入"
        info.value = nil
        info.checked = (selectedShapeshiftModelName == "手动输入")
        info.func = function()
            selectedShapeshiftModelID = nil
            selectedShapeshiftModelName = "手动输入"
            iMorphToolsDBC.ShapeshiftModelSelection = "手动输入"
            UIDropDownMenu_SetText(dropdownShapeshiftModels, "手输")
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetText(dropdownShapeshiftModels, selectedShapeshiftModelName or "幽灵虎")

    local editBox10 = CreateModernEditBox("editBox10", mainFrame, 45, 28)
    editBox10:SetPoint("LEFT", dropdownShapeshiftModels, "RIGHT", -8, 0)
    editBox10:SetText(iMorphToolsDBC.ShapeshiftModelID or "21974")
    editBox10:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.ShapeshiftModelID = self:GetText()
    end)

    local buttonShapeshiftChange = CreateModernButton("buttonShapeshiftChange", mainFrame, 65, 28, "改形态")
    buttonShapeshiftChange:SetPoint("LEFT", editBox10, "RIGHT", 4, 0)
    SetupTooltip(buttonShapeshiftChange, "选择形态和形态模型，点击修改")

    buttonShapeshiftChange:SetScript("OnClick", function()
        local morphID = selectedShapeshiftModelID or tonumber(editBox10:GetText())
        if selectedShapeshiftID and morphID then
            SetShapeshiftForm(selectedShapeshiftID, morphID)
        end
    end)

    return dropdownShapeshifts
end

local function BuildScaleSection(mainFrame, preWidget)
    local modelSlider = CreateScaleSlider("scaleSlider", mainFrame, preWidget, "模型缩放", SetScale, 17)
    local petSlider = CreateScaleSlider("petScaleSlider", mainFrame, modelSlider, "宠物缩放", SetScalePet)
    return petSlider
end

local function BuildItemSection(mainFrame, preWidget)
    local selectedSlotID = iMorphToolsDBC.selectedSlotID or 1

    local dropDown = CreateFrame("Frame", "WPDemoDropDown2", mainFrame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -18, -14)
    UIDropDownMenu_SetWidth(dropDown, 150)
    StyleDropdown(dropDown)

    UIDropDownMenu_Initialize(dropDown, function(self, level)
        if level ~= 1 then return end
        local info = UIDropDownMenu_CreateInfo()
        for _, slotID in ipairs(IMT.SlotOrder) do
            local slotName = IMT.SlotIDs[slotID]
            if slotName then
                info.text = slotName
                info.value = slotID
                info.checked = (slotID == selectedSlotID)
                info.func = function()
                    selectedSlotID = slotID
                    iMorphToolsDBC.selectedSlotID = slotID
                    UIDropDownMenu_SetText(dropDown, "栏位: " .. slotName)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)
    UIDropDownMenu_SetText(dropDown, "栏位: " .. (IMT.SlotIDs[selectedSlotID] or "未知栏位"))

    local textFrame = CreateModernEditBox("WPDemoTextFrame", mainFrame, 85, 28)
    textFrame:SetPoint("LEFT", dropDown, "RIGHT", -8, 0)
    textFrame:SetText(iMorphToolsDBC.modelID or "物品编号")
    textFrame:SetScript("OnTextChanged", function()
        iMorphToolsDBC.modelID = textFrame:GetText()
    end)

    local buttonFrame = CreateModernButton("WPDemoButtonFrame", mainFrame, 75, 28, "改装备")
    buttonFrame:SetPoint("LEFT", textFrame, "RIGHT", 4, 0)
    SetupTooltip(buttonFrame, "选择装备栏位然后在编辑框填写物品ID，点击修改")

    buttonFrame:SetScript("OnClick", function()
        local itemID = tonumber(textFrame:GetText())
        if selectedSlotID and itemID then
            SetItem(selectedSlotID, itemID)
        end
    end)
    return dropDown
end

local function BuildEnchantSection(mainFrame, preWidget)
    local selectEnchantBtn = CreateModernButton("SelectEnchantBtn", mainFrame, 100, 28, "武器附魔")
    selectEnchantBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 20, -3)
    SetupTooltip(selectEnchantBtn, "点击打开附魔选择列表")

    -- 附魔选择弹出框
    local enchantFrame = CreateFrame("Frame", "IMTEnchantFrame", UIParent, "BackdropTemplate")
    RegisterPopup(enchantFrame)
    enchantFrame:SetSize(320, 460)
    enchantFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    enchantFrame:SetBackdropColor(unpack(T.bg))
    enchantFrame:SetBackdropBorderColor(unpack(T.border))
    enchantFrame:EnableMouse(true)
    enchantFrame:SetMovable(true)
    enchantFrame:RegisterForDrag("LeftButton")
    enchantFrame:SetScript("OnDragStart", enchantFrame.StartMoving)
    enchantFrame:SetScript("OnDragStop", enchantFrame.StopMovingOrSizing)
    enchantFrame:SetFrameStrata("DIALOG")
    enchantFrame:Hide()

    CreateTitleBar(enchantFrame, "|cff3399FF武器附魔|r", function() enchantFrame:Hide() end)

    local ENCHANT_BTN_H = 22
    local ENCHANT_BTN_W = 275
    local ENCHANT_TAB_TOP = -30
    local SLOT_BAR_TOP = -56
    local ENCHANT_LIST_TOP = -78
    local ENCHANT_LIST_BOTTOM = 12
    local ENCHANT_VISIBLE = math.floor((460 + ENCHANT_LIST_TOP - ENCHANT_LIST_BOTTOM) / ENCHANT_BTN_H)

    local enchantScrollOffset = 0
    local currentSlot = 16 -- 16=主手, 17=副手
    local enchantSelectedGroup = IMT.EnchantGroups[1] and IMT.EnchantGroups[1][1] or ""

    local IMTEnchantScrollFrame_Update

    -- 滚动条
    local enchantSlider = CreateFrame("Slider", "IMTEnchantSlider", enchantFrame, "BackdropTemplate")
    enchantSlider:SetPoint("TOPRIGHT", -14, ENCHANT_LIST_TOP + 10)
    enchantSlider:SetPoint("BOTTOMRIGHT", -14, ENCHANT_LIST_BOTTOM + 10)
    enchantSlider:SetWidth(12)
    enchantSlider:SetOrientation("VERTICAL")
    enchantSlider:SetMinMaxValues(0, 0)
    enchantSlider:SetValueStep(1)
    enchantSlider:SetObeyStepOnDrag(true)
    enchantSlider:SetValue(0)
    enchantSlider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    enchantSlider:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
    enchantSlider:SetBackdropBorderColor(0.20, 0.20, 0.24, 0.6)
    enchantSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
    local thumb = enchantSlider:GetThumbTexture()
    thumb:SetSize(10, 30)
    thumb:SetColorTexture(unpack(T.accent))

    -- 上/下滚动按钮
    local function CreateEnchantScrollButton(pointParent, pointFrom, pointTo, offsetY, arrowChar, onScroll)
        local btn = CreateFrame("Button", nil, enchantFrame, "BackdropTemplate")
        btn:SetSize(12, 12)
        btn:SetPoint(pointFrom, pointParent, pointTo, 0, offsetY)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.accent))
        btn:SetBackdropBorderColor(unpack(T.border))
        btn:SetNormalFontObject("GameFontNormalSmall")
        btn:SetHighlightFontObject("GameFontHighlightSmall")
        btn:SetText(arrowChar)
        btn:SetScript("OnClick", onScroll)
        return btn
    end

    CreateEnchantScrollButton(enchantSlider, "BOTTOM", "TOP", 2, "▲", function()
        local newVal = math.max(0, enchantScrollOffset - 3)
        if newVal ~= enchantScrollOffset then
            enchantScrollOffset = newVal
            IMTEnchantScrollFrame_Update()
        end
    end)

    CreateEnchantScrollButton(enchantSlider, "TOP", "BOTTOM", -2, "▼", function()
        local _, maxVal = enchantSlider:GetMinMaxValues()
        local newVal = math.min(maxVal, enchantScrollOffset + 3)
        if newVal ~= enchantScrollOffset then
            enchantScrollOffset = newVal
            IMTEnchantScrollFrame_Update()
        end
    end)

    -- 按钮池
    enchantSlider.buttonPool = {}
    for i = 1, ENCHANT_VISIBLE do
        local btn = CreateFrame("Button", nil, enchantFrame, "BackdropTemplate")
        btn:SetSize(ENCHANT_BTN_W, ENCHANT_BTN_H)
        btn:SetPoint("TOPLEFT", 12, ENCHANT_LIST_TOP - (i - 1) * ENCHANT_BTN_H)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.listBg))
        btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        btn:SetFontString(btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
        btn:GetFontString():SetAllPoints(btn)
        btn:GetFontString():SetJustifyH("LEFT")
        btn:GetFontString():SetPoint("LEFT", 8, 0)

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(T.listHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(T.listBg))
            self:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        end)
        btn:SetScript("OnMouseWheel", function(self, delta)
            enchantFrame:GetScript("OnMouseWheel")(enchantFrame, delta)
        end)
        btn:SetScript("OnClick", function(self)
            if self.enchantID then
                SafeCall(SetEnchant, currentSlot, self.enchantID)
            end
        end)
        enchantSlider.buttonPool[i] = btn
    end

    -- 核心刷新函数
    IMTEnchantScrollFrame_Update = function()
        local groupData
        for _, g in ipairs(IMT.EnchantGroups) do
            if g[1] == enchantSelectedGroup then groupData = g[2]; break end
        end
        local count = groupData and #groupData or 0
        local maxScroll = math.max(0, count - ENCHANT_VISIBLE)
        enchantSlider:SetMinMaxValues(0, maxScroll)
        if enchantScrollOffset > maxScroll then
            enchantScrollOffset = maxScroll
        end
        enchantSlider:SetValue(enchantScrollOffset)
        for i = 1, ENCHANT_VISIBLE do
            local btn = enchantSlider.buttonPool[i]
            local idx = enchantScrollOffset + i
            if idx <= count then
                local def = groupData[idx]
                btn:SetText(def[1])
                btn.enchantID = def[2]
                btn:SetBackdropColor(unpack(T.listBg))
                btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
                btn:Show()
            else
                btn:Hide()
            end
        end
    end

    enchantSlider:SetScript("OnValueChanged", function(self, value)
        enchantScrollOffset = math.floor(value + 0.5)
        IMTEnchantScrollFrame_Update()
    end)

    enchantFrame:SetScript("OnMouseWheel", function(self, delta)
        local _, maxVal = enchantSlider:GetMinMaxValues()
        local newVal = math.max(0, math.min(maxVal, enchantScrollOffset - delta))
        if newVal ~= enchantScrollOffset then
            enchantScrollOffset = newVal
            IMTEnchantScrollFrame_Update()
        end
    end)

    -- 版本标签按钮
    local enchantTabBtns = {}
    local function SetEnchantTabActive(activeTab)
        for _, t in ipairs(enchantTabBtns) do
            if t == activeTab then
                t.isActive = true
                t:SetBackdropColor(unpack(T.tabActiveBg))
                t:SetBackdropBorderColor(unpack(T.tabActiveBdr))
                t:GetFontString():SetTextColor(unpack(T.textAccent))
            else
                t.isActive = false
                t:SetBackdropColor(unpack(T.btnBg))
                t:SetBackdropBorderColor(unpack(T.btnBorder))
                t:GetFontString():SetTextColor(1, 0.85, 0, 1)
            end
        end
    end
    for gi, group in ipairs(IMT.EnchantGroups) do
        local tab = CreateModernButton(nil, enchantFrame, 55, 20, group[1])
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetHighlightFontObject("GameFontHighlightSmall")
        local prevTab = enchantTabBtns[#enchantTabBtns]
        if prevTab then
            tab:SetPoint("TOPLEFT", prevTab, "TOPRIGHT", 2, 0)
        else
            tab:SetPoint("TOPLEFT", 10, ENCHANT_TAB_TOP)
        end
        tab:SetScript("OnClick", function()
            enchantSelectedGroup = group[1]
            enchantScrollOffset = 0
            SetEnchantTabActive(tab)
            IMTEnchantScrollFrame_Update()
            C_Timer.After(0, IMTEnchantScrollFrame_Update)
        end)
        if group[1] == enchantSelectedGroup then
            tab.isActive = true
            tab:SetBackdropColor(unpack(T.tabActiveBg))
            tab:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            tab:GetFontString():SetTextColor(unpack(T.textAccent))
        end
        tab:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(unpack(T.btnHover))
                self:SetBackdropBorderColor(unpack(T.accent))
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropColor(unpack(T.tabActiveBg))
                self:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            else
                self:SetBackdropColor(unpack(T.btnBg))
                self:SetBackdropBorderColor(unpack(T.btnBorder))
            end
        end)
        enchantTabBtns[#enchantTabBtns + 1] = tab
    end

    -- 主手/副手 切换按钮（版本标签下方）
    local slotBtns = {}
    local slotInfo = {{"主手", 16}, {"副手", 17}}
    local function SetSlotBtnActive(activeBtn)
        for _, t in ipairs(slotBtns) do
            if t == activeBtn then
                t.isActive = true
                t:SetBackdropColor(unpack(T.tabActiveBg))
                t:SetBackdropBorderColor(unpack(T.tabActiveBdr))
                t:GetFontString():SetTextColor(unpack(T.textAccent))
            else
                t.isActive = false
                t:SetBackdropColor(unpack(T.btnBg))
                t:SetBackdropBorderColor(unpack(T.btnBorder))
                t:GetFontString():SetTextColor(1, 0.85, 0, 1)
            end
        end
    end
    for _, info in ipairs(slotInfo) do
        local label, slot = info[1], info[2]
        local btn = CreateModernButton(nil, enchantFrame, 45, 18, label)
        btn:SetNormalFontObject("GameFontNormalSmall")
        btn:SetHighlightFontObject("GameFontHighlightSmall")
        local prevBtn = slotBtns[#slotBtns]
        if prevBtn then
            btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", 2, 0)
        else
            btn:SetPoint("TOPLEFT", 10, SLOT_BAR_TOP)
        end
        btn:SetScript("OnClick", function()
            currentSlot = slot
            SetSlotBtnActive(btn)
        end)
        if slot == currentSlot then
            btn.isActive = true
            btn:SetBackdropColor(unpack(T.tabActiveBg))
            btn:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            btn:GetFontString():SetTextColor(unpack(T.textAccent))
        end
        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(unpack(T.btnHover))
                self:SetBackdropBorderColor(unpack(T.accent))
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropColor(unpack(T.tabActiveBg))
                self:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            else
                self:SetBackdropColor(unpack(T.btnBg))
                self:SetBackdropBorderColor(unpack(T.btnBorder))
            end
        end)
        slotBtns[#slotBtns + 1] = btn
    end

    selectEnchantBtn:SetScript("OnClick", function(self)
        if enchantFrame:IsShown() then
            enchantFrame:Hide()
        else
            enchantFrame:ClearAllPoints()
            enchantFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            enchantScrollOffset = 0
            IMTEnchantScrollFrame_Update()
            CloseAllPopups(enchantFrame)
            enchantFrame:Show()
        end
    end)

    -- 手动输入ID
    local editBoxEnchant = CreateModernEditBox("editBoxEnchant", mainFrame, 85, 28)
    editBoxEnchant:SetPoint("LEFT", selectEnchantBtn, "RIGHT", 4, 0)
    editBoxEnchant:SetText(iMorphToolsDBC.enchantManualID or "0")
    editBoxEnchant:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.enchantManualID = self:GetText()
    end)

    local manualEnchantBtn = CreateModernButton("manualEnchantMH", mainFrame, 60, 28, "主手")
    manualEnchantBtn:SetPoint("LEFT", editBoxEnchant, "RIGHT", 4, 0)
    SetupTooltip(manualEnchantBtn, "输入附魔ID后点击修改主手")

    manualEnchantBtn:SetScript("OnClick", function()
        local inputID = tonumber(editBoxEnchant:GetText())
        if inputID then
            SafeCall(SetEnchant, 16, inputID)
        end
    end)

    local manualEnchantBtnOH = CreateModernButton("manualEnchantOH", mainFrame, 60, 28, "副手")
    manualEnchantBtnOH:SetPoint("LEFT", manualEnchantBtn, "RIGHT", 2, 0)
    SetupTooltip(manualEnchantBtnOH, "输入附魔ID后点击修改副手")

    manualEnchantBtnOH:SetScript("OnClick", function()
        local inputID = tonumber(editBoxEnchant:GetText())
        if inputID then
            SafeCall(SetEnchant, 17, inputID)
        end
    end)

    return selectEnchantBtn
end

local function BuildSpellSection(mainFrame, preWidget)
    local savedSelectedSpellName = iMorphToolsDBC.selectedSpellName or "神圣风暴"
    local savedEditBoxContent = iMorphToolsDBC.editBoxContent
    local savedDynamicSpellName = iMorphToolsDBC.dynamicSpellName
    local savedDynamicSpellID = iMorphToolsDBC.dynamicSpellID

    -- ============================================
    -- 动态法术按钮
    -- ============================================
    local dynamicSpellBtn = CreateModernButton("DynamicSpellBtn", mainFrame, 100, 28, savedDynamicSpellName or "动态选择法术")
    dynamicSpellBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -5)
    SetupTooltip(dynamicSpellBtn, "点击选择技能书中的法术")

    -- 动态法术弹出框
    local DYN_BTN_H = 22
    local DYN_BTN_W = 180
    local DYN_LIST_TOP = -36
    local DYN_LIST_BOTTOM = 12
    local DYN_MAX_VISIBLE = 12
    local DYN_FRAME_H = 36 + DYN_MAX_VISIBLE * DYN_BTN_H + 12

    local dynPopup = CreateFrame("Frame", "IMTDynSpellFrame", UIParent, "BackdropTemplate")
    RegisterPopup(dynPopup)
    dynPopup:SetSize(DYN_BTN_W + 30, DYN_FRAME_H)
    dynPopup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dynPopup:SetBackdropColor(unpack(T.bg))
    dynPopup:SetBackdropBorderColor(unpack(T.border))
    dynPopup:EnableMouse(true)
    dynPopup:SetMovable(true)
    dynPopup:RegisterForDrag("LeftButton")
    dynPopup:SetScript("OnDragStart", dynPopup.StartMoving)
    dynPopup:SetScript("OnDragStop", dynPopup.StopMovingOrSizing)
    dynPopup:SetFrameStrata("DIALOG")
    dynPopup:Hide()
    CreateTitleBar(dynPopup, "|cff3399FF动态选择法术|r", function() dynPopup:Hide() end)

    local dynScrollOffset = 0
    local dynSpellData = {}
    local dynBtnPool = {}

    -- 滚动条
    local dynSlider = CreateFrame("Slider", "IMTDynSpellSlider", dynPopup, "BackdropTemplate")
    dynSlider:SetPoint("TOPRIGHT", -8, DYN_LIST_TOP + 0)
    dynSlider:SetPoint("BOTTOMRIGHT", -8, DYN_LIST_BOTTOM + 0)
    dynSlider:SetWidth(12)
    dynSlider:SetOrientation("VERTICAL")
    dynSlider:SetMinMaxValues(0, 0)
    dynSlider:SetValueStep(1)
    dynSlider:SetObeyStepOnDrag(true)
    dynSlider:SetValue(0)
    dynSlider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dynSlider:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
    dynSlider:SetBackdropBorderColor(0.20, 0.20, 0.24, 0.6)
    dynSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
    local dynThumb = dynSlider:GetThumbTexture()
    dynThumb:SetSize(10, 30)
    dynThumb:SetColorTexture(unpack(T.accent))

    local function DynUpdateList()
        local count = #dynSpellData
        local maxScroll = math.max(0, count - DYN_MAX_VISIBLE)
        dynScrollOffset = math.min(dynScrollOffset, maxScroll)
        dynSlider:SetMinMaxValues(0, maxScroll)
        dynSlider:SetValue(dynScrollOffset)
        for i = 1, DYN_MAX_VISIBLE do
            local btn = dynBtnPool[i]
            local idx = dynScrollOffset + i
            if idx <= count then
                btn:SetText(dynSpellData[idx][1])
                btn.dataName = dynSpellData[idx][1]
                btn.dataID = dynSpellData[idx][2]
                btn:SetBackdropColor(unpack(T.listBg))
                btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
                btn:Show()
            else
                btn:Hide()
            end
        end
    end

    dynSlider:SetScript("OnValueChanged", function(self, value)
        dynScrollOffset = math.floor(value + 0.5)
        DynUpdateList()
    end)

    for i = 1, DYN_MAX_VISIBLE do
        local btn = CreateFrame("Button", nil, dynPopup, "BackdropTemplate")
        btn:SetSize(DYN_BTN_W, DYN_BTN_H)
        btn:SetPoint("TOPLEFT", 12, DYN_LIST_TOP - (i - 1) * DYN_BTN_H)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.listBg))
        btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        btn:SetFontString(btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
        btn:GetFontString():SetAllPoints(btn)
        btn:GetFontString():SetJustifyH("LEFT")
        btn:GetFontString():SetPoint("LEFT", 8, 0)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(T.listHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(T.listBg))
            self:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        end)
        btn:SetScript("OnMouseWheel", function(self, delta)
            local maxScroll = math.max(0, #dynSpellData - DYN_MAX_VISIBLE)
            local newVal = math.max(0, math.min(maxScroll, dynScrollOffset - delta))
            if newVal ~= dynScrollOffset then
                dynScrollOffset = newVal
                DynUpdateList()
            end
        end)
        btn:SetScript("OnClick", function(self)
            if self.dataID then
                savedDynamicSpellName = self.dataName
                savedDynamicSpellID = self.dataID
                iMorphToolsDBC.dynamicSpellName = self.dataName
                iMorphToolsDBC.dynamicSpellID = self.dataID
                dynamicSpellBtn:SetText(self.dataName)
                C_Timer.After(0, function() dynPopup:Hide() end)
            end
        end)
        btn:Hide()
        dynBtnPool[i] = btn
    end

    dynPopup:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = math.max(0, #dynSpellData - DYN_MAX_VISIBLE)
        local newVal = math.max(0, math.min(maxScroll, dynScrollOffset - delta))
        if newVal ~= dynScrollOffset then
            dynScrollOffset = newVal
            DynUpdateList()
        end
    end)

    local function RefreshDynamicSpells()
        dynSpellData = {}
        if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
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
                                table.insert(dynSpellData, {spellName, spellInfo.spellID})
                            end
                        end
                    end
                end
            end
        else
            local numTabs = GetNumSpellTabs()
            for tab = 1, numTabs do
                local name, _, offset, numSpells = GetSpellTabInfo(tab)
                if name and name ~= "综合" then
                    for i = offset + 1, offset + numSpells do
                        local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
                        if spellType == "SPELL" and spellID then
                            local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                            if spellName then
                                table.insert(dynSpellData, {spellName, spellID})
                            end
                        end
                    end
                end
            end
        end
    end

    dynamicSpellBtn:SetScript("OnClick", function(self)
        if dynPopup:IsShown() then
            dynPopup:Hide()
        else
            RefreshDynamicSpells()
            dynPopup:ClearAllPoints()
            dynPopup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            dynScrollOffset = 0
            DynUpdateList()
            CloseAllPopups(dynPopup)
            dynPopup:Show()
        end
    end)

    -- ============================================
    -- ID输入框 + 改技能按钮
    -- ============================================
    local editBox1 = CreateModernEditBox("editBox1", mainFrame, 50, 28)
    editBox1:SetPoint("LEFT", dynamicSpellBtn, "RIGHT", 4, 0)
    editBox1:SetText(savedEditBoxContent or "")

    local buttonSpellChange = CreateModernButton("buttonSpellChange", mainFrame, 80, 28, "》改技能》")
    buttonSpellChange:SetPoint("LEFT", editBox1, "RIGHT", 4, 0)
    SetupTooltip(buttonSpellChange, "技能显示效果修改：\n编辑框可填写触发类饰品，ID自己查询填入即可\n若编辑框填写了ID则忽略左侧选择框")

    -- ============================================
    -- 技能效果按钮（带标签分组）
    -- ============================================
    local spellEffectBtn = CreateModernButton("SpellEffectBtn", mainFrame, 90, 28, savedSelectedSpellName)
    spellEffectBtn:SetPoint("LEFT", buttonSpellChange, "RIGHT", 4, 0)
    SetupTooltip(spellEffectBtn, "点击选择技能效果")

    local spellFrame = CreateFrame("Frame", "IMTSpellFrame", UIParent, "BackdropTemplate")
    RegisterPopup(spellFrame)
    spellFrame:SetSize(320, 460)
    spellFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    spellFrame:SetBackdropColor(unpack(T.bg))
    spellFrame:SetBackdropBorderColor(unpack(T.border))
    spellFrame:EnableMouse(true)
    spellFrame:SetMovable(true)
    spellFrame:RegisterForDrag("LeftButton")
    spellFrame:SetScript("OnDragStart", spellFrame.StartMoving)
    spellFrame:SetScript("OnDragStop", spellFrame.StopMovingOrSizing)
    spellFrame:SetFrameStrata("DIALOG")
    spellFrame:Hide()
    CreateTitleBar(spellFrame, "|cff3399FF技能效果|r", function() spellFrame:Hide() end)

    local SPELL_BTN_H = 22
    local SPELL_BTN_W = 275
    local SPELL_TAB_TOP = -30
    local SPELL_TAB2_TOP = -52
    local SPELL_LIST_TOP = -74
    local SPELL_LIST_BOTTOM = 12
    local SPELL_VISIBLE = math.floor((460 + SPELL_LIST_TOP - SPELL_LIST_BOTTOM) / SPELL_BTN_H)

    local spellScrollOffset = 0
    local spellSelectedGroup = IMT.SpellGroups[1] and IMT.SpellGroups[1][1] or ""

    local IMTSpellScrollFrame_Update

    -- 滚动条
    local spellSlider = CreateFrame("Slider", "IMTSpellSlider", spellFrame, "BackdropTemplate")
    spellSlider:SetPoint("TOPRIGHT", -14, SPELL_LIST_TOP + 10)
    spellSlider:SetPoint("BOTTOMRIGHT", -14, SPELL_LIST_BOTTOM + 10)
    spellSlider:SetWidth(12)
    spellSlider:SetOrientation("VERTICAL")
    spellSlider:SetMinMaxValues(0, 0)
    spellSlider:SetValueStep(1)
    spellSlider:SetObeyStepOnDrag(true)
    spellSlider:SetValue(0)
    spellSlider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    spellSlider:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
    spellSlider:SetBackdropBorderColor(0.20, 0.20, 0.24, 0.6)
    spellSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
    local spellThumb = spellSlider:GetThumbTexture()
    spellThumb:SetSize(10, 30)
    spellThumb:SetColorTexture(unpack(T.accent))

    local function CreateSpellScrollBtn(pointParent, pointFrom, pointTo, offsetY, arrowChar, onScroll)
        local btn = CreateFrame("Button", nil, spellFrame, "BackdropTemplate")
        btn:SetSize(12, 12)
        btn:SetPoint(pointFrom, pointParent, pointTo, 0, offsetY)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.accent))
        btn:SetBackdropBorderColor(unpack(T.border))
        btn:SetNormalFontObject("GameFontNormalSmall")
        btn:SetHighlightFontObject("GameFontHighlightSmall")
        btn:SetText(arrowChar)
        btn:SetScript("OnClick", onScroll)
        return btn
    end

    CreateSpellScrollBtn(spellSlider, "BOTTOM", "TOP", 2, "▲", function()
        local newVal = math.max(0, spellScrollOffset - 3)
        if newVal ~= spellScrollOffset then
            spellScrollOffset = newVal
            IMTSpellScrollFrame_Update()
        end
    end)
    CreateSpellScrollBtn(spellSlider, "TOP", "BOTTOM", -2, "▼", function()
        local _, maxVal = spellSlider:GetMinMaxValues()
        local newVal = math.min(maxVal, spellScrollOffset + 3)
        if newVal ~= spellScrollOffset then
            spellScrollOffset = newVal
            IMTSpellScrollFrame_Update()
        end
    end)

    -- 按钮池
    spellSlider.buttonPool = {}
    for i = 1, SPELL_VISIBLE do
        local btn = CreateFrame("Button", nil, spellFrame, "BackdropTemplate")
        btn:SetSize(SPELL_BTN_W, SPELL_BTN_H)
        btn:SetPoint("TOPLEFT", 12, SPELL_LIST_TOP - (i - 1) * SPELL_BTN_H)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.listBg))
        btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        btn:SetFontString(btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
        btn:GetFontString():SetAllPoints(btn)
        btn:GetFontString():SetJustifyH("LEFT")
        btn:GetFontString():SetPoint("LEFT", 8, 0)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(T.listHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(T.listBg))
            self:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        end)
        btn:SetScript("OnMouseWheel", function(self, delta)
            spellFrame:GetScript("OnMouseWheel")(spellFrame, delta)
        end)
        btn:SetScript("OnClick", function(self)
            if self.spellID then
                savedSelectedSpellName = self.spellName
                iMorphToolsDBC.selectedSpellName = self.spellName
                spellEffectBtn:SetText(self.spellName)
                spellFrame:Hide()
            end
        end)
        spellSlider.buttonPool[i] = btn
    end

    -- 核心刷新
    IMTSpellScrollFrame_Update = function()
        local groupData
        for _, g in ipairs(IMT.SpellGroups) do
            if g[1] == spellSelectedGroup then groupData = g[2]; break end
        end
        local cnt = groupData and #groupData or 0
        local maxScroll = math.max(0, cnt - SPELL_VISIBLE)
        spellSlider:SetMinMaxValues(0, maxScroll)
        if spellScrollOffset > maxScroll then
            spellScrollOffset = maxScroll
        end
        spellSlider:SetValue(spellScrollOffset)
        for i = 1, SPELL_VISIBLE do
            local btn = spellSlider.buttonPool[i]
            local idx = spellScrollOffset + i
            if idx <= cnt then
                local def = groupData[idx]
                btn:SetText(def[1])
                btn.spellName = def[1]
                btn.spellID = def[2]
                btn:SetBackdropColor(unpack(T.listBg))
                btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
                btn:Show()
            else
                btn:Hide()
            end
        end
    end

    spellSlider:SetScript("OnValueChanged", function(self, value)
        spellScrollOffset = math.floor(value + 0.5)
        IMTSpellScrollFrame_Update()
    end)

    spellFrame:SetScript("OnMouseWheel", function(self, delta)
        local _, maxVal = spellSlider:GetMinMaxValues()
        local newVal = math.max(0, math.min(maxVal, spellScrollOffset - delta))
        if newVal ~= spellScrollOffset then
            spellScrollOffset = newVal
            IMTSpellScrollFrame_Update()
        end
    end)

    -- 标签按钮
    local spellTabBtns = {}
    local function SetSpellTabActive(activeTab)
        for _, t in ipairs(spellTabBtns) do
            if t == activeTab then
                t.isActive = true
                t:SetBackdropColor(unpack(T.tabActiveBg))
                t:SetBackdropBorderColor(unpack(T.tabActiveBdr))
                t:GetFontString():SetTextColor(unpack(T.textAccent))
            else
                t.isActive = false
                t:SetBackdropColor(unpack(T.btnBg))
                t:SetBackdropBorderColor(unpack(T.btnBorder))
                t:GetFontString():SetTextColor(1, 0.85, 0, 1)
            end
        end
    end
    for gi, group in ipairs(IMT.SpellGroups) do
        local tab = CreateModernButton(nil, spellFrame, 65, 20, group[1])
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetHighlightFontObject("GameFontHighlightSmall")
        local prevTab = spellTabBtns[#spellTabBtns]
        if gi == 1 then
            tab:SetPoint("TOPLEFT", 10, SPELL_TAB_TOP)
        elseif gi <= 3 then
            tab:SetPoint("TOPLEFT", prevTab, "TOPRIGHT", 2, 0)
        elseif gi == 4 then
            tab:SetPoint("TOPLEFT", 10, SPELL_TAB2_TOP)
        else
            tab:SetPoint("TOPLEFT", prevTab, "TOPRIGHT", 2, 0)
        end
        tab:SetScript("OnClick", function()
            spellSelectedGroup = group[1]
            spellScrollOffset = 0
            SetSpellTabActive(tab)
            IMTSpellScrollFrame_Update()
            C_Timer.After(0, IMTSpellScrollFrame_Update)
        end)
        if group[1] == spellSelectedGroup then
            tab.isActive = true
            tab:SetBackdropColor(unpack(T.tabActiveBg))
            tab:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            tab:GetFontString():SetTextColor(unpack(T.textAccent))
        end
        tab:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(unpack(T.btnHover))
                self:SetBackdropBorderColor(unpack(T.accent))
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropColor(unpack(T.tabActiveBg))
                self:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            else
                self:SetBackdropColor(unpack(T.btnBg))
                self:SetBackdropBorderColor(unpack(T.btnBorder))
            end
        end)
        spellTabBtns[#spellTabBtns + 1] = tab
    end

    spellEffectBtn:SetScript("OnClick", function(self)
        if spellFrame:IsShown() then
            spellFrame:Hide()
        else
            spellFrame:ClearAllPoints()
            spellFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            spellScrollOffset = 0
            IMTSpellScrollFrame_Update()
            CloseAllPopups(spellFrame)
            spellFrame:Show()
        end
    end)

    buttonSpellChange:SetScript("OnClick", function()
        local selectedSpellID = IMT.SpellNames[savedSelectedSpellName]
        iMorphToolsDBC.editBoxContent = editBox1:GetText()

        local param
        local editText = editBox1:GetText()
        if editText and editText ~= "" then
            param = tonumber(editText)
        elseif savedDynamicSpellID then
            param = savedDynamicSpellID
        elseif selectedSpellID then
            param = selectedSpellID
        end

        if param then
            SetSpell(param, selectedSpellID)
        end
    end)

    return dynamicSpellBtn
end

local function BuildPlayKitSection(mainFrame, preWidget)
    local savedPKID = tonumber(iMorphToolsDBC.PlayKitID) or 36399
    local selectedPlayKitID = savedPKID
    local selectedPlayKitOpt = iMorphToolsDBC.PlayKitOpt or "0"
    local selectedPlayKitName = "白虎特效"
    for _, pk in ipairs(IMT.PlayKitDefs) do
        if pk[2] == savedPKID then
            selectedPlayKitName = pk[1]
            break
        end
    end

    -- 特效选择按钮
    local pkBtn = CreateModernButton("PlayKitBtn", mainFrame, 100, 28, selectedPlayKitName)
    pkBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -5)
    SetupTooltip(pkBtn, "点击选择视觉套件")

    -- 动态/静态切换
    local optBtns = {}
    local optInfo = {{"动态", "0"}, {"静态", "1"}}
    local function SetOptBtnActive(activeBtn)
        for _, t in ipairs(optBtns) do
            if t == activeBtn then
                t.isActive = true
                t:SetBackdropColor(unpack(T.tabActiveBg))
                t:SetBackdropBorderColor(unpack(T.tabActiveBdr))
                t:GetFontString():SetTextColor(unpack(T.textAccent))
            else
                t.isActive = false
                t:SetBackdropColor(unpack(T.btnBg))
                t:SetBackdropBorderColor(unpack(T.btnBorder))
                t:GetFontString():SetTextColor(1, 0.85, 0, 1)
            end
        end
    end
    for _, info in ipairs(optInfo) do
        local label, opt = info[1], info[2]
        local btn = CreateModernButton(nil, mainFrame, 40, 28, label)
        btn:SetNormalFontObject("GameFontNormalSmall")
        btn:SetHighlightFontObject("GameFontHighlightSmall")
        local prevBtn = optBtns[#optBtns]
        if prevBtn then
            btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", 2, 0)
        else
            btn:SetPoint("LEFT", pkBtn, "RIGHT", 4, 0)
        end
        btn:SetScript("OnClick", function()
            selectedPlayKitOpt = opt
            iMorphToolsDBC.PlayKitOpt = opt
            SetOptBtnActive(btn)
        end)
        if opt == selectedPlayKitOpt then
            btn.isActive = true
            btn:SetBackdropColor(unpack(T.tabActiveBg))
            btn:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            btn:GetFontString():SetTextColor(unpack(T.textAccent))
        end
        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(unpack(T.btnHover))
                self:SetBackdropBorderColor(unpack(T.accent))
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropColor(unpack(T.tabActiveBg))
                self:SetBackdropBorderColor(unpack(T.tabActiveBdr))
            else
                self:SetBackdropColor(unpack(T.btnBg))
                self:SetBackdropBorderColor(unpack(T.btnBorder))
            end
        end)
        optBtns[#optBtns + 1] = btn
    end

    -- 应用按钮
    local buttonPK = CreateModernButton("buttonPK", mainFrame, 50, 28, "应用")
    buttonPK:SetPoint("LEFT", optBtns[#optBtns], "RIGHT", 4, 0)
    SetupTooltip(buttonPK, "应用选中的视觉套件\n动态=0 套件动作执行一次\n静态=1 套件保持固定效果")

    buttonPK:SetScript("OnClick", function()
        if selectedPlayKitID then
            PlayEffectKit(selectedPlayKitID, selectedPlayKitOpt)
        end
    end)

    -- 特效弹出框
    local PK_BTN_H = 22
    local PK_BTN_W = 150
    local PK_LIST_TOP = -36
    local PK_LIST_BOTTOM = 12
    local PK_VISIBLE = math.min(16, #IMT.PlayKitDefs)

    local pkPopup = CreateFrame("Frame", "IMTPKFrame", UIParent, "BackdropTemplate")
    RegisterPopup(pkPopup)
    pkPopup:SetSize(PK_BTN_W + 30, 36 + PK_VISIBLE * PK_BTN_H + 12)
    pkPopup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    pkPopup:SetBackdropColor(unpack(T.bg))
    pkPopup:SetBackdropBorderColor(unpack(T.border))
    pkPopup:EnableMouse(true)
    pkPopup:SetMovable(true)
    pkPopup:RegisterForDrag("LeftButton")
    pkPopup:SetScript("OnDragStart", pkPopup.StartMoving)
    pkPopup:SetScript("OnDragStop", pkPopup.StopMovingOrSizing)
    pkPopup:SetFrameStrata("DIALOG")
    pkPopup:Hide()
    CreateTitleBar(pkPopup, "|cff3399FF视觉套件|r", function() pkPopup:Hide() end)

    local pkBtnPool = {}
    for i = 1, PK_VISIBLE do
        local btn = CreateFrame("Button", nil, pkPopup, "BackdropTemplate")
        btn:SetSize(PK_BTN_W, PK_BTN_H)
        btn:SetPoint("TOPLEFT", 12, PK_LIST_TOP - (i - 1) * PK_BTN_H)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(unpack(T.listBg))
        btn:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        btn:SetFontString(btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
        btn:GetFontString():SetAllPoints(btn)
        btn:GetFontString():SetJustifyH("LEFT")
        btn:GetFontString():SetPoint("LEFT", 8, 0)
        btn:SetText(IMT.PlayKitDefs[i][1])
        btn.pkID = IMT.PlayKitDefs[i][2]
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(T.listHover))
            self:SetBackdropBorderColor(unpack(T.accent))
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(T.listBg))
            self:SetBackdropBorderColor(0.10, 0.10, 0.12, 1)
        end)
        btn:SetScript("OnClick", function(self)
            if self.pkID then
                selectedPlayKitID = self.pkID
                selectedPlayKitName = self:GetText()
                iMorphToolsDBC.PlayKitID = self.pkID
                pkBtn:SetText(self:GetText())
                C_Timer.After(0, function() pkPopup:Hide() end)
            end
        end)
        pkBtnPool[i] = btn
    end

    pkBtn:SetScript("OnClick", function(self)
        if pkPopup:IsShown() then
            pkPopup:Hide()
        else
            pkPopup:ClearAllPoints()
            pkPopup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            CloseAllPopups(pkPopup)
            pkPopup:Show()
        end
    end)

    return pkBtn
end

-- ============================================
-- 主界面初始化
-- ============================================
function InitUI()
    local mainFrame = CreateFrame("Frame", "iMorphToolsMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(360, 550)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    mainFrame:SetBackdropColor(unpack(T.bg))
    mainFrame:SetBackdropBorderColor(unpack(T.border))
    mainFrame:SetMovable(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetFrameStrata("LOW")
    mainFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -20)
    mainFrame:Hide()
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

    tinsert(UISpecialFrames, "iMorphToolsMainFrame")

    CreateTitleBar(mainFrame, "|cff3399FFiMorphTools|r", function() mainFrame:Hide() end)

    iMorphToolsMiniMapButton = CreateiMorphToolsMiniMapButton(mainFrame)

    -- 依次构建各功能区
    local w = BuildResetSection(mainFrame)
    w = BuildCmdSection(mainFrame, w)
    w = BuildSetSection(mainFrame, w)
    w = BuildModelSection(mainFrame, w)
    w = BuildPetSection(mainFrame, w)
    w = BuildMountSection(mainFrame, w)
    w = BuildRaceSection(mainFrame, w)
    w = BuildShapeshiftSection(mainFrame, w)
    w = BuildScaleSection(mainFrame, w)
    w = BuildItemSection(mainFrame, w)
    w = BuildEnchantSection(mainFrame, w)
    w = BuildSpellSection(mainFrame, w)
    BuildPlayKitSection(mainFrame, w)

    -- 版本文字
    local version = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8)
    version:SetText("|cff3399FFiMorphTools|cffffcc00by|cffff80ff聖殿十字军|r")
    version:Show()
end

-- ============================================
-- 小地图按钮
-- ============================================
function CreateiMorphToolsMiniMapButton(mainFrame)
    local btn = CreateFrame("Button", "iMorphToolsMiniMapButton", Minimap)
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 15, -110)
    btn:SetSize(30, 30)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\iMorphTools\\icon")

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText("iMorphTools\n右键按住拖动\n左键打开界面")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    btn:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if mainFrame:IsShown() then
                mainFrame:Hide()
            else
                mainFrame:Show()
            end
        end
    end)

    btn:SetMovable(true)
    btn:RegisterForDrag("RightButton")
    btn:SetScript("OnDragStart", function(self) self:StartMoving() end)
    btn:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    return btn
end

-- ============================================
-- 事件注册与斜杠命令
-- ============================================
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "iMorphTools" then
        iMorphToolsDBC = iMorphToolsDBC or {}
        InitUI()
    end
end)

-- 合并自原 diy.lua：玩家登录后显示欢迎消息
local welcomeFrame = CreateFrame("Frame")
welcomeFrame:RegisterEvent("PLAYER_LOGIN")
welcomeFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()
            print("|cffffff00欢迎使用iMorphTools改模工具，点击小地图图标或者使用/imt命令打开主界面|r")
        end)
    end
end)

SlashCmdList["iMorphTools"] = function()
    if iMorphToolsMainFrame and not iMorphToolsMainFrame:IsVisible() then
        iMorphToolsMainFrame:Show()
    end
end
SLASH_iMorphTools1 = "/imt"
