local Players = game:GetService("Players")
local VoiceChatService = game:GetService("VoiceChatService")
local VoiceChatInternal = game:GetService("VoiceChatInternal")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local autoRejoin = false
local baseplate, followBaseplate
local baseplateVisible = false
local followBaseplateEnabled = false
local rainbowEnabled = false
local hue, rainbowSpeed = 0, 1
local baseplateColor = Color3.new(0.5, 0.5, 0.5)
local baseplateTransparency = 0.3
local baseplateSize = Vector3.new(512, 1, 512)
local baseplateYPosition = -0.5
local material = Enum.Material.SmoothPlastic

-- Shader-related variables
local ShaderInstances = {}
local BlurEffect = Instance.new("BlurEffect", Lighting)
BlurEffect.Size = 0
local motionBlurEnabled = false
local blurIntensityFactor = 5
local rainbowHue = 0

local DefaultValues = {
    ClockTime = 12,
    Brightness = 2,
    Ambient = Color3.fromRGB(127, 127, 127),
    OutdoorAmbient = Color3.fromRGB(127, 127, 127),
    BloomIntensity = 0.3,
    BlurSize = 5,
    SunRaysIntensity = 0.1,
    Saturation = 0.25,
    AtmosphereDensity = 0.3,
    AtmosphereColor = Color3.fromRGB(255, 255, 255),
    RainbowEnabled = false,
    RainbowSpeed = .5
}

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "PoopyPants Enhancement Suite",
    LoadingTitle = "Loading farts...",
    LoadingSubtitle = "by Artifaqt",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RobloxEnhancer",
        FileName = "Settings"
    },
    KeySystem = false
})
---------------------------------------------------
-- Voice Chat Tab
---------------------------------------------------
local VCTab = Window:CreateTab("Voice Chat", "mic")

VCTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(Value)
        autoRejoin = Value
    end
})

VCTab:CreateButton({
    Name = "Join Voice Chat",
    Callback = function()
        VoiceChatService:joinVoice()
    end
})

VCTab:CreateButton({
    Name = "Leave Voice Chat",
    Callback = function()
        VoiceChatService:leaveVoice()
    end
})

VoiceChatInternal.LocalPlayerModerated:Connect(function()
    if autoRejoin then
        VoiceChatService:leaveVoice()
        task.wait(1)
        VoiceChatService:joinVoice()
    end
end)

---------------------------------------------------
-- Baseplate Tab
---------------------------------------------------
local BaseplateTab = Window:CreateTab("Baseplate", "grid-3x3")

local function updateBaseplate()
    if baseplate then
        baseplate.Size = baseplateSize
        baseplate.Position = Vector3.new(0, baseplateYPosition, 0)
        baseplate.Color = baseplateColor
        baseplate.Transparency = baseplateTransparency
        baseplate.Material = material
        baseplate.TopSurface = Enum.SurfaceType.Smooth
    end
    if followBaseplate then
        followBaseplate.Size = Vector3.new(baseplateSize.X, 1, baseplateSize.Z)
        local pos = followBaseplate.Position
        followBaseplate.Position = Vector3.new(pos.X, baseplateYPosition, pos.Z)
        followBaseplate.Color = baseplateColor
        followBaseplate.Transparency = baseplateTransparency
        followBaseplate.Material = material
        followBaseplate.TopSurface = Enum.SurfaceType.Smooth
    end
end

local function createBaseplate()
    if not baseplate then
        baseplate = Instance.new("Part")
        baseplate.Anchored = true
        baseplate.Name = "CustomBaseplate"
    end
    updateBaseplate()
    baseplate.Parent = Workspace
end

local function createFollowBaseplate()
    if not followBaseplate then
        followBaseplate = Instance.new("Part")
        followBaseplate.Anchored = true
        followBaseplate.Name = "FollowBaseplate"
        followBaseplate.Parent = Workspace
        updateBaseplate()
    end
end

RunService.RenderStepped:Connect(function()
    if followBaseplateEnabled and followBaseplate and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = localPlayer.Character.HumanoidRootPart.Position
        followBaseplate.Position = Vector3.new(pos.X, baseplateYPosition, pos.Z)
    end
    if rainbowEnabled then
        hue = (tick() * rainbowSpeed % 5) / 5
        baseplateColor = Color3.fromHSV(hue, 1, 1)
        updateBaseplate()
    end
end)

