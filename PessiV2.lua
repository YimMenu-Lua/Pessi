
local AbstractOption = {    m_visible = true;};
AbstractOption.__index = AbstractOption;

function AbstractOption:GetName()
    return self.m_name or "NOT_FOUND"; 
end

function AbstractOption:IsVisible()
    return self.m_visible and self.m_requirement();
end

function AbstractOption:AddRequirement(func)
    if(func) then 
        self.m_requirement = func;
        return self;
    end
    return nil;
end

local CButton = {};
CButton.__index = CButton;
setmetatable(CButton, AbstractOption);


local CBreak = {};
CBreak.__index = CBreak;
setmetatable(CBreak, AbstractOption);

local CSubmenu = {};
CSubmenu.__index = CSubmenu;
setmetatable(CSubmenu, AbstractOption);

local CStack = {}
CStack.__index = CStack;

local CManager = {};
CManager.__index = CManager;

local CMouseManager = {};
CMouseManager.__index = CMouseManager;

local CRenderer = {};
CRenderer.__index = CRenderer

local SubmenuHandler = {};
SubmenuHandler.__index = SubmenuHandler

local MainMenu = {};
MainMenu.__index = MainMenu;

function CStack:New(items)
    local stack = {top = items and #items or 0, elements = items or {}}
    local Instance = setmetatable(stack, CStack)
    return Instance
end

function CStack:Push(element)
    self.top = self.top + 1
    self.elements[self.top] = element
end

function CStack:Pop()
    if self.top > 0 then
        local element = self.elements[self.top]
        self.top = self.top - 1
        return element
    else
        log.warning("Stack is empty")
        return;
    end
end

function CStack:Top()
    if self.top > 0 then
        return self.elements[self.top]
    else
        log.warning("Stack is empty")
        return nil
    end
end

function CStack:Size()
    return self.top
end


local g_SubmenuHandler = nil;
function SubmenuHandler:New()
    local self = setmetatable({}, SubmenuHandler);
    self.m_current_submenu = nil;
    self.m_submenus = {};
    self.m_submenu_stack = CStack:New();
    self.m_current_option = 1;
    self.m_total_options = 0;
    return self;
end

function SubmenuHandler:Get()
    if(not g_SubmenuHandler) then 
        g_SubmenuHandler = self:New()
        return g_SubmenuHandler
    else
        return g_SubmenuHandler;
    end
end

function SubmenuHandler:SwitchToSubmenu(id)
    for _, submenu in pairs(self.m_submenus) do 
        if(submenu.m_id == id) then
            submenu:Execute();
            if(#submenu.m_options == 0) then 
                submenu:AddOption(CButton:New("Nothing to see here."));
            end
            self.m_current_submenu.m_last_option = self.m_current_option;
            self.m_submenu_stack:Push(submenu);
            self.m_current_option = submenu.m_last_option;
            self.m_current_submenu = submenu;
            return;
        end
    end
end


function SubmenuHandler:SwitchToPrevious()
    if(self.m_submenu_stack:Size() > 1) then 
        self.m_current_submenu.m_last_option = self.m_current_option;
        self.m_submenu_stack:Pop();
        self.m_current_submenu = self.m_submenu_stack:Top();
        self.m_current_option = self.m_current_submenu.m_last_option;
    end
end
function SubmenuHandler:Append(sub)
    if(sub) then
        table.insert(self.m_submenus, sub);
    end
end

function SubmenuHandler:AddSubmenu(name)
    local submenu <const> = CSubmenu:New(name);
    if(self.m_submenu_stack:Size() == 0) then 
        self.m_submenu_stack:Push(submenu);
    end
    table.insert(self.m_submenus, submenu);
    return submenu;
end

function SubmenuHandler:GetSubOnStack()
    if(self.m_submenu_stack:Size() > 0) then
        return self.m_current_submenu;
    end
   return nil;
end

function SubmenuHandler:Init()
    self.m_root = self:AddSubmenu("Pessi");
    self.m_current_submenu = self.m_root;
end


local g_Renderer = nil;
function CRenderer:New()
    local self = setmetatable({}, CRenderer);
    return self;
end

function CRenderer:Get()
    if(not g_Renderer) then 
        g_Renderer = self:New()
        return g_Renderer
    else
        return g_Renderer;
    end
end

function CRenderer:DrawRect(coords, size, color)
    assert(type(coords) == "table", "1st arg(coords) must be a table.");
    assert(type(size) == "table", "2nd arg(size) must be a table.");
    if(color) then 
        assert(type(color) == "table", "3rd arg(color) must be a table.");
    end
    GRAPHICS.DRAW_RECT(coords.x, coords.y, size.w, size.h, color.r or 255, color.g or 255, color.b or 255, color.a or CManager:Get().m_opacity, false);
end


function CRenderer:DrawSprite(textureDict, textureName, coords, size, color, heading);
    assert(type(textureDict) == "string", "1st arg (textureDict) must be a string.")
    assert(type(textureName) == "string", "2nd arg (textureName) must be a string.")
    assert(type(coords) == "table", "3rd arg (coords) must be a table.")
    assert(type(size) == "table", "4th arg (size) must be a table.")
    if(color) then 
        assert(type(color) == "table", "5th arg (color) must be a table.")
    end
    if(heading) then 
        assert(type(heading) == "number", "6th arg (heading) must be a number.")
    end
    GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(textureDict, false);
    GRAPHICS.DRAW_SPRITE(textureDict, textureName, coords.x, coords.y, size.w, size.h, 0, color.r or 255, color.g or 255, color.b or 255, color.a or CManager:Get().m_opacity, false, heading or 0);
end

function CRenderer:DrawText(text, coords, center, scale, color, font)
    assert(type(text) == "string", "1st arg (text) must be a string.")
    assert(type(coords) == "table", "2nd arg (coords) must be a table.")
    assert(type(center) == "boolean", "3rd arg (center) must be a boolean.")
    assert(type(scale) == "number", "4th arg (scale) must be a number.")
    if color then
        assert(type(color) == "table", "5th arg (color) must be a table.")
    end
    if font then
        assert(type(font) == "number", "6th arg (font) must be a number.")
    end
	HUD.SET_TEXT_CENTRE(center or false)
	HUD.SET_TEXT_COLOUR(color.r, color.g, color.b, color.a)
	HUD.SET_TEXT_FONT(font or 4)
	HUD.SET_TEXT_SCALE(scale, scale)
	HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
	HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(text))
	HUD.END_TEXT_COMMAND_DISPLAY_TEXT(coords.x, coords.y, 0)
end


function CRenderer:GetTextWidth(str, font, fontsize)
    assert(type(str) == "string", "1st arg(str) must be a string");
    assert(type(font) == "number", "2nd arg(font) must be a number");
    assert(type(fontsize) == "number", "3rd arg(fontSize) must be a number.")
	HUD.BEGIN_TEXT_COMMAND_GET_SCREEN_WIDTH_OF_DISPLAY_TEXT("STRING");
	HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(str));
	HUD.SET_TEXT_FONT(font);
	HUD.SET_TEXT_SCALE(fontsize, fontsize);
	return HUD.END_TEXT_COMMAND_GET_SCREEN_WIDTH_OF_DISPLAY_TEXT(true);
