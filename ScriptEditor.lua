local _G = getfenv(0)
local enableDebug = false

local function TableToStr(tbl)
	local tabitems = {}				
	for key,val in pairs(tbl) do
		if type(val) == "table" then
			val = TableToStr(val)
		else
			val = tostring(val)
		end
		table.insert(tabitems, tostring(key).."="..val)
	end
	
	return "{"..table.concat(tabitems,",").."}"
end

local function ArgsToStr(...)
	-- convert a ... argument to a comma separated text list
	local text = nil
	if arg ~= nil then
		local items = {}
		local count = 0
		for i,v in ipairs(arg) do			
			if type(v) == "table" then
				table.insert(items, TableToStr(v) )
			else
				-- anything else and we just force it to string
				table.insert(items, tostring(v))
			end
			count = count + 1
		end
		if count > 0 then
			text = table.concat(items," ")
		end
	end
	return tostring(text)
end

local function debug(...)
	-- local helper to dump to system frame
	if enableDebug == true then
		local text = ArgsToStr(unpack(arg))
		_G["ChatFrame1"]:AddMessage( "|cFF00FF00[sed]|r "..text )	
	end
end

local function dbgcall(fcn, params)
	-- helper to print out function name and call it
	local a = loadstring("return function(...) return "..fcn.."(unpack(arg)) end")
	result = a()(unpack(params))
	cfout("Called "..fcn.. " = "..tostring(result))
	return result
end

local function Scroll(self, scrollValue)

	if IsControlKeyDown() == 1 then
		scrollValue = 10 * scrollValue
	end
	
	local newScroll = self:GetVerticalScroll()-scrollValue
	if newScroll < 0 then 
		newScroll = 0
	end
	if newScroll >= self:GetScrollChild():GetHeight() then
		newScroll = self:GetScrollChild():GetHeight() - 20
	end
	debug("newscroll=",newScroll)
	self:SetVerticalScroll(newScroll)
	self:UpdateScrollChildRect()
	self:GetScrollChild():SetPoint("TOP",self,"TOP", self:GetVerticalScroll() )
	self:GetScrollChild():SetPoint("BOTTOM",self,"BOTTOM")
	debug(tostring(self:GetScrollChild():GetHeight()))
end

local function ScrollToCursor(self, arg1, arg2, arg3, arg4)
	if self.cursor == nil then
		self.cursor = {x = arg1, y = arg2}
	end
	debug("OnCursorChanged:"..arg1..","..arg2..","..arg3..","..arg4)
	-- if the cursor changed y position
	-- calculate if its now outside of visible space, then we will scroll our parent either up or down to accomodate the cursor position
	
	if arg1 ~= self.cursor.x or arg2 ~= self.cursor.y then
		self.cursor = {x = arg1, y = arg2 }
		local vscroll = self:GetParent():GetVerticalScroll()
		local topAdjust = vscroll + self.cursor.y
		local botAdjust = self:GetParent():GetHeight() + topAdjust - arg4
		debug({vscroll=vscroll,cursorY=self.cursor.y,topAdjust=topAdjust,height=self:GetParent():GetHeight(),botAdjust=botAdjust})
		if topAdjust > 0 then
			Scroll(self:GetParent(),topAdjust)
		elseif botAdjust < 0 then
			Scroll(self:GetParent(),botAdjust)
		end
	end
end

-- invisible frame to handle outside clicks
local fout = CreateFrame("Frame", nil, WorldFrame)
fout:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
fout:SetBackdropColor(1,1,1,1)
fout:SetWidth(fout:GetParent():GetWidth()/2)
fout:SetHeight(fout:GetParent():GetHeight()/2)
fout:SetFrameStrata("DIALOG")
fout:SetPoint("CENTER",0,0)
fout:RegisterEvent("ADDON_LOADED")
fout:EnableMouse(true)
fout:RegisterForDrag("LeftButton")
fout:SetMovable()
fout:SetScript("OnDragStart",function()	
	this:StartMoving()
end)
fout:SetScript("OnDragStop",function()
	this:StopMovingOrSizing()
end)
fout:Hide()


local flogScroll = CreateFrame("ScrollFrame", nil, fout)
flogScroll:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
flogScroll:SetBackdropColor(0,0,0,0)
flogScroll:SetPoint("TOP",fout,"TOP",0,-20)
flogScroll:SetPoint("BOTTOM",fout,"BOTTOM")
flogScroll:SetPoint("LEFT",fout,"LEFT")
flogScroll:SetPoint("RIGHT",fout,"RIGHT")
flogScroll:EnableMouseWheel(true)
flogScroll:SetScript("OnMouseWheel",function()
	Scroll(this, arg1*20)
end)

local flog = CreateFrame("EditBox", nil, flogScroll)
flogScroll:SetScrollChild(flog) -- for some reason (tm) this must be called first
flog:SetAutoFocus(false)
flog:SetMultiLine(true)
flog:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
flog:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
flog:SetBackdropColor(0,0,0.5,1)
flog:SetPoint("TOP",flogScroll,"TOP")
flog:SetPoint("BOTTOM",flogScroll,"BOTTOM")
flog:SetScript("OnCursorChanged", function()
	ScrollToCursor(this,arg1,arg2,arg3,arg4)
end)
flog:SetScript("OnEscapePressed", function() 
	this:ClearFocus()
end)
flog:SetScript("OnTabPressed", function() 
	this:Insert("    ")
end)
flog:SetScript("OnEditFocusLost", function(a,b,c,d) 
	this:SetFontObject("GameFontDisable")
end)
flog:SetScript("OnEditFocusGained", function(a,b,c,d) 
	this:SetFontObject("GameFontWhite")	
end)


