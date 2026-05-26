-- Write your code here.
local function YourFunction()
  print("|cffffff00欢迎使用iMorphTools改模工具，点击小地图图标或者使用/imt命令打开主界面|r")
end

local function onPlayerLogin(self, event, ...)
  if event == "PLAYER_LOGIN" then
      C_Timer.After(2, YourFunction) -- 将 YourFunction 延迟 2 秒执行
  end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", onPlayerLogin)