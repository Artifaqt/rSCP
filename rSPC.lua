local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Shader Control Panel by Artifaqt",
    LoadingTitle = "Shader System",
    Icon = "sun", -- Lucide icon for the window
    LoadingSubtitle = "by artifaqt",
    Theme = "DarkBlue",
    KeySystem = false -- Removed configuration-saving to avoid issues
})

-- Welcome Notification
Rayfield:Notify({
    Title = "Welcome to Shader Control Panel",
    Content = "Customize and enhance your Roblox experience with shaders! ",
    Duration = 6.5,
    Image = "sun" -- Lucide icon or asset ID
})

-- Services
local RunService = game:GetService("RunService")
local Light = game.Lighting

-- Shader Variables
local ShaderInstances = { -- Table to store shader instances
    Sky = nil,
    Bloom = nil,
    Blur = nil,
    ColorCorrection = nil,
    SunRays = nil,
    Atmosphere = nil
}

local rainbowEnabled = false
local rainbowSpeed = .5 -- Default rainbow speed
local rainbowHue = 0 -- Keeps track of the current hue for the rainbow effect

-- Default Values for Reset
local DefaultValues = {
    ClockTime = 12, -- Midday
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

-- References to UI Elements
local Toggle_EnableShaders, Slider_TimeOfDay, Button_ResetDefaults
local Slider_BloomIntensity, Slider_BlurSize, Slider_SunRaysIntensity, Slider_Saturation
local Slider_AtmosphereOpacity, ColorPicker_AtmosphereColor, Toggle_RainbowAtmosphere, Slider_RainbowSpeed

-- Function to Apply Shaders
local function ApplyShaders()
    if not ShaderInstances.Sky then
        local Sky = Instance.new("Sky", Light)
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=144933338"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=144931530"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=144933262"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=144933244"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=144933299"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=144931564"
        Sky.StarCount = 5000
        Sky.SunAngularSize = 5
        ShaderInstances.Sky = Sky
    end

    if not ShaderInstances.Bloom then
        local Bloom = Instance.new("BloomEffect", Light)
        Bloom.Intensity = DefaultValues.BloomIntensity
        Bloom.Size = 10
        Bloom.Threshold = 0.8
        ShaderInstances.Bloom = Bloom
    end

    if not ShaderInstances.Blur then
        local Blur = Instance.new("BlurEffect", Light)
        Blur.Size = DefaultValues.BlurSize
        ShaderInstances.Blur = Blur
    end

    if not ShaderInstances.ColorCorrection then
        local ColorCorrection = Instance.new("ColorCorrectionEffect", Light)
        ColorCorrection.Brightness = 0
        ColorCorrection.Contrast = 0.1
        ColorCorrection.Saturation = DefaultValues.Saturation
        ColorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        ShaderInstances.ColorCorrection = ColorCorrection
    end

    if not ShaderInstances.SunRays then
        local SunRays = Instance.new("SunRaysEffect", Light)
        SunRays.Intensity = DefaultValues.SunRaysIntensity
        SunRays.Spread = 0.8
        ShaderInstances.SunRays = SunRays
    end

    if not ShaderInstances.Atmosphere then
        local Atmosphere = Instance.new("Atmosphere", Light)
        Atmosphere.Density = DefaultValues.AtmosphereDensity
        Atmosphere.Offset = 0.25
        Atmosphere.Glare = 0.1
        Atmosphere.Haze = 2
        Atmosphere.Color = DefaultValues.AtmosphereColor
        ShaderInstances.Atmosphere = Atmosphere
    end
end

-- Function to Remove Shaders
local function RemoveShaders()
    for _, shader in pairs(ShaderInstances) do
        if shader and shader.Parent then
            shader:Destroy()
        end
    end
    ShaderInstances = {
        Sky = nil,
        Bloom = nil,
        Blur = nil,
        ColorCorrection = nil,
        SunRays = nil,
        Atmosphere = nil
    }
end

-- Function to Reset All Values
local function ResetToDefault()
    -- Reset Lighting
    Light.ClockTime = DefaultValues.ClockTime
    Light.Brightness = DefaultValues.Brightness
    Light.Ambient = DefaultValues.Ambient
    Light.OutdoorAmbient = DefaultValues.OutdoorAmbient

    -- Remove all shaders
    RemoveShaders()

    -- Reset UI Toggles and Sliders
    Toggle_EnableShaders:Set(false) -- Reset the Enable Shaders toggle
    Slider_TimeOfDay:Set(DefaultValues.ClockTime)
    Slider_BloomIntensity:Set(DefaultValues.BloomIntensity)
    Slider_BlurSize:Set(DefaultValues.BlurSize)
    Slider_SunRaysIntensity:Set(DefaultValues.SunRaysIntensity)
    Slider_Saturation:Set(DefaultValues.Saturation)
    Slider_AtmosphereOpacity:Set(DefaultValues.AtmosphereDensity)
    ColorPicker_AtmosphereColor:Set(DefaultValues.AtmosphereColor)
    Toggle_RainbowAtmosphere:Set(DefaultValues.RainbowEnabled)
    Slider_RainbowSpeed:Set(DefaultValues.RainbowSpeed)
    Slider_Brightness:Set(DefaultValues.Brightness)

    -- Reset Rainbow Atmosphere
    rainbowEnabled = DefaultValues.RainbowEnabled
    rainbowSpeed = DefaultValues.RainbowSpeed

    print("All settings reset to default.")
end

-- Rainbow Effect Logic
RunService.Heartbeat:Connect(function(deltaTime)
    if rainbowEnabled and ShaderInstances.Atmosphere then
        rainbowHue = (rainbowHue + deltaTime * rainbowSpeed) % 1 -- Increment hue based on speed and delta time
        local rainbowColor = Color3.fromHSV(rainbowHue, 1, 1) -- Convert hue to a rainbow color
        ShaderInstances.Atmosphere.Color = rainbowColor -- Apply the color to the atmosphere
    end
end)

-- Create Tabs
local GeneralTab = Window:CreateTab("General", "earth")
local AtmosphereTab = Window:CreateTab("Atmosphere", "cloud-rain")
local EffectsTab = Window:CreateTab("Effects", "sliders")
local OtherTab = Window:CreateTab("Other", "meh")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- General Tab
Toggle_EnableShaders = GeneralTab:CreateToggle({
    Name = "Enable Shaders",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            ApplyShaders()
            print("Shaders enabled.")
        else
            RemoveShaders()
            print("Shaders disabled.")
        end
    end
})

Slider_TimeOfDay = GeneralTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.1,
    CurrentValue = DefaultValues.ClockTime,
    Callback = function(value)
        Light.ClockTime = value
        print("Time of day set to: " .. value)
    end
})