BaseplateTab:CreateToggle({
    Name = "Toggle Fixed Baseplate",
    CurrentValue = false,
    Flag = "FixedBaseplate",
    Callback = function(Value)
        baseplateVisible = Value
        if baseplateVisible then
            createBaseplate()
        elseif baseplate then
            baseplate.Parent = nil
        end
    end
})

BaseplateTab:CreateToggle({
    Name = "Follow Player Baseplate",
    CurrentValue = false,
    Flag = "FollowBaseplate",
    Callback = function(Value)
        followBaseplateEnabled = Value
        if followBaseplateEnabled then
            createFollowBaseplate()
        elseif followBaseplate then
            followBaseplate:Destroy()
            followBaseplate = nil
        end
    end
})

BaseplateTab:CreateColorPicker({
    Name = "Baseplate Color",
    Color = baseplateColor,
    Flag = "BaseplateColor",
    Callback = function(Value)
        baseplateColor = Value
        updateBaseplate()
    end
})

BaseplateTab:CreateToggle({
    Name = "Enable Rainbow Color",
    CurrentValue = false,
    Flag = "RainbowColor",
    Callback = function(Value)
        rainbowEnabled = Value
    end
})

BaseplateTab:CreateSlider({
    Name = "Rainbow Speed",
    Range = {0.1, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Flag = "RainbowSpeed",
    Callback = function(Value)
        rainbowSpeed = Value
    end
})

BaseplateTab:CreateSlider({
    Name = "Baseplate Opacity",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 1 - baseplateTransparency,
    Flag = "BaseplateOpacity",
    Callback = function(Value)
        baseplateTransparency = 1 - Value
        updateBaseplate()
    end
})

BaseplateTab:CreateInput({
    Name = "Baseplate Size X",
    PlaceholderText = tostring(baseplateSize.X),
    RemoveTextAfterFocusLost = false,
    NumbersOnly = true,
    Flag = "SizeX",
    Callback = function(Value)
        baseplateSize = Vector3.new(tonumber(Value), 1, baseplateSize.Z)
        updateBaseplate()
    end
})

BaseplateTab:CreateInput({
    Name = "Baseplate Size Z",
    PlaceholderText = tostring(baseplateSize.Z),
    RemoveTextAfterFocusLost = false,
    NumbersOnly = true,
    Flag = "SizeZ",
    Callback = function(Value)
        baseplateSize = Vector3.new(baseplateSize.X, 1, tonumber(Value))
        updateBaseplate()
    end
})

BaseplateTab:CreateInput({
    Name = "Baseplate Height (Y Position)",
    PlaceholderText = tostring(baseplateYPosition),
    RemoveTextAfterFocusLost = false,
    NumbersOnly = true,
    Flag = "HeightY",
    Callback = function(Value)
        baseplateYPosition = tonumber(Value)
        updateBaseplate()
    end
})

BaseplateTab:CreateDropdown({
    Name = "Baseplate Material",
    Options = {"Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Concrete", "Slate", "Granite", "Marble", "Grass", "Sand", "Metal"},
    CurrentOption = "SmoothPlastic",
    Flag = "MaterialType",
    Callback = function(Selection)
        local selected = type(Selection) == "table" and Selection[1] or Selection
        if Enum.Material[selected] then
            material = Enum.Material[selected]
            updateBaseplate()
        end
    end
})

local ShaderTab = Window:CreateTab("Shaders", "sun")

local Toggle_EnableShaders, Slider_TimeOfDay, Slider_Brightness, Toggle_MotionBlur, Slider_BlurIntensity
local Slider_BloomIntensity, Slider_BlurSize, Slider_SunRaysIntensity, Slider_Saturation
local Slider_AtmosphereOpacity, ColorPicker_AtmosphereColor, Toggle_RainbowAtmosphere, Slider_RainbowSpeed

local function ApplyShaders()
    if not ShaderInstances.Sky then
        local Sky = Instance.new("Sky", Lighting)
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=144933338"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=144931530"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=144933262"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=144933244"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=144933299"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=144931564"
        ShaderInstances.Sky = Sky
    end
    if not ShaderInstances.Bloom then
        local Bloom = Instance.new("BloomEffect", Lighting)
        Bloom.Intensity = DefaultValues.BloomIntensity
        Bloom.Size = 10
        Bloom.Threshold = 0.8
        ShaderInstances.Bloom = Bloom
    end
    if not ShaderInstances.Blur then
        local Blur = Instance.new("BlurEffect", Lighting)
        Blur.Size = DefaultValues.BlurSize
        ShaderInstances.Blur = Blur
    end
    if not ShaderInstances.ColorCorrection then
        local ColorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
        ColorCorrection.Saturation = DefaultValues.Saturation
        ShaderInstances.ColorCorrection = ColorCorrection
    end
    if not ShaderInstances.SunRays then
        local SunRays = Instance.new("SunRaysEffect", Lighting)
        SunRays.Intensity = DefaultValues.SunRaysIntensity
        SunRays.Spread = 0.8
        ShaderInstances.SunRays = SunRays
    end
    if not ShaderInstances.Atmosphere then
        local Atmosphere = Instance.new("Atmosphere", Lighting)
        Atmosphere.Density = DefaultValues.AtmosphereDensity
        Atmosphere.Color = DefaultValues.AtmosphereColor
        ShaderInstances.Atmosphere = Atmosphere
    end
end

local function RemoveShaders()
    for _, shader in pairs(ShaderInstances) do
        if shader and shader.Parent then
            shader:Destroy()
        end
    end
    ShaderInstances = {}
end

local function ResetToDefault()
    Lighting.ClockTime = DefaultValues.ClockTime
    Lighting.Brightness = DefaultValues.Brightness
    Lighting.Ambient = DefaultValues.Ambient
    Lighting.OutdoorAmbient = DefaultValues.OutdoorAmbient
    RemoveShaders()
    Toggle_EnableShaders:Set(false)
    Slider_TimeOfDay:Set(DefaultValues.ClockTime)
    Slider_Brightness:Set(DefaultValues.Brightness)
    Slider_BloomIntensity:Set(DefaultValues.BloomIntensity)
    Slider_BlurSize:Set(DefaultValues.BlurSize)
    Slider_SunRaysIntensity:Set(DefaultValues.SunRaysIntensity)
    Slider_Saturation:Set(DefaultValues.Saturation)
    Slider_AtmosphereOpacity:Set(DefaultValues.AtmosphereDensity)
    ColorPicker_AtmosphereColor:Set(DefaultValues.AtmosphereColor)
    Toggle_RainbowAtmosphere:Set(DefaultValues.RainbowEnabled)
    Slider_RainbowSpeed:Set(DefaultValues.RainbowSpeed)
    Toggle_MotionBlur:Set(false)
    rainbowEnabled = DefaultValues.RainbowEnabled
    rainbowSpeed = DefaultValues.RainbowSpeed
end

RunService.RenderStepped:Connect(function()
    if motionBlurEnabled then
        local currentCameraPosition = Camera.CFrame.Position
        local velocity = (currentCameraPosition - Camera.CFrame.Position).Magnitude
        BlurEffect.Size = math.clamp(velocity * blurIntensityFactor, 0, 24)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if rainbowEnabled and ShaderInstances.Atmosphere then
        rainbowHue = (rainbowHue + dt * rainbowSpeed) % 1
        ShaderInstances.Atmosphere.Color = Color3.fromHSV(rainbowHue, 1, 1)
    end
end)

Toggle_EnableShaders = ShaderTab:CreateToggle({
    Name = "Enable Shaders",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            ApplyShaders()
        else
            RemoveShaders()
        end
    end
})

Slider_TimeOfDay = ShaderTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.1,
    CurrentValue = DefaultValues.ClockTime,
    Callback = function(value)
        Lighting.ClockTime = value
    end
})

