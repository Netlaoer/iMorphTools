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
    local old = DEFAULT_CHAT_FRAME.AddMessage
    DEFAULT_CHAT_FRAME.AddMessage = function() end
    local ok, err = pcall(func, ...)
    DEFAULT_CHAT_FRAME.AddMessage = old
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
    local selectMountBtn, _, _, _ = CreateSelectRow(mainFrame, preWidget, {
        selectName = "SelectMountBtn", selectLabel = "点击坐骑改模",
        selectTooltip = "点击选择坐骑模型直接生效",
        menuName = "MountSelectMenu",
        data = IMT.MountIDs, order = IMT.MountOrder,
        onSelect = SetMount,
        editBoxName = "editBox3", editBoxDefault = "21974",
        editBoxSavedVar = "MountModelID",
        manualName = "buttonMountChange", manualLabel = "手动坐骑改模",
        manualTooltip = "输入坐骑模型ID后点击修改",
        onManual = SetMount,
    })
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
        if level ~= 1 then return end
        local info = UIDropDownMenu_CreateInfo()
        for _, spellName in ipairs(IMT.SpellOrder) do
            local spellID = IMT.SpellNames[spellName]
            if spellID then
                info.text = spellName
                info.value = spellID
                info.checked = (spellName == savedSelectedSpellName)
                info.func = function()
                    savedSelectedSpellName = spellName
                    iMorphToolsDBC.selectedSpellName = spellName
                    UIDropDownMenu_SetText(dropdownSpells, spellName)
                end
                UIDropDownMenu_AddButton(info)
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
    local editBoxPK = CreateFrame("EditBox", "editBoxPK", mainFrame, "BJ_InputBoxTemplate")
    editBoxPK:SetSize(80, 30)
    editBoxPK:SetPoint("TOPLEFT", preWidget, "BOTTOMLEFT", 25, -15)
    editBoxPK:SetText(iMorphToolsDBC.PlayKitID or "36399")
    editBoxPK:SetAutoFocus(false)
    editBoxPK:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.PlayKitID = self:GetText()
    end)

    local editBoxPKOpt = CreateFrame("EditBox", "editBoxPKOpt", mainFrame, "BJ_InputBoxTemplate")
    editBoxPKOpt:SetSize(40, 30)
    editBoxPKOpt:SetPoint("LEFT", editBoxPK, "RIGHT", 10, 0)
    editBoxPKOpt:SetText(iMorphToolsDBC.PlayKitOpt or "1")
    editBoxPKOpt:SetAutoFocus(false)
    editBoxPKOpt:SetScript("OnTextChanged", function(self)
        iMorphToolsDBC.PlayKitOpt = self:GetText()
    end)

    local buttonPK = CreateFrame("Button", "buttonPK", mainFrame, "UIPanelButtonTemplate")
    buttonPK:SetSize(90, 30)
    buttonPK:SetPoint("LEFT", editBoxPKOpt, "RIGHT", 5, 0)
    buttonPK:SetText("视觉套件")
    SetupTooltip(buttonPK, "执行 .playkit 命令\n左侧输入套件ID，右侧输入值(0=动态 1=静态)")

    buttonPK:SetScript("OnClick", function()
        local kitID = editBoxPK:GetText()
        local opt = editBoxPKOpt:GetText()
        if kitID and kitID ~= "" then
            local editBox = ChatFrame1EditBox
            editBox:SetText(".playkit " .. kitID .. " " .. (opt or "1"))
            ChatEdit_SendText(editBox, 0)
        end
    end)

    -- 套件ID标签
    local pkLabel1 = mainFrame:CreateFontString()
    pkLabel1:SetPoint("BOTTOMLEFT", editBoxPK, "TOPLEFT", 0, 1)
    pkLabel1:SetFontObject(GameFontNormalSmall)
    pkLabel1:SetText("视觉套件ID")

    local pkLabel2 = mainFrame:CreateFontString()
    pkLabel2:SetPoint("BOTTOMLEFT", editBoxPKOpt, "TOPLEFT", 0, 1)
    pkLabel2:SetFontObject(GameFontNormalSmall)
    pkLabel2:SetText("值")

    preWidget = editBoxPK

    -- 版本文字
    local version = mainFrame:CreateFontString()
    version:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8)
    version:SetFontObject(GameFontNormal)
    version:SetText("|cFFA335EEiMorphTools|cFFFF7D0Aby|cFFABD473聖殿十字军")
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