end

function CRenderer:Lerp(a, b, t)
    assert(type(a) == "number", "1st arg (a) must be a number.");
    assert(type(b) == "number", "2nd arg (b) must be a number.");
    assert(type(t) == "number", "3rd arg (t) must be a number.");
    return a + t * (b - a);
end

local function CalculateAngle(base, min, max)
    assert(type(base) == "number", "1st arg (base) must be a number.");
    assert(type(min) == "number", "2nd arg (min) must be a number.");
    assert(type(max) == "number", "3rd arg (max) must be a number.");
    local mid;
    if (min == max) then return min end;
    mid = max - min;
    base = base - math.floor(base - min / mid) * mid;
    if (base < min) then 
        base = base + mid;
    end
    return base;
end

local glare_direction = 0
function CRenderer:DrawGlare(coords, size)
    assert(type(coords) == "table", "1st arg (coords) must be a table.");
    assert(type(size) == "table", "2nd arg (size) must be a table.");
    local scaleform_handle = GRAPHICS.REQUEST_SCALEFORM_MOVIE_WITH_IGNORE_SUPER_WIDESCREEN("MP_MENU_GLARE");
    local direction = CalculateAngle(CAM.GET_GAMEPLAY_CAM_ROT(2).z, 0, 360);
    if ((glare_direction == 0 or glare_direction - direction > 0.5) or glare_direction - direction < -0.5) then 
        glare_direction = direction;
        GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform_handle, "SET_DATA_SLOT");
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_FLOAT(glare_direction);
        GRAPHICS.END_SCALEFORM_MOVIE_METHOD();
    end
    GRAPHICS.DRAW_SCALEFORM_MOVIE(scaleform_handle, coords.x, coords.y, size.w, size.h,  255, 255, 200, CManager:Get().m_opacity, 0);
