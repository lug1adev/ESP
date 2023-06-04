assert(Drawing, "missing dependency: 'Drawing'");

-- variables
local lib = {
    name = true,
    boxOutline = true
    box = true,
    healthOutline = true
    health = true
}
local players = game:GetService("Players");
local runService = game:GetService("RunService");
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local cache = {};

-- constants
local BOX_OUTLINE_COLOR = Color3.new(0, 0, 0);
local BOX_COLOR = Color3.new(1,0,0);
local NAME_COLOR = Color3.new(1,1,1);
local HEALTH_OUTLINE_COLOR = Color3.new(0, 0, 0);
local HEALTH_HIGH_COLOR = Color3.new(0, 1, 0);
local HEALTH_LOW_COLOR = Color3.new(1, 0, 0);
local CHAR_SIZE = Vector2.new(4, 6);

-- utils
local function floor2(v)
    return Vector2.new(math.floor(v.X), math.floor(v.Y));
end

-- functions
local function createEsp(player)
    local boxOutline = Drawing.new("Square");
    boxOutline.Color = BOX_OUTLINE_COLOR;
    boxOutline.Thickness = 3;
    boxOutline.Filled = false;

    local box = Drawing.new("Square");
    box.Color = BOX_COLOR;
    box.Thickness = 1;
    box.Filled = false;

    local name = Drawing.new("Text");
    name.Color = NAME_COLOR;
    name.Font = (syn and not RectDynamic) and 2 or 1;
    name.Outline = true;
    name.Center = true;
    name.Size = 13;

    local healthOutline = Drawing.new("Line");
    healthOutline.Thickness = 3;
    healthOutline.Color = HEALTH_OUTLINE_COLOR;

    local health = Drawing.new("Line");
    health.Thickness = 1;

    cache[player] = {
        box = box,
        boxOutline = boxOutline,
        name = name,
        healthOutline = healthOutline,
        health = health
    };
end

local function removeEsp(player)
    local esp = cache[player];
    if not esp then return end

    for _, drawing in pairs(esp) do
        drawing:Remove();
    end

    cache[player] = nil;
end

local function updateEsp()
    for player, esp in pairs(cache) do
        local character, team = player.Character, player.Team;
        if character and (not team or team ~= localPlayer.Team) then
            local cframe = character:GetModelCFrame();
            local screen, onScreen = camera:WorldToViewportPoint(cframe.Position);

            if onScreen then
                local frustumHeight = math.tan(math.rad(camera.FieldOfView * 0.5)) * 2 * screen.Z;
                local size = camera.ViewportSize.Y / frustumHeight * CHAR_SIZE;
                local position = Vector2.new(screen.X, screen.Y);

                esp.boxOutline.Size = floor2(size);
                esp.boxOutline.Position = floor2(position - size * 0.5);
                esp.boxOutline.Visible = lib.boxOutline

                esp.box.Size = esp.boxOutline.Size;
                esp.box.Position = esp.boxOutline.Position;
                esp.box.Visible = lib.box

                esp.name.Text = string.lower(player.Name);
                esp.name.Position = floor2(position - Vector2.yAxis * (size.Y * 0.5 + esp.name.TextBounds.Y + 2));
                esp.name.Visible = lib.name

                local humanoid = character:FindFirstChildOfClass("Humanoid");
                local health = (humanoid and humanoid.Health or 100) / 100;

                esp.healthOutline.From = floor2(position - size * 0.5) - Vector2.xAxis * 5;
                esp.healthOutline.To = floor2(position - size * Vector2.new(0.5, -0.5)) - Vector2.xAxis * 5;
                esp.healthOutline.Visible = lib.healthOutline

                esp.health.From = esp.healthOutline.To;
                esp.health.To = floor2(esp.healthOutline.To:Lerp(esp.healthOutline.From, health));
                esp.health.Color = HEALTH_LOW_COLOR:Lerp(HEALTH_HIGH_COLOR, health);
                esp.health.Visible = lib.health

                esp.healthOutline.From -= Vector2.yAxis;
                esp.healthOutline.To += Vector2.yAxis;
            end

            for _, drawing in pairs(esp) do
                drawing.Visible = onScreen;
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false;
            end
        end
    end
end

lib.CreateESP = createEsp
lib.RemoveESP = removeEsp
lib.UpdateESP = updateEsp
return lib
