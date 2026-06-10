-- 如果原始 iMorph 已初始化则保留，否则创建
IMorphInfo = IMorphInfo or {
	call = nil,
	parseTextOld = nil,
	frame = nil,
}

-- ============================================
-- 常量定义（缓存，避免每次调用重新创建）
-- ============================================

local CUSTOMIZATION_NAMES = {
	'aquaticform','armbands','armorcolor','armorstyle','armspikes','armupgrade','beard','bearform','blindfold','blindfolds',
	'bodymarkings','bodypaint','bodypaintcolor','bodypattern','bodyscales','bodysize','bodytattoo','bracelets','breastplate',
	'breechcloth','brow','catform','cheek','cheekbone','chest','chestspikes','chin','chindecoration','circlet','crest',
	'eargauge','earringcolor','earrings','ears','eyebrows','eyecolor','eyes','eyesight','eyestyle','face','facefeatures',
	'facejewelry','facemarkings','facepaint','facepaintcolor','facepattern','faceshape','facetattoo','facialhair','feather',
	'features','feet','flightform','flower','foremane','furcolor','grime','hair','haircolor','hairdecoration','hairhighlights',
	'hairstyle','headdress','helm','horncolor','horndecoration','hornjewelry','hornmarkings','horns','hornstyle','hornwraps',
	'hunched','jawdecoration','jawfeatures','jawjewelry','jewelrycolor','legspikes','legupgrade','lowerarms','luminoushands',
	'makeup','markings','markingscolor','modification','moonkinform','mustache','necklace','nose','nosepiercing','nosering',
	'paint','paintcolor','pattern','piercing','piercings','primarycolor','rune','scalecolor','scalemarkings','scalepattern',
	'scars','secondarycolor','secondarycolorstrength','secondaryhaircolor','secondaryskincolor','shoulders','sideburns',
	'skincolor','skintype','snout','tail','taildecoration','tailridge','tattoo','tattoocolor','tattoostyle','tendrils',
	'tentacles','thighs','throat','travelform','tusks','underclothesbottom','underclothescolor','underclothestop','upperarms',
	'upright','vinecolor','vines','waist','warpaint','warpaintcolor','wingdecoration',
}

-- 哈希表，用于 O(1) 查找
local CUSTOMIZATION_SET = {}
for _, v in ipairs(CUSTOMIZATION_NAMES) do
	CUSTOMIZATION_SET[v] = true
end

-- ============================================
-- 参数校验辅助
-- ============================================

local function checkArgs(args, types)
	for i, t in ipairs(types) do
		local arg = args[i]
		if t == "number" then
			if tonumber(arg) == nil then return false end
		elseif t == "string" then
			if tostring(arg) == nil then return false end
		elseif t == "true" then
			-- always pass
		end
	end
	return true
end

-- ============================================
-- 命令路由表（命令 + 参数校验 + 执行函数 合一）
-- ============================================

-- 预计算的 help 文本（一次拼接，避免 60+ 次 print）
local HELP_TEXT = [[|cFFDC143CiMorph|r commands:
  .dir
  .site
  .discord
  .reset
  .unload
  .disablesm
  .enablesm
  .gender
  .scale |cFFCCCCCC<0.5-3.0>|r
  .scalepet |cFFCCCCCCscale>|r
  .morph |cFFCCCCCC<display id>|r
  .morphpet |cFFCCCCCC<display id>|r
  .race |cFFCCCCCC<1-77> <form 0-1>|r
  .mount |cFFCCCCCC<display id> | <1 ground, 2 flying>|r
  .item |cFFCCCCCC<1-19> <item id> <version> <secondary appearance>|r
  .itemset |cFFCCCCCC<itemset id> <version>|r
  .transmog |cFFCCCCCC<transmog id> <version>|r
  .enchant |cFFCCCCCC<1-2> <enchant id>|r
  .itemswap |cFFCCCCCC<item id> <item id>|r
  .title |cFFCCCCCC<0-128>|r
  .customtitle |cFFCCCCCC<title text> <0-1>|r
  .medal |cFFCCCCCC<0-8>|r
  .customization |cFFCCCCCC<name> <id>|r
  .setcustomization |cFFCCCCCC<name> <id>|r
  .shapeshift |cFFCCCCCC<form id> <display id>|r
  .spell |cFFCCCCCC<spell id> <spell id>|r
  .spellvisual |cFFCCCCCC<spell visual id> <spell visual id>|r
  .spellvisualkit |cFFCCCCCC<spell visual kit id> <spell visual kit id>|r
  .spellvisualkitmodelattach |cFFCCCCCC<spell visual kit model id> <spell visual kit model id>|r
  .spellmissile |cFFCCCCCC<spell missile id> <spell missile id>|r
  .visualeffect |cFFCCCCCC<spell effect id> <spell effect id>|r
  .playeffect |cFFCCCCCC<effect id> <positioner id>|r
  .playkit |cFFCCCCCC<effect id> <option id>|r
  .playpeteffectkit |cFFCCCCCC<effect id> <option id>|r
  .loadingscreen |cFFCCCCCC<loading screen id>|r
  .light |cFFCCCCCC<light id>|r
  .screeneffect |cFFCCCCCC<screen effect id>|r
  .weather |cFFCCCCCC<weatherId> <0.0-1.0>|r
  .time |cFFCCCCCC<hours> <minutes>|r
  .exp
  .logging
  .console
  .mog |cFFCCCCCC<name>|r
  .mogs
  .mogreload]]