end


local g_CManager = nil;
function CManager:New() 
    local self = setmetatable({}, CManager);
    self.m_opacity = 0;
    self.menu_coords = { x=0.8, y=0.2 };
    self.menu_size = { w=0.21, h=0.085 };
    self.menu_color = { r=232, g=91, b=80 };
    self.m_key_hold_timer = 0;
    self.m_input_timer = 0;
    self.m_input_delay = 0.3;
    self.m_last_key = 0;
    self.m_inputs = {};
    self.m_selected = false;
    self.m_option_height = 0.03;
    self.m_max_options = 10;
    self.m_current = 0;
    self.m_background_y = 0;
    self.m_footer_y = 0;
    self.m_registered_inputs = {};

    self.m_directions = {
        ["UP"] = 0,
        ["DOWN"] = 1
    }

    self.m_current_direction = self.m_directions.UP;
    return self;
end

function CManager:Get()
    if(not g_CManager) then 
        g_CManager = self:New()
        return g_CManager
    else
        return g_CManager;
    end
end

function CManager:RenderBackground()
    local options_to_render = math.min(SubmenuHandler:Get().m_total_options, self.m_max_options);
    local target = self.menu_coords.y + self.menu_size.h/2 + ((options_to_render * self.m_option_height)/2)
    self.m_background_y = CRenderer:Get():Lerp(self.m_background_y, target, 0.3);
    if(math.abs(self.m_background_y - target) < 0.8) then 
        self.m_background_y = target;
    end
    CRenderer:Get():DrawRect({ x=self.menu_coords.x, y=self.m_background_y }, {w=self.menu_size.w, h= options_to_render * self.m_option_height }, {r=0, g=0, b=0, a=math.floor(self.m_opacity - 140.25)});
end


function CManager:RenderFooter()
    local options_to_render = math.min(SubmenuHandler:Get().m_total_options, self.m_max_options);
    local target = self.menu_coords.y + self.menu_size.h/2 + 0.028/2 + options_to_render * self.m_option_height;
    self.m_footer_y = CRenderer:Get():Lerp(self.m_footer_y, target, 0.3);
    CRenderer:Get():DrawRect({ x=self.menu_coords.x, y=self.m_footer_y}, {w=self.menu_size.w, h=0.028 }, self.menu_color);
    CRenderer:Get():DrawSprite("commonmenu", "shop_arrows_upanddown", { x=self.menu_coords.x, y=self.menu_coords.y + self.menu_size.h/2 + 0.028/2 + options_to_render * self.m_option_height}, {w = 0.015, h = 0.025}, {r=255, g=255, b=255, a=self.m_opacity})
    local option_list = ("%s | %s"):format(SubmenuHandler:Get().m_current_option, SubmenuHandler:Get().m_total_options)
    CRenderer:Get():DrawText(option_list, {x=self.menu_coords.x - self.menu_size.w/2 - CRenderer:Get():GetTextWidth(option_list, 4, 0.3) + 0.21, y=self.m_footer_y - 0.009}, false, 0.3, {r=255, g=255, b=255, a=self.m_opacity}, 4)