-- 
local feditScroll = CreateFrame("ScrollFrame", nil, fout)
feditScroll:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
feditScroll:SetBackdropColor(1,0,0,1)
feditScroll:SetPoint("TOP",fout,"TOP",0,-20)
feditScroll:SetPoint("BOTTOM",fout,"BOTTOM")
feditScroll:SetPoint("LEFT",fout,"LEFT")
feditScroll:SetPoint("RIGHT",fout,"RIGHT")
feditScroll:EnableMouseWheel(true)
feditScroll:SetScript("OnMouseWheel",function()
	Scroll(this, arg1*20)
end)

local fedit = CreateFrame("EditBox", nil, feditScroll)
feditScroll:SetScrollChild(fedit) -- for some reason (tm) this must be called first
fedit:SetAutoFocus(false)
fedit:SetMultiLine(true)
fedit:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
fedit:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
fedit:SetBackdropColor(0,0,0,1)
fedit:SetAllPoints(fedit:GetParent())
fedit:SetScript("OnCursorChanged", function()
	ScrollToCursor(this,arg1,arg2,arg3,arg4)
end)
fedit:SetScript("OnEscapePressed", function() 
	this:ClearFocus()
end)
fedit:SetScript("OnTabPressed", function() 
	this:Insert("    ")
end)
fedit:SetScript("OnEditFocusLost", function(a,b,c,d) 
	this:SetFontObject("GameFontDisable")
end)
fedit:SetScript("OnEditFocusGained", function(a,b,c,d) 
	this:SetFontObject("GameFontWhite")
end)


local bnExec = CreateFrame("Button", "bnExec", fout)
bnExec:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
bnExec:SetBackdropColor(0.1,0.1,0.1,1)
bnExec:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
bnExec:SetPoint("TOPLEFT", fout, "TOPLEFT")
bnExec:SetWidth(50)
bnExec:SetHeight(20)
bnExec:SetText("Exec")
bnExec:SetScript("OnClick",function()
	ScriptEditorDB = {
		editorText = fedit:GetText()
	}
	fedit:ClearFocus()
	feditScroll:Hide()
	flog:SetText("")
	flogScroll:Show()
	
	
	local pfcn = [[-- ScriptEditor Local Scope --
	function print(...)
		ScriptEditor:Log(unpack(arg))
	end]]
	
	local f = loadstring(pfcn.."\n"..fedit:GetText())
	if f ~= nil then
		f()
	else
		flog:SetText("ERROR: Unable to parse script")
	end
end)

local bnPgEdit = CreateFrame("Button", "bnPgEdit", fout)
bnPgEdit:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
bnPgEdit:SetBackdropColor(0.1,0.1,0.1,1)
bnPgEdit:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
bnPgEdit:SetPoint("LEFT", bnExec, "RIGHT", -1)
bnPgEdit:SetWidth(50)
bnPgEdit:SetHeight(20)
bnPgEdit:SetText("Edit")
bnPgEdit:SetScript("OnClick",function()
	feditScroll:Show()
	flogScroll:Hide()
end)

local bnPgLog = CreateFrame("Button", "bnPgLog", fout)
bnPgLog:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
bnPgLog:SetBackdropColor(0.1,0.1,0.1,1)
bnPgLog:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
bnPgLog:SetPoint("LEFT", bnPgEdit, "RIGHT", -1)
bnPgLog:SetWidth(50)
bnPgLog:SetHeight(20)
bnPgLog:SetText("Output")
bnPgLog:SetScript("OnClick",function()
	feditScroll:Hide()
	flogScroll:Show()	
end)

local bnClose = CreateFrame("Button", "bnClose", fout)
bnClose:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground"})
bnClose:SetBackdropColor(0.1,0.1,0.1,1)
bnClose:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
bnClose:SetPoint("LEFT", bnPgLog, "RIGHT", -1)
bnClose:SetWidth(50)
bnClose:SetHeight(20)
bnClose:SetText("Close")
bnClose:SetScript("OnClick",function()
	fout:Hide()
end)


local function TableToStr(tbl)
	local tabitems = {}				
	for key,val in pairs(tbl) do
		if type(val) == "table" then
			val = TableToStr(val)
		else
			val = tostring(val)
		end
		table.insert(tabitems, tostring(key).."="..val)
	end
	
	return "{"..table.concat(tabitems,",").."}"
end

local function ArgsToStr(...)
	-- convert a ... argument to a comma separated text list
	local text = nil
	if arg ~= nil then
		local items = {}
		local count = 0
		for i,v in ipairs(arg) do			
			if type(v) == "table" then
				table.insert(items, TableToStr(v) )
			else
				-- anything else and we just force it to string
				table.insert(items, tostring(v))
			end
			count = count + 1
		end
		if count > 0 then
			text = table.concat(items,",")
		end
	end
	return tostring(text)
end

-- globally exposed namespace
ScriptEditor = {}
-- function that will print to the log
ScriptEditor.Log = function(...)
	-- remove the self argument if called with :
	if arg[1] == ScriptEditor then
		table.remove(arg, 1)
	end
	local newText = flog:GetText() .. ArgsToStr(unpack(arg)) .. "\n"
	flog:SetText(newText)
end

ScriptEditor.Clear = function()
	flog:SetText("")
end


SLASH_SCRIPTEDITOR_SLASH1 = "/sed"
SlashCmdList["SCRIPTEDITOR_SLASH"] = function()	
	feditScroll:Show()
	fedit:SetFocus()
	flogScroll:Hide()
	fout:Show()
end


fout:SetScript("OnEvent",function()
	if event == "ADDON_LOADED" and arg1 == "ScriptEditor" then
		debug(ScriptEditorDB)
		fedit:SetText(ScriptEditorDB.editorText)
	end
end)
