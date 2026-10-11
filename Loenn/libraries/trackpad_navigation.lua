local keyboardUtils = require("utils.keyboard")
local menubar = require("ui.menubar")
local persistence = require("persistence")
local configs = require("configs")
local uiElements = require("ui.elements.input")
local viewportDevice = require("input_devices.viewport_device")
local viewportHandler = require("viewport_handler")

local trackpadNavigation = {
    name = "trackpad_navigation"
}

-- Tune these values if the defaults feel too fast or too slow.
local panPixelsPerStep = 32
local zoomSensitivity = 0.12
local minimumScale = 1 / 64
local maximumScale = 64

local persistenceKey = "trackpadNavigationEnabled"

local function isEnabled()
    local enabled = persistence[persistenceKey]

    if enabled == nil then
        return true
    end

    return enabled
end

local function toggleEnabled()
    persistence[persistenceKey] = not isEnabled()
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function smoothZoom(delta)
    local viewport = viewportHandler.viewport
    local mouseX, mouseY = viewportHandler.getMousePosition()
    local oldScale = viewport.scale
    local newScale = clamp(oldScale * math.exp(delta * zoomSensitivity), minimumScale, maximumScale)

    if newScale == oldScale then
        return
    end

    local scaleRatio = newScale / oldScale

    -- Keep the map point below the pointer stationary while zooming.
    viewport.x = (viewport.x + mouseX) * scaleRatio - mouseX
    viewport.y = (viewport.y + mouseY) * scaleRatio - mouseY
    viewport.scale = newScale

    viewportHandler.persistCamera()
end

local function trackpadWheelmoved(dx, dy)
    if not isEnabled() then
        return viewportDevice._trackpadNavigationOriginalWheelmoved(dx, dy)
    end

    if keyboardUtils.modifierControl() or keyboardUtils.modifierGUI() then
        if dy ~= 0 then
            smoothZoom(dy)
            return true
        end

        return
    end

    if dx ~= 0 or dy ~= 0 then
        local viewport = viewportHandler.viewport

        -- LÖVE reports positive x to the right and positive y upward.
        viewport.x = viewport.x + dx * panPixelsPerStep
        viewport.y = viewport.y - dy * panPixelsPerStep

        viewportHandler.persistCamera()

        return true
    end
end

local function installWheelHandler()
    if not viewportDevice._trackpadNavigationOriginalWheelmoved then
        viewportDevice._trackpadNavigationOriginalWheelmoved = viewportDevice.wheelmoved
    end

    viewportDevice.wheelmoved = trackpadWheelmoved
end

local function installMenuItem()
    for _, topLevelEntry in ipairs(menubar.menubar) do
        if topLevelEntry[1] == "view" then
            local viewEntries = topLevelEntry[2]

            for _, entry in ipairs(viewEntries) do
                if entry[1] == "trackpad_navigation" then
                    return
                end
            end

            table.insert(viewEntries, {"trackpad_navigation", toggleEnabled, "checkbox", isEnabled})
            return
        end
    end
end

local function installMacKeyboardFixes()
    if love.system.getOS() ~= "OS X" then
        return
    end

    -- Lönn 0.0.0's text field checks love.system.getOS without calling it,
    -- so the macOS branch is never selected. Accept both modifiers here.
    uiElements.field.__default.hotkeyModifierHeld = function()
        return keyboardUtils.modifierControl() or keyboardUtils.modifierGUI()
    end

    -- UI-specific hotkeys do not receive the macOS ctrl -> cmd conversion
    -- used by Lönn's main hotkey defaults.
    if configs.ui.hotkeys.focusMaterialSearch == "ctrl + f" then
        configs.ui.hotkeys.focusMaterialSearch = "cmd + f"
    end
end

installWheelHandler()
installMenuItem()
installMacKeyboardFixes()

return trackpadNavigation