end

function CManager:RenderScroller()
    local current_option = math.min(SubmenuHandler:Get().m_current_option-1, self.m_max_options - 1);
    local target = self.menu_coords.y + self.menu_size.h/2 + self.m_option_height/2 + current_option * self.m_option_height;
    self.m_current = CRenderer:Get():Lerp(self.m_current, target, 0.15);
    CRenderer:Get():DrawRect({x=self.menu_coords.x, y=self.m_current}, {w=self.menu_size.w, h=self.m_option_height}, self.menu_color);
end


function CManager:RenderHeader()
    CRenderer:Get():DrawRect(self.menu_coords, self.menu_size, self.menu_color);
    local title = string.upper(SubmenuHandler:Get().m_current_submenu:GetName());
    local text_width = CRenderer:Get():GetTextWidth(title, 4, 0.9);
    CRenderer:Get():DrawText(title, { x=self.menu_coords.x - self.menu_size.w/2 + (text_width/3) + 0.023, y=self.menu_coords.y + (self.menu_size.h/2) - 0.067 }, true, 0.9, {r=255, g=255, b=255, a=self.m_opacity}, 4)
    if(MainMenu:Get().m_open) then
        CRenderer:Get():DrawGlare({x= self.menu_coords.x + 0.287, y=self.menu_coords.y + 0.38}, {w=self.menu_size.w + 0.6, h=self.menu_size.h + 0.85});
    end
end

function CManager:RegisterInput(key, func)
    self.m_registered_inputs[key] = func;
end

function CManager:InputManager()
    if(MainMenu:Get().m_open) then
        PAD.DISABLE_CONTROL_ACTION(2, 27, true);
    end
    if not PAD.IS_DISABLED_CONTROL_PRESSED(0, self.m_last_key) then
        self.m_key_hold_timer = 0
    end
    self.m_selected = false
    for key, func in pairs(self.m_registered_inputs) do
        if((ImGui.GetTime() - self.m_input_timer) > self.m_input_delay) then
            if PAD.IS_DISABLED_CONTROL_PRESSED(0, key) then
                func()
                self.m_input_timer = ImGui.GetTime()
                if key == self.m_last_key then
                    self.m_key_hold_timer = self.m_key_hold_timer + 1
                else
                    self.m_key_hold_timer = 0
                end
                if self.m_key_hold_timer > 3 then
                    self.m_input_delay = 0.1
                else
                    self.m_input_delay = 0.3
                end
                self.m_last_key = key
            end
        end
    end
end

function CManager:Init()
    self:RegisterInput(173, function()
        if(not MainMenu:Get().m_open) then return end;
        if(SubmenuHandler:Get().m_current_option < SubmenuHandler:Get().m_total_options) then 
            self.m_current_direction = self.m_directions.DOWN;
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_current_option + 1;
        else
            self.m_current_direction = self.m_directions.UP;
            SubmenuHandler:Get().m_current_option = 1
        end
    end)
    self:RegisterInput(188, function()
        if(not MainMenu:Get().m_open) then return end;
        if(SubmenuHandler:Get().m_current_option > 1) then 
            self.m_current_direction = self.m_directions.UP;
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_current_option - 1;
        else
            self.m_current_direction = self.m_directions.DOWN;
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_total_options
        end
    end)
    self:RegisterInput(191, function()
        if(not MainMenu:Get().m_open) then return end;
        self.m_selected = true;
    end)
    self:RegisterInput(194, function()
        if(not MainMenu:Get().m_open) then return end;
        SubmenuHandler:Get():SwitchToPrevious();
    end)
    self:RegisterInput(73, function()
        if(not MainMenu:Get().m_open) then return end;
        CMouseManager:Get():Toggle();
    end)
    self:RegisterInput(166, function()
        MainMenu:Get().m_open = not MainMenu:Get().m_open
        MainMenu:Get().m_just_closed = not MainMenu:Get().m_open
    end)