Slider_Brightness = ShaderTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 5},
    Increment = 0.1,
    CurrentValue = DefaultValues.Brightness,
    Callback = function(value)
        Lighting.Brightness = value
    end
})

Toggle_MotionBlur = ShaderTab:CreateToggle({
    Name = "Enable Motion Blur",
    CurrentValue = false,
    Callback = function(enabled)
        motionBlurEnabled = enabled
        if not enabled then
            BlurEffect.Size = 0
        end
    end
})

Slider_BloomIntensity = ShaderTab:CreateSlider({
    Name = "Bloom Intensity",
    Range = {0, 2},
    Increment = 0.1,
    CurrentValue = DefaultValues.BloomIntensity,
    Callback = function(value)
        if ShaderInstances.Bloom then
            ShaderInstances.Bloom.Intensity = value
        end
    end
})

Slider_BlurSize = ShaderTab:CreateSlider({
    Name = "Blur Size",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = DefaultValues.BlurSize,
    Callback = function(value)
        if ShaderInstances.Blur then
            ShaderInstances.Blur.Size = value
        end
    end
})

Slider_SunRaysIntensity = ShaderTab:CreateSlider({
    Name = "Sun Rays Intensity",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = DefaultValues.SunRaysIntensity,
    Callback = function(value)
        if ShaderInstances.SunRays then
            ShaderInstances.SunRays.Intensity = value
        end
    end
})