Slider_Brightness = GeneralTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 5},
    Increment = 0.1,
    CurrentValue = Light.Brightness,
    Callback = function(value)
        Light.Brightness = value
        print("Brightness set to: " .. value)
    end
})

Button_ResetDefaults = GeneralTab:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        ResetToDefault()
    end
})

-- Atmosphere Tab
ColorPicker_AtmosphereColor = AtmosphereTab:CreateColorPicker({
    Name = "Atmosphere Color",
    Color = DefaultValues.AtmosphereColor,
    Callback = function(value)
        if ShaderInstances.Atmosphere then
            ShaderInstances.Atmosphere.Color = value
            print("Atmosphere color set to:", value)
        end
    end
})

Slider_AtmosphereOpacity = AtmosphereTab:CreateSlider({
    Name = "Atmosphere Opacity",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = DefaultValues.AtmosphereDensity,
    Callback = function(value)
        if ShaderInstances.Atmosphere then
            ShaderInstances.Atmosphere.Density = value
            print("Atmosphere opacity set to:", value)
        end
    end
})

Toggle_RainbowAtmosphere = AtmosphereTab:CreateToggle({
    Name = "Rainbow Atmosphere",
    CurrentValue = DefaultValues.RainbowEnabled,
    Callback = function(enabled)
        rainbowEnabled = enabled
        print("Rainbow Atmosphere " .. (enabled and "Enabled" or "Disabled"))
    end
})

AtmosphereTab:CreateSlider({
    Name = "Water Wave Size",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = workspace.Terrain.WaterWaveSize,
    Callback = function(value)
        workspace.Terrain.WaterWaveSize = value
        print("Water Wave Size set to: " .. value)
    end
})

Slider_RainbowSpeed = AtmosphereTab:CreateSlider({
    Name = "Rainbow Speed",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = DefaultValues.RainbowSpeed,
    Callback = function(value)
        rainbowSpeed = value
        print("Rainbow Speed set to: " .. value)
    end
})

-- Effects Tab
Slider_BloomIntensity = EffectsTab:CreateSlider({
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

Slider_BlurSize = EffectsTab:CreateSlider({
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

Slider_SunRaysIntensity = EffectsTab:CreateSlider({
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

Slider_Saturation = EffectsTab:CreateSlider({
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

--Useful Other Stuff
OtherTab:CreateButton({
    Name = "VC Unban",
    Callback = function()
             local IsStudio = false
             game:GetService("VoiceChatService"):joinVoice()
    end,
 })

OtherTab:CreateButton({
    Name = "IY",
    Callback = function()
             local IsStudio = false
             loadstring(game:HttpGet("https://raw.githubusercontent.com/EnterpriseExperience/crazyDawg/main/InfYieldOther.lua"))()
end,
})

OtherTab:CreateToggle({
    Name = "No Void",
    CurrentValue = false, -- The initial state of the toggle (off)
    Flag = "NoVoidToggle", -- Unique identifier for the toggle
    Callback = function(enabled)
        local isStudio = game:GetService("RunService"):IsStudio()
        if isStudio then
            warn("This feature cannot be used in Studio mode.")
            return
        end
 
        local Workspace = game:GetService("Workspace")
        local Terrain = Workspace.Terrain
 
        if enabled then
            -- Fill the void when the toggle is enabled
            Terrain:FillBlock(CFrame.new(66, -10, 72.5), Vector3.new(10000, 16, 10000), Enum.Material.Asphalt)
            print("Void filled.")
        else
            -- Remove the filled block when the toggle is disabled
            Terrain:Clear() -- This will clear all terrain modifications; adjust if you want more specific removal.
            print("Void cleared.")
        end
    end,
 })

--Settings tab options
SettingsTab:CreateDropdown({
    Name = "Select Theme",
    Options = {"Default", "Amber Glow", "Amethyst", "Bloom", "Dark Blue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = "Dark Blue", -- Initial Theme
    Callback = function(selectedTheme)
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
            Window:SetTheme(themeIdentifier) -- Apply the theme
            Rayfield:Notify({
                Title = "Theme Changed",
                Content = "Theme updated to: " .. selectedTheme,
                Duration = 4
            })
            print("Theme changed to: " .. selectedTheme .. " (" .. themeIdentifier .. ")")
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid theme selected: " .. selectedTheme,
                Duration = 4
            })
            print("Invalid theme selected: " .. selectedTheme)
        end
    end
})