end


function CSubmenu:New(name)
    local self = setmetatable({}, CSubmenu);
    self.m_options = {};
    self.m_name = name;
    self.m_id = joaat(name);
    self.m_on_update = nil;
    self.m_last_option = 1;
    self.m_requirement = function() return true end;
    return self;
end

function CSubmenu:Render(position)
    local header_y = CManager:Get().menu_coords.y + CManager:Get().menu_size.h/2;
    local option_y = ((position) * CManager:Get().m_option_height) + header_y
    CRenderer:Get():DrawText(self.m_name, { x = CManager:Get().menu_coords.x - CManager:Get().menu_size.w/2 + 0.004, y = option_y}, false, 0.4, {r=255, g=255, b=255, a=CManager:Get().m_opacity}, 4)
    CRenderer:Get():DrawSprite("commonmenu", "arrowright", {x=CManager:Get().menu_coords.x + CManager:Get().menu_size.w/2 - 0.007, y=option_y + 0.015},{w=0.01, h=0.018}, {r=255, g=255, b=255, a=CManager:Get().m_opacity}, 90)
end

function CSubmenu:Execute()
    if(m_on_update) then 
        m_on_update()
    end
end


function CSubmenu:Invoke()
    if(CManager:Get().m_selected) then
        SubmenuHandler:Get():SwitchToSubmenu(self.m_id);
    end
end

function CSubmenu:AddSubmenu(name)
    local sub = self:New(name);
    table.insert(self.m_options, sub);
    SubmenuHandler:Get():Append(sub);
    return sub;
end

function CSubmenu:AddOption(option)
    if(option) then
        table.insert(self.m_options, option)
        return option;
    end
    return nil;
end

function CBreak:New(name)
    local self = setmetatable({}, CBreak);
    self.m_name = name 
    self.m_requirement = function() return true end;
    return self;
end


function CBreak:Render(position)
    local header_y = CManager:Get().menu_coords.y + CManager:Get().menu_size.h/2;
    local option_y = ((position) * CManager:Get().m_option_height) + header_y
    CRenderer:Get():DrawText(self.m_name, { x = CManager:Get().menu_coords.x, y = option_y + 0.005}, true, 0.35, {r=255, g=255, b=255, a=CManager:Get().m_opacity}, 1)
end

function CBreak:Invoke()
    local current_dir = CManager:Get().m_current_direction;
    if(current_dir == CManager:Get().m_directions.UP) then 
        if(SubmenuHandler:Get().m_current_option > 1) then 
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_current_option - 1;
        else
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_total_options;
        end
    elseif(current_dir == CManager:Get().m_directions.DOWN) then 
        if(SubmenuHandler:Get().m_current_option < SubmenuHandler:Get().m_total_options) then 
            SubmenuHandler:Get().m_current_option = SubmenuHandler:Get().m_current_option + 1
        else
            SubmenuHandler:Get().m_current_option = 1;
        end
    end
end

function CButton:New(name)
    local self = setmetatable({}, CButton);
    self.m_name = name 
    self.m_callback = function()end
    self.m_id = joaat(name);
    self.m_requirement = function() return true end;
    return self;
end


function CButton:Render(position)
    local header_y = CManager:Get().menu_coords.y + CManager:Get().menu_size.h/2;
    local option_y = ((position) * CManager:Get().m_option_height) + header_y
    CRenderer:Get():DrawText(self.m_name, { x = CManager:Get().menu_coords.x - CManager:Get().menu_size.w/2 + 0.004, y = option_y}, false, 0.4, {r=255, g=255, b=255, a=CManager:Get().m_opacity}, 4)