Slider_Saturation = ShaderTab:CreateSlider({
    Name = "Saturation",
    Range = {-1, 1},
    Increment = 0.1,
    CurrentValue = DefaultValues.Saturation,
    Callback = function(value)
        if ShaderInstances.ColorCorrection then
            ShaderInstances.ColorCorrection.Saturation = value
        end
    end
})

Slider_AtmosphereOpacity = ShaderTab:CreateSlider({
    Name = "Atmosphere Opacity",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = DefaultValues.AtmosphereDensity,
    Callback = function(value)
        if ShaderInstances.Atmosphere then
            ShaderInstances.Atmosphere.Density = value
        end
    end
})

ColorPicker_AtmosphereColor = ShaderTab:CreateColorPicker({
    Name = "Atmosphere Color",
    Color = DefaultValues.AtmosphereColor,
    Callback = function(value)
        if ShaderInstances.Atmosphere then
            ShaderInstances.Atmosphere.Color = value
        end
    end
})

Toggle_RainbowAtmosphere = ShaderTab:CreateToggle({
    Name = "Rainbow Atmosphere",
    CurrentValue = DefaultValues.RainbowEnabled,
    Callback = function(enabled)
        rainbowEnabled = enabled
    end
})

Slider_RainbowSpeed = ShaderTab:CreateSlider({
    Name = "Rainbow Speed",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = DefaultValues.RainbowSpeed,
    Callback = function(value)
        rainbowSpeed = value
    end
})

ShaderTab:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        ResetToDefault()
    end
})
---------------------------------------------------
-- Other Tab
---------------------------------------------------
local OtherTab = Window:CreateTab("Other", "meh")
OtherTab:CreateButton({
    Name = "IY",
    Callback = function()
             local IsStudio = false
             loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end,
})
OtherTab:CreateSlider({
    Name = "Animation Speed",
    Range = {-5, 5},
    Increment = 0.01,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "AnimationSpeedSlider",
    Callback = function(Value)
        print("Animation speed set to: " .. Value .. "x")
        local Humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            for _, anim in pairs(Humanoid:GetPlayingAnimationTracks()) do
                anim:AdjustSpeed(Value)
            end
        end
    end
})
-- Toggle to Freeze animations
OtherTab:CreateButton({
    Name = "Freeze Animation",
    Callback = function()
        AnimationSpeed = 0
        print("Animation Frozen")
        local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            for _, anim in pairs(Humanoid:GetPlayingAnimationTracks()) do
                anim:AdjustSpeed(0)
            end
        end
    end,
})
---------------------------------------------------
-- Settings Tab
---------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateDropdown({
    Name = "Select Theme",
    Options = {"Default", "Amber Glow", "Amethyst", "Bloom", "Dark Blue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = "Dark Blue", -- Initial Theme
    Callback = function(selectedTheme)
        -- Ensure selectedTheme is a string
        if type(selectedTheme) == "table" then
            selectedTheme = selectedTheme[1] -- Use the first selection if multiple
        end

        -- Map the theme name to its exact identifier
        local themeMap = {
            ["Default"] = "Default",
            ["Amber Glow"] = "AmberGlow",
            ["Amethyst"] = "Amethyst",
            ["Bloom"] = "Bloom",
            ["Dark Blue"] = "DarkBlue",
            ["Green"] = "Green",
            ["Light"] = "Light",
            ["Ocean"] = "Ocean",
            ["Serenity"] = "Serenity"
        }

        -- Fetch the identifier for the selected theme
        local themeIdentifier = themeMap[selectedTheme]

        if themeIdentifier then
            Window.ModifyTheme(themeIdentifier) -- Apply the theme
            Rayfield:Notify({
                Title = "Theme Changed",
                Content = "Theme updated to: " .. selectedTheme,
                Duration = 4
            })
            print("Theme changed to: " .. selectedTheme .. " (" .. themeIdentifier .. ")")
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid theme selected: " .. tostring(selectedTheme),
                Duration = 4
            })
            print("Invalid theme selected: " .. tostring(selectedTheme))
        end
    end
})
---------------------------------------------------
-- Global UI Toggle
---------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed then
        Window:Toggle()
    end
end)