-- 无参数命令（格式：{func}）
local noArgCommands = {
	help      = function() print(HELP_TEXT) end,
	reset     = ResetIds,
	disablesm = function() SetFlag(2, 0) end,
	enablesm  = function() SetFlag(2, 1) end,
	gender    = SetGender,
	helmshow  = HelmShow,
	mogreload = ReloadMog,
	mogs      = ListMogs,
}

-- 命令名 → iMorphMiddleware 字符串映射（循环生成）
do
	local delegateList = {
		'dir', 'exp', 'unload', 'site', 'discord', 'health', 'debug',
	}
	for _, cmd in ipairs(delegateList) do
		noArgCommands[cmd] = function() iMorphMiddleware(cmd) end
	end
end

-- 单参数命令（格式：{func, validatorType}）
-- validatorType: "number" | "string" | "true" (即永远通过)
local singleArgCommands = {
	console    = {SetConsole, "true"},
	menu       = {SetMenu, "true"},
	mog        = {SetMog, "string"},
	scale      = {SetScale, "number"},
	scalepet   = {SetScalePet, "number"},
	morph      = {Morph, "number"},
	morphpet   = {MorphPet, "number"},
	class      = {SetClass, "number"},
	medal      = {SetMedal, "number"},
	loadingscreen = {SetLoadingScreen, "number"},
	light      = {SetLightParam, "number"},
	screeneffect = {SetScreenEffect, "number"},
	npc        = {MorphNpc, "true"},
}

-- 多参数命令（格式：{func, validatorTypes...} 或特殊处理枚举）
local multiArgCommands = {
	customization = {Customizations, {"true"}},
	cust          = {Customizations, {"true"}},
	race          = {SetRace, {"number"}},
	item          = {SetItem, {"number"}},
	itemset       = {function(a1, a2) SetItemSet(tonumber(a1), tonumber(a2)) end, {"number"}},
	transmog      = {function(a1, a2) SetTransmogSet(tonumber(a1), tonumber(a2)) end, {"number"}},
	outfit        = {function(a1, a2) SetOutfit(tonumber(a1), tonumber(a2)) end, {"number"}},
	mount         = {function(a1, a2) SetMount(tonumber(a1), tonumber(a2)) end, {"true"}},
	log           = {SetLogging, {"true"}},
	shapeshift    = {SetShapeshiftForm, {"number", "number"}},
	weather       = {SetWeather, {"number", "number"}},
	time          = {SetTime, {"number", "number"}},
	spell         = {SetSpell, {"number", "number"}},
	spellvisual   = {SetSpellVisual, {"number", "number"}},
	spellvisualkit = {SetSpellVisualKit, {"number", "number"}},
	visualeffect  = {SetVisualEffect, {"number", "number"}},
	spellvisualkitmodelattach = {SetSpellvisualkitmodelattach, {"true"}},
	itemswap      = {SetItemSwap, {"number", "number"}},
	playeffect    = {PlayEffect, {"number"}},
	playkit       = {PlayEffectKit, {"number"}},
	playpetkit    = {function(a1, a2) PlayPetEffectKit(a1, a2, nil) end, {"number"}},
	title         = {SetTitle, {"number"}},
	customtitle   = {SetCustomTitleEvent, {"string"}},
}

-- enchant 特殊处理
local function handleEnchant(a1, a2)
	local slot = tonumber(a1)
	if slot == 1 then
		SetEnchant(16, a2)
	elseif slot == 2 then
		SetEnchant(17, a2)
	end
end

-- ============================================
-- 聊天输入钩子（拦截 .xxx 格式的命令）
-- ============================================

hooksecurefunc("ChatEdit_ParseText", function(chatEntry, send)
	if send == 1 then
		local txt = chatEntry:GetText()
		if txt and txt:sub(1,1) == '.' and txt:len() > 3 and txt:sub(2, 2):match('%a') then
			iMorphChatHandler(txt)
			chatEntry:SetText("")
		end
	end
end)

-- ============================================
-- 命令处理器（使用查找表，O(1) 路由）
-- ============================================

