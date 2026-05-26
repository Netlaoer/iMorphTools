-- iMorphTools UI
-- 主界面逻辑，使用 IMT 命名空间中的数据

-- ============================================
-- 辅助函数
-- ============================================

-- 安全调用：确保 ID 为数字才执行
local function SafeCall(func, id)
    if type(id) == "number" then
        func(id)
    end
end

-- 安静调用：抑制函数执行时的 info 输出（如 Customizations）
local function SilentCall(func, ...)
    local saved = {}
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        if cf and cf.AddMessage then
            saved[i] = cf.AddMessage
            cf.AddMessage = function(self, msg, ...)
                if msg and type(msg) == "string" then
                    if msg:find("%(info%)") or msg:find("model id:") then return end
                end
                return saved[i](self, msg, ...)
            end
        end
    end
    local ok, err = pcall(func, ...)
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        if cf and saved[i] then
            cf.AddMessage = saved[i]
        end
    end
    if not ok then DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. tostring(err) .. "|r") end
end

-- 创建通用 Tooltip
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

-- 创建"选择+手动输入"行（角色/宠物/坐骑共用）
-- 返回 selectBtn, editBox, manualBtn, menuFrame
local function CreateSelectRow(parent, prevWidget, config)
    -- config: { selectName, selectLabel, selectTooltip, menuName,
    --           data, order, onSelect,
    --           editBoxName, editBoxSize, editBoxDefault, editBoxSavedVar,
    --           manualName, manualLabel, manualTooltip, onManual }

    local selectBtn = CreateFrame("Button", config.selectName, parent, "UIPanelButtonTemplate")
    selectBtn:SetPoint("TOPLEFT", prevWidget, "BOTTOMLEFT", config.offsetX or 0, config.offsetY or -3)
    selectBtn:SetSize(121, 30)
    selectBtn:SetText(config.selectLabel)
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

    selectBtn:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, menuFrame, self, 0, 0)
    end)

    local editBox = CreateFrame("EditBox", config.editBoxName, parent, "BJ_InputBoxTemplate")
    editBox:SetSize(config.editBoxSize or 85, 30)
    editBox:SetPoint("LEFT", selectBtn, "RIGHT", 8, 0)
    editBox:SetText(iMorphToolsDBC[config.editBoxSavedVar] or config.editBoxDefault)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC[config.editBoxSavedVar] = self:GetText()
    end)

    local manualBtn = CreateFrame("Button", config.manualName, parent, "UIPanelButtonTemplate")
    manualBtn:SetSize(121, 30)
    manualBtn:SetPoint("LEFT", editBox, "RIGHT", 1, 0)
    manualBtn:SetText(config.manualLabel)
    SetupTooltip(manualBtn, config.manualTooltip)

    manualBtn:SetScript("OnClick", function()
        local inputID = tonumber(editBox:GetText())
        if inputID then
            config.onManual(inputID)
        end
    end)

    return selectBtn, editBox, manualBtn, menuFrame
end

