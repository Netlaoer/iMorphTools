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

-- 安全调用：确保 ID 为数字才执行
local function SafeCall(func, id)
    if type(id) == "number" then
        func(id)
    end
end

-- 安静调用：抑制函数执行时的 info 输出（如 Customizations）
local function SilentCall(func, ...)
    local origPrint = print
    print = function() end
    local ok, err = pcall(func, ...)
    print = origPrint
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
    for gi, group in ipairs(IMT.MountGroups) do
        local tab = CreateModernButton(nil, mountFrame, 55, 20, group[1])
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetHighlightFontObject("GameFontHighlightSmall")
        tab:SetDisabledFontObject("GameFontDisableSmall")
        local prevTab = mountTabBtns[#mountTabBtns]
        if prevTab then
            tab:SetPoint("TOPLEFT", prevTab, "TOPRIGHT", 2, 0)
        else
            tab:SetPoint("TOPLEFT", 10, MOUNT_TAB_TOP)
        end
        tab:SetScript("OnClick", function()
            mountSelectedGroup = group[1]
            mountScrollOffset = 0
            for _, t in ipairs(mountTabBtns) do
                t:SetEnabled(true)
            end
            tab:SetEnabled(false)
            IMTMountScrollFrame_Update()
            C_Timer.After(0, IMTMountScrollFrame_Update)
        end)
        if group[1] == mountSelectedGroup then
            tab:SetEnabled(false)
        end
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
    local savedMainHandSelection = iMorphToolsDBC.mainHandbjfmSelection or ""
    local selectedMainHandFunc = IMT.MainHandEnchants[savedMainHandSelection]
    local selectedMainHandName = savedMainHandSelection

    local savedOffHandSelection = iMorphToolsDBC.offHandbjfmSelection or ""
    local selectedOffHandFunc = IMT.OffHandEnchants[savedOffHandSelection]
    local selectedOffHandName = savedOffHandSelection

    local function CreateEnchantDropdown(name, parent, point, enchantData, enchantOrder, savedName, onSelect)
        local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint(unpack(point))
        UIDropDownMenu_SetWidth(dropdown, 112.5)
        UIDropDownMenu_SetText(dropdown, savedName or "请选择")
        StyleDropdown(dropdown)

        UIDropDownMenu_Initialize(dropdown, function(self, level)
            if level ~= 1 then return end
            local info = UIDropDownMenu_CreateInfo()
            for _, enchantName in ipairs(enchantOrder) do
                local func = enchantData[enchantName]
                if func then
                    info.text = enchantName
                    info.value = enchantName
                    info.checked = (enchantName == savedName)
                    info.func = function()
                        onSelect(enchantName, func)
                        UIDropDownMenu_SetText(dropdown, enchantName)
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end
        end)

        dropdown:SetScript("OnMouseDown", function(self)
            UIDropDownMenu_Refresh(self)
        end)

        return dropdown
    end

    local mainHandDropdown = CreateEnchantDropdown(
        "WPDemoMainHandbjfmDropDown", mainFrame,
        {"TOPLEFT", preWidget, "BOTTOMLEFT", 0, 0},
        IMT.MainHandEnchants, IMT.MainHandEnchantOrder, savedMainHandSelection,
        function(name, func)
            selectedMainHandName = name
            selectedMainHandFunc = func
            iMorphToolsDBC.mainHandbjfmSelection = name
        end
    )

    local offHandDropdown = CreateEnchantDropdown(
        "WPDemoOffHandbjfmDropDown", mainFrame,
        {"LEFT", mainHandDropdown, "RIGHT", -30, 0},
        IMT.OffHandEnchants, IMT.OffHandEnchantOrder, savedOffHandSelection,
        function(name, func)
            selectedOffHandName = name
            selectedOffHandFunc = func
            iMorphToolsDBC.offHandbjfmSelection = name
        end
    )

    local bjfmButton = CreateModernButton("bjfmButton", mainFrame, 75, 28, "武器附魔")
    bjfmButton:SetPoint("LEFT", offHandDropdown, "RIGHT", -16, 2)
    SetupTooltip(bjfmButton, "选择主副手附魔效果，点击修改")

    bjfmButton:SetScript("OnClick", function()
        if selectedMainHandFunc then selectedMainHandFunc() end
        if selectedOffHandFunc then selectedOffHandFunc() end
    end)

    if selectedMainHandName and selectedMainHandName ~= "" then
        UIDropDownMenu_SetText(mainHandDropdown, selectedMainHandName)
    end
    if selectedOffHandName and selectedOffHandName ~= "" then
        UIDropDownMenu_SetText(offHandDropdown, selectedOffHandName)
    end
    return mainHandDropdown
end

local function BuildSpellSection(mainFrame, preWidget)
    local savedSelectedSpellName = iMorphToolsDBC.selectedSpellName or "神圣风暴"
    local savedEditBoxContent = iMorphToolsDBC.editBoxContent
    local savedDynamicSpellName = iMorphToolsDBC.dynamicSpellName
    local savedDynamicSpellID = iMorphToolsDBC.dynamicSpellID

    -- 动态法术下拉
    local dynamicSpellDropdown = CreateFrame("Frame", "DynamicSpellDropdown", mainFrame, "UIDropDownMenuTemplate")
    dynamicSpellDropdown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, 0)
    UIDropDownMenu_SetWidth(dynamicSpellDropdown, 82.5)
    UIDropDownMenu_SetText(dynamicSpellDropdown, savedDynamicSpellName or "动态选择法术")
    StyleDropdown(dynamicSpellDropdown)

    local function InitializeDynamicSpellDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local foundAny = false

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
                                info.text = spellName
                                info.arg1 = spellInfo.spellID
                                info.checked = (spellName == savedDynamicSpellName)
                                info.func = function(_, arg1)
                                    savedDynamicSpellName = spellName
                                    savedDynamicSpellID = arg1
                                    iMorphToolsDBC.dynamicSpellName = spellName
                                    iMorphToolsDBC.dynamicSpellID = arg1
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
                                info.checked = (spellName == savedDynamicSpellName)
                                info.func = function(_, arg1)
                                    savedDynamicSpellName = spellName
                                    savedDynamicSpellID = arg1
                                    iMorphToolsDBC.dynamicSpellName = spellName
                                    iMorphToolsDBC.dynamicSpellID = arg1
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

        if not foundAny then
            info.text = "未找到可用法术"
            info.disabled = true
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dynamicSpellDropdown, InitializeDynamicSpellDropdown)

    local editBox1 = CreateModernEditBox("editBox1", mainFrame, 50, 28)
    editBox1:SetPoint("LEFT", dynamicSpellDropdown, "RIGHT", -8, 0)
    editBox1:SetText(savedEditBoxContent or "")

    local buttonSpellChange = CreateModernButton("buttonSpellChange", mainFrame, 80, 28, "》改技能》")
    buttonSpellChange:SetPoint("LEFT", editBox1, "RIGHT", 4, 0)
    SetupTooltip(buttonSpellChange, "技能显示效果修改：\n编辑框可填写触发类饰品，ID自己查询填入即可\n若编辑框填写了ID则忽略左侧选择框")

    -- 技能效果下拉
    local dropdownSpells = CreateFrame("Frame", "WPDemoDropdownSpells", mainFrame, "UIDropDownMenuTemplate")
    dropdownSpells:SetPoint("LEFT", buttonSpellChange, "RIGHT", -15, 0)
    UIDropDownMenu_SetWidth(dropdownSpells, 82.5)
    UIDropDownMenu_SetText(dropdownSpells, savedSelectedSpellName)
    StyleDropdown(dropdownSpells)

    UIDropDownMenu_Initialize(dropdownSpells, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        if level == 1 then
            for gi, group in ipairs(IMT.SpellGroups) do
                info.text = group[1]
                info.value = gi
                info.hasArrow = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info)
            end
        elseif level == 2 then
            local gi = UIDROPDOWNMENU_MENU_VALUE
            local group = IMT.SpellGroups[gi]
            if group then
                for _, spell in ipairs(group[2]) do
                    info.text = spell[1]
                    info.value = spell[2]
                    info.checked = (spell[1] == savedSelectedSpellName)
                    info.func = function()
                        savedSelectedSpellName = spell[1]
                        iMorphToolsDBC.selectedSpellName = spell[1]
                        UIDropDownMenu_SetText(dropdownSpells, spell[1])
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
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

    return dynamicSpellDropdown
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

    local dropdownPlayKit = CreateFrame("Frame", "PlayKitDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropdownPlayKit:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -5)
    UIDropDownMenu_SetWidth(dropdownPlayKit, 90)
    UIDropDownMenu_SetText(dropdownPlayKit, selectedPlayKitName)
    StyleDropdown(dropdownPlayKit)

    UIDropDownMenu_Initialize(dropdownPlayKit, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, pk in ipairs(IMT.PlayKitDefs) do
            info.text = pk[1]
            info.func = function()
                selectedPlayKitID = pk[2]
                selectedPlayKitName = pk[1]
                iMorphToolsDBC.PlayKitID = pk[2]
                UIDropDownMenu_SetText(dropdownPlayKit, pk[1])
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local optLabels = {["0"] = "动态", ["1"] = "静态"}
    local dropdownPlayKitOpt = CreateFrame("Frame", "PlayKitOptDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropdownPlayKitOpt:SetPoint("LEFT", dropdownPlayKit, "RIGHT", -10, 0)
    UIDropDownMenu_SetWidth(dropdownPlayKitOpt, 60)
    UIDropDownMenu_SetText(dropdownPlayKitOpt, optLabels[selectedPlayKitOpt] or "动态")
    StyleDropdown(dropdownPlayKitOpt)

    UIDropDownMenu_Initialize(dropdownPlayKitOpt, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "动态"
        info.func = function()
            selectedPlayKitOpt = "0"
            iMorphToolsDBC.PlayKitOpt = "0"
            UIDropDownMenu_SetText(dropdownPlayKitOpt, "动态")
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
        info = UIDropDownMenu_CreateInfo()
        info.text = "静态"
        info.func = function()
            selectedPlayKitOpt = "1"
            iMorphToolsDBC.PlayKitOpt = "1"
            UIDropDownMenu_SetText(dropdownPlayKitOpt, "静态")
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end)

    local buttonPK = CreateModernButton("buttonPK", mainFrame, 50, 24, "应用")
    buttonPK:SetPoint("LEFT", dropdownPlayKitOpt, "RIGHT", -5, 2)
    SetupTooltip(buttonPK, "应用选中的视觉套件\n动态=0 套件动作执行一次\n静态=1 套件保持固定效果")

    buttonPK:SetScript("OnClick", function()
        if selectedPlayKitID then
            PlayEffectKit(selectedPlayKitID, selectedPlayKitOpt)
        end
    end)

    return dropdownPlayKit
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