end

function CButton:Invoke()
    if(CManager:Get().m_selected) then
        script.run_in_fiber(function(script)
            self.m_callback(script)
        end, self)
    end
end

function CButton:AddFunction(func)
    if(func) then 
        self.m_callback = func;
        return self;
    end
    return nil;
end

local CToggle = {};
CToggle.__index = CToggle;
setmetatable(CToggle, AbstractOption);


function CToggle:New(name)
    local self = setmetatable({}, CToggle);
    self.m_name = name 
    self.m_state = false
    self.m_callback = function()end
    self.m_id = joaat(name)
    self.m_requirement = function() return true end;
    return self;
end


function CToggle:AddFunction(func)
    if(func) then 
        self.m_callback = func
        return self;
    end
end

function CToggle:Render(position)
    local state = self.m_state and {r=0, g=255, b=0, a=CManager:Get().m_opacity} or {r=255, g=0, b=0, a=CManager:Get().m_opacity}
    local header_y = CManager:Get().menu_coords.y + CManager:Get().menu_size.h/2;
    local option_y = (position * CManager:Get().m_option_height) + header_y
    CRenderer:Get():DrawSprite("CommonMenu", "common_medal", { x = CManager:Get().menu_coords.x + CManager:Get().menu_size.w/2 - 0.007, y = option_y + 0.015}, {w=0.015, h=0.02}, state)
    CRenderer:Get():DrawText(self.m_name, { x = CManager:Get().menu_coords.x - CManager:Get().menu_size.w/2 + 0.004, y = option_y}, false, 0.4, {r=255, g=255, b=255, a=CManager:Get().m_opacity}, 4)
end


function CToggle:AddState(state)
    self.m_state = state
    return self;
end

function CToggle:Invoke()
    if(CManager:Get().m_selected) then
        self.m_state = not self.m_state
        script.run_in_fiber(function(script)
            self.m_callback(self, script)
        end, self)
    end
end

local g_MouseManager = nil;
function CMouseManager:New()
    local self = setmetatable({}, CMouseManager);
    self.m_dragged = false;
    self.m_active = false;
    return self;
end

function CMouseManager:Get()
    if(not g_MouseManager) then 
        g_MouseManager = self:New()
        return g_MouseManager;
    else
        return g_MouseManager;
    end
end

function CMouseManager:Toggle()
    self.m_active = not self.m_active
end

function CMouseManager:GetMouseCoords()
    return { x = PAD.GET_DISABLED_CONTROL_NORMAL(2, 239), y = PAD.GET_DISABLED_CONTROL_NORMAL(2, 240) };
end

function CMouseManager:IsMouseInHeader()
    local left =    CManager:Get().menu_coords.x - CManager:Get().menu_size.w/2;
    local right =   CManager:Get().menu_coords.x + CManager:Get().menu_size.w/2;
    local top =     CManager:Get().menu_coords.y + CManager:Get().menu_size.h/2;
    local bottom =  CManager:Get().menu_coords.y - CManager:Get().menu_size.h/2;

    local mouse_coords = self:GetMouseCoords();

    if(mouse_coords.x > right or mouse_coords.x < left) then 
        return false;
    end
    if(mouse_coords.y > top or mouse_coords.y < bottom) then 
        return false;
    end
    return true;
end