-- ============================================
-- 主界面初始化
-- ============================================
function InitUI()
    -- 主界面框架
    local mainFrame = CreateFrame("Frame", "iMorphToolsMainFrame", UIParent, "BasicFrameTemplate")
    mainFrame:SetSize(360, 550)
    mainFrame.TitleText:SetText("|cff40C7EBiMorphTools")
    mainFrame:SetMovable(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetPropagateKeyboardInput(true)
    mainFrame:SetFrameStrata("LOW")
    mainFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -20)
    mainFrame:Hide()

    mainFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    mainFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    mainFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then self:Hide() end
    end)

    -- 小地图按钮
    iMorphToolsMiniMapButton = CreateiMorphToolsMiniMapButton(mainFrame)

    -- 当前布局锚点
    local preWidget

    -- ======== 重置按钮 ========
    local resetBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    resetBtn:SetSize(330, 25)
    resetBtn:SetPoint("TOP", mainFrame, "TOP", 0, -28)
    resetBtn:SetText("重置初始模型")
    resetBtn:SetScript("OnClick", ResetIds)
    preWidget = resetBtn

    -- ======== 便捷改模指令集 ========
    local cmdBtn = CreateFrame("Button", "CmdBtn", mainFrame, "UIPanelButtonTemplate")
    cmdBtn:SetSize(330, 25)
    cmdBtn:SetPoint("TOP", preWidget, "BOTTOM", 0, -5)
    cmdBtn:SetText("便捷改模指令集")
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

    cmdBtn:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, cmdMenu, self, 0, 0)
    end)
    preWidget = cmdBtn

    -- ======== 修改套装 ========
    local savedSetText = iMorphToolsDBC.EditBox2Text or ""
    local editBox2 = CreateFrame("EditBox", "editBox2", mainFrame, "BJ_InputBoxTemplate")
    editBox2:SetSize(165, 30)
    editBox2:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 10, -3)
    editBox2:SetText(savedSetText)
    editBox2:SetAutoFocus(false)

    local buttonSetChange = CreateFrame("Button", "buttonSetChange", mainFrame, "UIPanelButtonTemplate")
    buttonSetChange:SetSize(125, 30)
    buttonSetChange:SetPoint("LEFT", editBox2, "RIGHT", 30, 0)
    buttonSetChange:SetText("修改套装")
    SetupTooltip(buttonSetChange, "编辑框直接输入DKT3、QST6，PVP系列仅采集了S1，T9系列分BL/LM（例\"QSLMT9\"）。也可自行查询编号手动输入")

    buttonSetChange:SetScript("OnClick", function()
        local inputText = editBox2:GetText()
        local setId = tonumber(inputText) or IMT.SetMapping[inputText:upper()]
        if setId then SetItemSet(setId) end
        iMorphToolsDBC.EditBox2Text = inputText
    end)
    preWidget = editBox2

    -- ======== 角色改模 ========
    local selectModelBtn, _, _, _ = CreateSelectRow(mainFrame, preWidget, {
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
    preWidget = selectModelBtn

    -- ======== 宠物改模 ========
    local selectPetBtn, _, _, _ = CreateSelectRow(mainFrame, preWidget, {
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
    preWidget = selectPetBtn

    -- ======== 坐骑改模 ========
    local selectMountBtn = CreateFrame("Button", "SelectMountBtn", mainFrame, "UIPanelButtonTemplate")
    selectMountBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
    selectMountBtn:SetSize(121, 30)
    selectMountBtn:SetText("坐骑改模")
    SetupTooltip(selectMountBtn, "点击打开坐骑选择列表")

    -- 坐骑选择弹出框（带滚动条）
    local mountFrame = CreateFrame("Frame", "IMTMountFrame", UIParent, "BackdropTemplate")
    mountFrame:SetSize(320, 460)
    mountFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    mountFrame:SetBackdropColor(0, 0, 0, 0.95)
    mountFrame:EnableMouse(true)
    mountFrame:SetMovable(true)
    mountFrame:RegisterForDrag("LeftButton")
    mountFrame:SetScript("OnDragStart", mountFrame.StartMoving)
    mountFrame:SetScript("OnDragStop", mountFrame.StopMovingOrSizing)
    mountFrame:SetFrameStrata("DIALOG")
    mountFrame:Hide()

    local mountCloseBtn = CreateFrame("Button", nil, mountFrame, "UIPanelCloseButton")
    mountCloseBtn:SetPoint("TOPRIGHT", 2, 2)

    -- 分类标签按钮
    local MOUNT_BTN_H = 22
    local MOUNT_BTN_W = 275
    local MOUNT_TAB_TOP = -30
    local MOUNT_LIST_TOP = -60
    local MOUNT_LIST_BOTTOM = 12
    local MOUNT_VISIBLE = math.floor((460 + MOUNT_LIST_TOP - MOUNT_LIST_BOTTOM) / MOUNT_BTN_H)

    local mountSelectedGroup = IMT.MountGroups[1] and IMT.MountGroups[1][1] or ""
    local mountScrollOffset = 0
    local mountDirty = false

    -- 滚动条（纯视觉 + 交互，不触发直接更新）
    local mountSlider = CreateFrame("Slider", nil, mountFrame, "UIPanelScrollBarTemplate")
    mountSlider:SetPoint("TOPRIGHT", -6, MOUNT_LIST_TOP + 10)
    mountSlider:SetPoint("BOTTOMRIGHT", -6, MOUNT_LIST_BOTTOM + 10)
    mountSlider:SetOrientation("VERTICAL")
    mountSlider:SetMinMaxValues(0, 0)
    mountSlider:SetValueStep(1)
    mountSlider:SetObeyStepOnDrag(true)
    mountSlider:SetValue(0)

    -- 核心刷新函数
    local function IMTMountScrollFrame_Update()
        local groupData
        for _, g in ipairs(IMT.MountGroups) do
            if g[1] == mountSelectedGroup then groupData = g[2]; break end
        end
        local count = groupData and #groupData or 0
        local maxScroll = math.max(0, count - MOUNT_VISIBLE)
        -- 同步滑块范围（不触发回调）
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
                btn:Show()
            else
                btn:Hide()
            end
        end
    end

    -- 脏标记 + OnUpdate：保证刷新在帧渲染时执行
    mountFrame:SetScript("OnUpdate", function(self)
        if mountDirty then
            mountDirty = false
            IMTMountScrollFrame_Update()
        end
    end)

    local function IMTMountRequestUpdate()
        mountDirty = true
    end

    -- 滑块拖动只改偏移量，标记脏
    mountSlider:SetScript("OnValueChanged", function(self, value)
        mountScrollOffset = math.floor(value + 0.5)
        mountDirty = true
    end)

    -- 鼠标滚轮
    mountFrame:SetScript("OnMouseWheel", function(self, delta)
        local _, maxVal = mountSlider:GetMinMaxValues()
        local newVal = math.max(0, math.min(maxVal, mountScrollOffset - delta))
        if newVal ~= mountScrollOffset then
            mountScrollOffset = newVal
            mountDirty = true
        end
    end)

    -- 标签按钮
    local mountTabBtns = {}
    for gi, group in ipairs(IMT.MountGroups) do
        local tab = CreateFrame("Button", nil, mountFrame, "UIPanelButtonTemplate")
        tab:SetSize(55, 22)
        tab:SetText(group[1])
        tab:SetNormalFontObject("GameFontNormalSmall")
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
            IMTMountRequestUpdate()
        end)
        if group[1] == mountSelectedGroup then
            tab:SetEnabled(false)
        end
        mountTabBtns[#mountTabBtns + 1] = tab
    end

    -- 按钮池
    mountSlider.buttonPool = {}
    for i = 1, MOUNT_VISIBLE do
        local btn = CreateFrame("Button", nil, mountFrame)
        btn:SetSize(MOUNT_BTN_W, MOUNT_BTN_H)
        btn:SetPoint("TOPLEFT", 12, MOUNT_LIST_TOP - (i - 1) * MOUNT_BTN_H)
        btn:EnableMouseWheel(true)
        btn:SetScript("OnMouseWheel", function(self, delta)
            mountFrame:GetScript("OnMouseWheel")(mountFrame, delta)
        end)
        local fontStr = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fontStr:SetAllPoints()
        fontStr:SetJustifyH("LEFT")
        btn:SetFontString(fontStr)
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        local ht = btn:CreateTexture(nil, "HIGHLIGHT")
        ht:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
        ht:SetAllPoints()
        ht:SetAlpha(0.4)
        btn:SetScript("OnClick", function(self)
            if self.mountID then
                SafeCall(SetMount, self.mountID)
            end
        end)
        mountSlider.buttonPool[i] = btn
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

    local editBoxMount = CreateFrame("EditBox", "editBox3", mainFrame, "BJ_InputBoxTemplate")
    editBoxMount:SetSize(85, 30)
    editBoxMount:SetPoint("LEFT", selectMountBtn, "RIGHT", 8, 0)
    editBoxMount:SetText(iMorphToolsDBC.MountModelID or "21974")
    editBoxMount:SetAutoFocus(false)
    editBoxMount:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.MountModelID = self:GetText()
    end)

    local manualMountBtn = CreateFrame("Button", "buttonMountChange", mainFrame, "UIPanelButtonTemplate")
    manualMountBtn:SetSize(121, 30)
    manualMountBtn:SetPoint("LEFT", editBoxMount, "RIGHT", 1, 0)
    manualMountBtn:SetText("手动坐骑改模")
    SetupTooltip(manualMountBtn, "输入坐骑模型ID后点击修改")

    manualMountBtn:SetScript("OnClick", function()
        local inputID = tonumber(editBoxMount:GetText())
        if inputID then
            SetMount(inputID)
        end
    end)

    preWidget = selectMountBtn

    -- ======== 种族改模 ========
    local selectRaceBtn = CreateFrame("Button", "SelectRaceBtn", mainFrame, "UIPanelButtonTemplate")
    selectRaceBtn:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -3)
    selectRaceBtn:SetSize(170, 30)
    selectRaceBtn:SetText("点击修改种族模型")
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
        ToggleDropDownMenu(1, nil, raceMenu, self, 0, 0)
    end)
    preWidget = selectRaceBtn

    -- ======== 变性 ========
    local buttonGenderChange = CreateFrame("Button", "buttonGenderChange", mainFrame, "UIPanelButtonTemplate")
    buttonGenderChange:SetSize(160, 30)
    buttonGenderChange:SetPoint("LEFT", selectRaceBtn, "RIGHT", 8, 0)
    buttonGenderChange:SetText("变性")
    SetupTooltip(buttonGenderChange, "点击改变角色性别")
    buttonGenderChange:SetScript("OnClick", function()
        SetGender()
        SilentCall(Customizations)
    end)

    -- ======== 变形形态 ========
    local savedShapeshiftSelection = iMorphToolsDBC.shapeshiftSelection or "猎豹形态"
    local selectedShapeshiftID = IMT.ShapeshiftIDs[savedShapeshiftSelection]
    local selectedShapeshiftName = savedShapeshiftSelection

    local dropdownShapeshifts = CreateFrame("Frame", "WPDemoDropdownShapeshifts", mainFrame, "UIDropDownMenuTemplate")
    dropdownShapeshifts:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -17, -3)
    UIDropDownMenu_SetWidth(dropdownShapeshifts, 100)
    UIDropDownMenu_SetText(dropdownShapeshifts, "变形形态")

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

    -- 形态模型ID编辑框
    local editBox10 = CreateFrame("EditBox", "editBox10", mainFrame, "BJ_InputBoxTemplate")
    editBox10:SetSize(45, 30)
    editBox10:SetPoint("LEFT", dropdownShapeshiftModels, "RIGHT", -8, 0)
    editBox10:SetText(iMorphToolsDBC.ShapeshiftModelID or "21974")
    editBox10:SetAutoFocus(false)
    editBox10:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.ShapeshiftModelID = self:GetText()
    end)

    -- 改变形按钮
    local buttonShapeshiftChange = CreateFrame("Button", "buttonShapeshiftChange", mainFrame, "UIPanelButtonTemplate")
    buttonShapeshiftChange:SetSize(65, 30)
    buttonShapeshiftChange:SetPoint("LEFT", editBox10, "RIGHT", 1, 0)
    buttonShapeshiftChange:SetText("改形态")
    SetupTooltip(buttonShapeshiftChange, "选择形态和形态模型，点击修改")

    buttonShapeshiftChange:SetScript("OnClick", function()
        local morphID = selectedShapeshiftModelID or tonumber(editBox10:GetText())
        if selectedShapeshiftID and morphID then
            SetShapeshiftForm(selectedShapeshiftID, morphID)
        end
    end)

    preWidget = dropdownShapeshifts

    -- ======== 模型缩放滑块 ========
    local scaleSlider = CreateFrame("Slider", "scaleSlider", mainFrame, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 18, -12)
    scaleSlider:SetMinMaxValues(0.5, 3.0)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetValue(1.0)
    scaleSlider:SetWidth(330)
    scaleSlider.text = _G[scaleSlider:GetName().."Text"]
    scaleSlider.text:SetText("模型缩放: 1.00")
    _G[scaleSlider:GetName().."Low"]:SetText("缩小")
    _G[scaleSlider:GetName().."High"]:SetText("放大")
    scaleSlider:SetScript("OnValueChanged", function(self)
        local scale = self:GetValue()
        self.text:SetText(format("模型缩放: %.2f", scale))
        SetScale(scale)
    end)
    preWidget = scaleSlider

    -- ======== 宠物缩放滑块 ========
    local petScaleSlider = CreateFrame("Slider", "petScaleSlider", mainFrame, "OptionsSliderTemplate")
    petScaleSlider:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -18)
    petScaleSlider:SetMinMaxValues(0.5, 3.0)
    petScaleSlider:SetValueStep(0.1)
    petScaleSlider:SetValue(1.0)
    petScaleSlider:SetWidth(330)
    petScaleSlider.text = _G[petScaleSlider:GetName().."Text"]
    petScaleSlider.text:SetText("宠物缩放: 1.00")
    _G[petScaleSlider:GetName().."Low"]:SetText("缩小")
    _G[petScaleSlider:GetName().."High"]:SetText("放大")
    petScaleSlider:SetScript("OnValueChanged", function(self)
        local scale = self:GetValue()
        self.text:SetText(format("宠物缩放: %.2f", scale))
        SetScalePet(scale)
    end)
    preWidget = petScaleSlider

    -- ======== 改装备 ========
    local selectedSlotID = iMorphToolsDBC.selectedSlotID or 1

    local dropDown = CreateFrame("Frame", "WPDemoDropDown2", mainFrame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", -18, -14)
    UIDropDownMenu_SetWidth(dropDown, 150)

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

    local textFrame = CreateFrame("EditBox", "WPDemoTextFrame", mainFrame, "BJ_InputBoxTemplate")
    textFrame:SetSize(85, 30)
    textFrame:SetPoint("LEFT", dropDown, "RIGHT", -8, 0)
    textFrame:SetText(iMorphToolsDBC.modelID or "物品编号")
    textFrame:SetAutoFocus(false)
    textFrame:SetScript("OnTextChanged", function()
        iMorphToolsDBC.modelID = textFrame:GetText()
    end)

    local buttonFrame = CreateFrame("Button", "WPDemoButtonFrame", mainFrame, "UIPanelButtonTemplate")
    buttonFrame:SetSize(75, 30)
    buttonFrame:SetPoint("LEFT", textFrame, "RIGHT", 1, 0)
    buttonFrame:SetText("改装备")
    SetupTooltip(buttonFrame, "选择装备栏位然后在编辑框填写物品ID，点击修改")

    buttonFrame:SetScript("OnClick", function()
        local itemID = tonumber(textFrame:GetText())
        if selectedSlotID and itemID then
            SetItem(selectedSlotID, itemID)
        end
    end)
    preWidget = dropDown

    -- ======== 武器附魔 ========
    local savedMainHandSelection = iMorphToolsDBC.mainHandbjfmSelection or ""
    local selectedMainHandFunc = IMT.MainHandEnchants[savedMainHandSelection]
    local selectedMainHandName = savedMainHandSelection

    local savedOffHandSelection = iMorphToolsDBC.offHandbjfmSelection or ""
    local selectedOffHandFunc = IMT.OffHandEnchants[savedOffHandSelection]
    local selectedOffHandName = savedOffHandSelection

    -- 创建附魔下拉菜单的通用函数
    local function CreateEnchantDropdown(name, parent, point, enchantData, enchantOrder, savedName, onSelect)
        local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint(unpack(point))
        UIDropDownMenu_SetWidth(dropdown, 112.5)
        UIDropDownMenu_SetText(dropdown, savedName or "请选择")

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

    local bjfmButton = CreateFrame("Button", "bjfmButton", mainFrame, "UIPanelButtonTemplate")
    bjfmButton:SetSize(75, 30)
    bjfmButton:SetPoint("LEFT", offHandDropdown, "RIGHT", -16, 3)
    bjfmButton:SetText("武器附魔")
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
    preWidget = mainHandDropdown

    -- ======== 改技能 ========
    local savedSelectedSpellName = iMorphToolsDBC.selectedSpellName or "神圣风暴"
    local savedEditBoxContent = iMorphToolsDBC.editBoxContent
    local savedDynamicSpellName = iMorphToolsDBC.dynamicSpellName
    local savedDynamicSpellID = iMorphToolsDBC.dynamicSpellID

    -- 动态法术下拉
    local dynamicSpellDropdown = CreateFrame("Frame", "DynamicSpellDropdown", mainFrame, "UIDropDownMenuTemplate")
    dynamicSpellDropdown:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, 0)
    UIDropDownMenu_SetWidth(dynamicSpellDropdown, 82.5)
    UIDropDownMenu_SetText(dynamicSpellDropdown, savedDynamicSpellName or "动态选择法术")

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

    -- 技能ID编辑框
    local editBox1 = CreateFrame("EditBox", "editBox1", mainFrame, "BJ_InputBoxTemplate")
    editBox1:SetSize(50, 30)
    editBox1:SetPoint("LEFT", dynamicSpellDropdown, "RIGHT", -8, 0)
    editBox1:SetText(savedEditBoxContent or "")
    editBox1:SetAutoFocus(false)

    -- 改技能按钮
    local buttonSpellChange = CreateFrame("Button", "buttonSpellChange", mainFrame, "UIPanelButtonTemplate")
    buttonSpellChange:SetSize(80, 30)
    buttonSpellChange:SetPoint("LEFT", editBox1, "RIGHT", 0, 0)
    buttonSpellChange:SetText("》改技能》")
    SetupTooltip(buttonSpellChange, "技能显示效果修改：\n编辑框可填写触发类饰品，ID自己查询填入即可\n若编辑框填写了ID则忽略左侧选择框")

    -- 技能效果下拉
    local dropdownSpells = CreateFrame("Frame", "WPDemoDropdownSpells", mainFrame, "UIDropDownMenuTemplate")
    dropdownSpells:SetPoint("LEFT", buttonSpellChange, "RIGHT", -15, 0)
    UIDropDownMenu_SetWidth(dropdownSpells, 82.5)
    UIDropDownMenu_SetText(dropdownSpells, savedSelectedSpellName)

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

    preWidget = dynamicSpellDropdown

    -- ======== 视觉套件 (playkit) ========
    local selectedPlayKitID = iMorphToolsDBC.PlayKitID or "36399"
    local selectedPlayKitOpt = iMorphToolsDBC.PlayKitOpt or "0"
    local selectedPlayKitName = "白虎特效"
    for _, pk in ipairs(IMT.PlayKitDefs) do
        if pk[2] == selectedPlayKitID then
            selectedPlayKitName = pk[1]
            break
        end
    end

    local dropdownPlayKit = CreateFrame("Frame", "PlayKitDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropdownPlayKit:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 0, -5)
    UIDropDownMenu_SetWidth(dropdownPlayKit, 90)
    UIDropDownMenu_SetText(dropdownPlayKit, selectedPlayKitName)

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

    local buttonPK = CreateFrame("Button", "buttonPK", mainFrame, "UIPanelButtonTemplate")
    buttonPK:SetSize(50, 24)
    buttonPK:SetPoint("LEFT", dropdownPlayKitOpt, "RIGHT", -5, 2)
    buttonPK:SetText("应用")
    SetupTooltip(buttonPK, "执行 .playkit 命令应用选中的视觉套件\n动态=0 套件动作执行一次\n静态=1 套件保持固定效果")


    buttonPK:SetScript("OnClick", function()
        if selectedPlayKitID and selectedPlayKitID ~= "" then
            local editBox = ChatFrame1EditBox
            editBox:SetText(".playkit " .. selectedPlayKitID .. " " .. selectedPlayKitOpt)
            ChatEdit_SendText(editBox, 0)
        end
    end)

    preWidget = dropdownPlayKit

    -- 版本文字
    local version = mainFrame:CreateFontString()
    version:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8)
    version:SetFontObject(GameFontNormal)
    version:SetText("|cFFA335EEiMorphTools|cFFFF7D0Aby|cFFF58CBA聖殿十字军")
    version:Show()
end

-- ============================================
-- 小地图按钮
-- ============================================
function CreateiMorphToolsMiniMapButton(mainFrame)
    local btn = CreateFrame("Button", "iMorphToolsMiniMapButton", Minimap, "UICheckButtonTemplate")
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 15, -110)
    btn:SetSize(26, 26)
    btn:SetNormalTexture("Interface\\AddOns\\iMorphTools\\icon")
    btn:SetPushedTexture("Interface\\AddOns\\iMorphTools\\icon")
    btn:Show()

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText("iMorphTools\n右键按住拖动\n左键打开界面")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

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

SlashCmdList["iMorphTools"] = function()
    if iMorphToolsMainFrame and not iMorphToolsMainFrame:IsVisible() then
        iMorphToolsMainFrame:Show()
    end
end
SLASH_iMorphTools1 = "/imt"