function iMorphChatHandler(msg, ...)
	local command, arg = strsplit(' ', msg:sub(2), 2)

	-- 1. 无参数命令
	if noArgCommands[command] then
		noArgCommands[command]()
		return
	end

	-- 2. 自定义类型命令（customization 名称匹配）
	if CUSTOMIZATION_SET[command] and tonumber(arg) ~= nil then
		SetCustomization(command, arg)
		return
	end

	-- 3. 单参数命令（arg 存在）
	if arg then
		if singleArgCommands[command] then
			local entry = singleArgCommands[command]
			if checkArgs({arg}, {entry[2]}) then
				entry[1](arg)
				return
			end
		end

		-- 4. 多参数命令
		local arg1, arg2, arg3, arg4 = strsplit(' ', arg, 4)

		if command == 'enchant' then
			if checkArgs({arg1, arg2}, {"number", "number"}) then
				handleEnchant(arg1, arg2)
			end
			return
		end

		if multiArgCommands[command] then
			local entry = multiArgCommands[command]
			if checkArgs({arg1, arg2, arg3}, entry[2]) then
				entry[1](arg1, arg2, arg3, arg4)
			end
			return
		end
	else
		-- 5. 无 arg 但有特殊处理
		if command == 'customization' then
			Customizations()
			return
		end
	end
end

-- ============================================
-- 核心函数
-- ============================================

function iMorphSetup()
	IMorphInfo.call = IMorphInfo.call or _G[string.char(67, 108, 111, 115, 101, 84, 114, 97, 100, 101)]
end

function iMorphMiddleware(command, ...)
	iMorphSetup()
	IMorphInfo.call(command, ...)
end

function iMorphCustomization()
	return CUSTOMIZATION_NAMES
end

function iMorphContains(table, val)
	return CUSTOMIZATION_SET[val] == true
end

-- ============================================
-- 包装函数（全局导出，供 UI 调用）
-- ============================================

function SetShapeshiftForm(...) iMorphMiddleware('shapeshift', ...) end
function SetEnchant(...) iMorphMiddleware('enchant', ...) end
function SetItem(...) iMorphMiddleware('item', ...) end
function ResetIds() iMorphMiddleware('reset') end
function SetFlag(...) iMorphMiddleware('flag', ...) end
function SetWeather(...) iMorphMiddleware('weather', ...) end
function SetTime(...) iMorphMiddleware('time', ...) end
function SetConsole(...) iMorphMiddleware('console', ...) end
function SetScale(...) iMorphMiddleware('scale', ...) end
function SetScalePet(...) iMorphMiddleware('scalepet', ...) end
function Morph(...) iMorphMiddleware('morph', ...) end
function MorphPet(...) iMorphMiddleware('morphpet', ...) end
function MorphNpc(...) iMorphMiddleware('npc', ...) end
function SetGender() iMorphMiddleware('gender') end
function Customizations(...) iMorphMiddleware('customization', ...) end
function SetRace(...) iMorphMiddleware('race', ...) end
function SetLogging(...) iMorphMiddleware('logging', ...) end
function SetItemSet(...) iMorphMiddleware('itemset', ...) end
function SetTransmogSet(...) iMorphMiddleware('transmog', ...) end
function SetOutfit(...) iMorphMiddleware('outfit', ...) end
function SetMount(...) iMorphMiddleware('mount', ...) end
function SetTitle(...) iMorphMiddleware('title', ...) end
function SetCustomTitleEvent(...) iMorphMiddleware('customtitle', ...) end
function SetClass(...) iMorphMiddleware('class', ...) end
function SetMedal(...) iMorphMiddleware('medal', ...) end
function SetCustomization(...) iMorphMiddleware('setcustomization', ...) end
function SetSpell(...) iMorphMiddleware('spell', ...) end
function SetSpellVisual(...) iMorphMiddleware('spellvisual', ...) end
function SetSpellVisualKit(...) iMorphMiddleware('spellvisualkit', ...) end
function SetSpellvisualkitmodelattach(...) iMorphMiddleware('spellvisualkitmodelattach', ...) end
function SetVisualEffect(...) iMorphMiddleware('visualeffect', ...) end
function SetLoadingScreen(...) iMorphMiddleware('loadingscreen', ...) end
function SetLightParam(...) iMorphMiddleware('light', ...) end
function SetScreenEffect(...) iMorphMiddleware('screeneffect', ...) end
function PlayEffect(...) iMorphMiddleware('playeffect', ...) end
function PlayEffectKit(...) iMorphMiddleware('playeffectkit', ...) end
function PlayPetEffectKit(...) iMorphMiddleware('playpeteffectkit', ...) end
function SetItemSwap(...) iMorphMiddleware('itemswap', ...) end
function SetMenu(...) iMorphMiddleware('menu', ...) end
function HelmShow() iMorphMiddleware('helmshow') end
function SetMog(...) iMorphMiddleware('mog', ...) end
function ListMogs() iMorphMiddleware('mogs') end
function ReloadMog() iMorphMiddleware('mogreload') end