function CMouseManager:Tick()
    if(not self.m_active) then 
        return 
    end
    if(self.m_active) then
        HUD.SET_MOUSE_CURSOR_THIS_FRAME();
        PAD.DISABLE_ALL_CONTROL_ACTIONS(0);
    end
    local mouse_x = self:GetMouseCoords().x;
    local mouse_y = self:GetMouseCoords().y;

    if(PAD.IS_DISABLED_CONTROL_PRESSED(2, 18) and self:IsMouseInHeader()) then 
        self.m_dragged = true;
    end

    if(PAD.IS_DISABLED_CONTROL_JUST_RELEASED(2, 18)) then 
        self.m_dragged = false 
    end

    if(self:IsMouseInHeader()) then 
        HUD.SET_MOUSE_CURSOR_STYLE(3);
    else
        HUD.SET_MOUSE_CURSOR_STYLE(0);
    end

    if(self.m_dragged) then 
        HUD.SET_MOUSE_CURSOR_STYLE(4);
        CManager:Get().menu_coords.x = CRenderer:Get():Lerp(CManager:Get().menu_coords.x, mouse_x, 0.05)
        CManager:Get().menu_coords.y = CRenderer:Get():Lerp(CManager:Get().menu_coords.y, mouse_y, 0.05)
    end
end

local g_MainMenu = nil;
function MainMenu:New()
    local self = setmetatable({}, MainMenu);
    self.m_loaded = false;
    self.m_open = true;
    self.m_just_closed = false;
    return self;
end

function MainMenu:Get()
    if(not g_MainMenu) then 
        g_MainMenu = self:New()
        return g_MainMenu;
    else
        return g_MainMenu;
    end
end


local TransactionManager <const> = {};
TransactionManager.__index = TransactionManager

function TransactionManager:New()
    local self = setmetatable({}, TransactionManager);

    self.m_transactions = {
        {label = "15M (Bend Job Limited)", hash = 0x176D9D54},
        {label = "15M (Bend Bonus Limited)", hash = 0xA174F633},
        {label = "7M (Gang Money Limited)", hash = 0xED97AFC1},
        {label = "3.6M (Casino Heist Money Limited)", hash = 0xB703ED29},
        {label = "2.5M (Gang Money Limited)", hash = 0x46521174},
        {label = "2.5M (Island Heist Money Limited)", hash = 0xDBF39508},
        {label = "2M (Heist Awards Money Limited)", hash = 0x8107BB89},
        {label = "2M (Tuner Robbery Money Limited)", hash = 0x921FCF3C},
        {label = "2M (Business Hub Money Limited)", hash = 0x4B6A869C},
        {label = "1M (Avenger Operations Money Limited)", hash = 0xE9BBC247},
        {label = "1M (Daily Objective Event Money Limited)", hash = 0x314FB8B0},
        {label = "1M (Daily Objective Money Limited)", hash = 0xBFCBE6B6},
        {label = "680K (Betting Money Limited)", hash = 0xACA75AAE},
        {label = "500K (Juggalo Story Money Limited)", hash = 0x05F2B7EE},
        {label = "310K (Vehicle Export Money Limited)", hash = 0xEE884170},
        {label = "200K (DoomsDay Finale Bonus Money Limited)", hash = 0xBA16F44B},
        {label = "200K (Action Figures Money Limited)",  hash = 0x9145F938},
        {label = "200K (Collectibles Money Limited)",    hash = 0xCDCF2380},
        {label = "190K (Vehicle Sales Money Limited)",   hash = 0xFD389995}
    }

    return self;
end

---@param hash Int32
---@param category Int32
---@return price Int32
function TransactionManager:GetPrice(hash, category)
    return tonumber(NETSHOPPING.NET_GAMESERVER_GET_PRICE(hash, category, true))
end


---@param hash Int32 
---@param? amount Int32
function TransactionManager:TriggerTransaction(hash, amount)
    globals.set_int(4537212 + 1, 2147483646)
    globals.set_int(4537212 + 7, 2147483647)
    globals.set_int(4537212 + 6, 0)
    globals.set_int(4537212 + 5, 0)
    globals.set_int(4537212 + 3, hash)
    globals.set_int(4537212 + 2, amount or self:GetPrice(hash, 0x57DE404E))
    globals.set_int(4537212, 1)
end

local m_transaction_manager = nil;
function TransactionManager:Get()
    if(not m_transaction_manager) then 
        m_transaction_manager = self:New()
        return m_transaction_manager
    else
        return m_transaction_manager;
    end
end


function MainMenu:Init()
    CManager:Get():Init();
    SubmenuHandler:Get():Init();
    local accepted_warning = false;
    local million_state = false;
    local fifty_state = false;
    local transfer = false;
    local money <const> = SubmenuHandler:Get().m_root:AddSubmenu("Money");
    local util <const> = SubmenuHandler:Get().m_root:AddSubmenu("Utility");

    local function accepted_risks()
        return accepted_warning
    end

    money:AddOption(CButton:New("Click to accept the risks associated with these options.")
        :AddFunction(function()
            accepted_warning = true;
        end)
    )
    money:AddOption(CBreak:New("Loops"):AddRequirement(accepted_risks));
    money:AddOption(CToggle:New("1 Million Loop")
        :AddFunction(function(f, script)
            while(f.m_state) do 
                TransactionManager:Get():TriggerTransaction(0x615762F1)
                script:yield();
            end
        end)
        :AddState(million_state)
        :AddRequirement(accepted_risks)
    )
    money:AddOption(CToggle:New("50K Loop")
        :AddFunction(function(f, script)
            while(f.m_state) do 
                TransactionManager:Get():TriggerTransaction(0x610F9AB4)
                script:yield();
            end
        end)
        :AddState(fifty_state)
        :AddRequirement(accepted_risks)
    )
    money:AddOption(CBreak:New("Delayed"):AddRequirement(accepted_risks));
    for _, value in pairs(TransactionManager:Get().m_transactions) do 
        money:AddOption(CButton:New(value.label)
            :AddFunction(function()
                TransactionManager:Get():TriggerTransaction(value.hash)
            end)
            :AddRequirement(accepted_risks)
        )
    end


    util:AddOption(CToggle:New("Transfer Wallet To Bank")
    :AddFunction(function(f, script)
        while(f.m_state) do 
            NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(stats.get_character_index(), MONEY.NETWORK_GET_VC_WALLET_BALANCE(stats.get_character_index()))
            script:yield();
        end
    end)
        :AddState(transfer)
    )

    self.m_loaded = true;
end

MainMenu:Get():Init();
script.register_looped("MAIN", function (script)
    CManager:Get():InputManager();
    if(MainMenu:Get().m_loaded) then
        CManager:Get():RenderHeader();
        CManager:Get():RenderBackground();
        CManager:Get():RenderFooter();
        CManager:Get():RenderScroller();

        SubmenuHandler:Get().m_total_options = 0;
        local temp = {};
        local sub = SubmenuHandler:Get():GetSubOnStack();
        if(sub ~= nil) then 
            local options = sub.m_options;
            if(#options ~= 0) then 
                for _, option in pairs(options) do 
                    if(option:IsVisible()) then 
                        table.insert(temp, option);
                        SubmenuHandler:Get().m_total_options = SubmenuHandler:Get().m_total_options + 1;
                    end
                end
            end
        end

        local start_idx = math.max(1, SubmenuHandler:Get().m_current_option - CManager:Get().m_max_options+1)
        local end_idx = math.min(#temp, start_idx + CManager:Get().m_max_options-1)

        if(#temp ~= 0) then 
            for i = start_idx, end_idx do 
                temp[i]:Render(i - start_idx)
                if(i == SubmenuHandler:Get().m_current_option) then 
                    temp[i]:Invoke()
                end
            end
        end
    end
end)


script.register_looped("MOUSE_MANAGER", function() CMouseManager:Get():Tick() end);


script.register_looped("FADE_HANDLER", function()
    local target = MainMenu:Get().m_just_closed and 0 or 255
    CManager:Get().m_opacity = CRenderer:Get():Lerp(CManager:Get().m_opacity, target, 0.05)
    CManager:Get().m_opacity = math.floor(math.min(255, math.max(0, CManager:Get().m_opacity)))
end)

