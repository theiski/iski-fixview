local QBCore = exports['qb-core']:GetCoreObject()
local currentCamera = nil
local playerPed = PlayerPedId()
local countdown = 1.5 -- Countdown in seconds

-- Create the instruction scaleform
local function CreateInstructions()
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    -- Button instructions
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 177, true)) -- Backspace to close
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform("Close Camera")
    EndTextCommandScaleformString()
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    -- Draw the scaleform on screen
    CreateThread(function()
        while currentCamera ~= nil do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            Wait(0)
        end
    end)
end

-- Function to force the game to load assets at the camera's location
local function ForceLoadSceneAtCoords(coords)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)  -- Request collision
    NewLoadSceneStart(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z, 50.0, 0) -- Force loading of the area
    while not IsNewLoadSceneLoaded() do  -- Wait until the area is fully loaded
        Wait(0)
    end
end

-- Function to close the camera and reset the focus
local function CloseCamera()
    if currentCamera ~= nil then
        DestroyCam(currentCamera, false)
        RenderScriptCams(false, false, 0, true, true)
        ClearFocus()  -- Reset focus to avoid bugs
        currentCamera = nil
        QBCore.Functions.Notify("Camera closed.", "info") -- Notify player
    end
end

-- Function to set the camera at specified coordinates without freezing the player
local function SetCameraAtCoords()
    if currentCamera ~= nil then
        DestroyCam(currentCamera, 0)
        currentCamera = nil
    end

    currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    -- Set camera position and heading
    local coords = vector4(724.37, 610.76, 137.3, 265.28) -- Your custom coordinates
    SetCamCoord(currentCamera, coords.x, coords.y, coords.z)
    SetCamRot(currentCamera, 0.0, 0.0, coords.w) -- Set heading
    RenderScriptCams(true, false, 0, true, true)
    SetCamActive(currentCamera, true)

    -- Focus on the camera's location and prevent rendering at player's current location
    SetFocusArea(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z)

    ForceLoadSceneAtCoords(coords) -- Ensure the area is rendered properly with the same camera coordinates

    CreateInstructions() -- Create instructions when the camera is activated

    -- Start the countdown for camera close
    local timer = countdown
    CreateThread(function()
        while timer > 0 do
            Wait(0)
            -- Display countdown
            DrawCountdown(timer)
            timer = timer - 0.01
        end
        CloseCamera() -- Close the camera automatically after countdown
    end)
end

-- Function to draw the countdown on the screen
function DrawCountdown(timeLeft)
    local scale = 0.7 -- Text size
    local text = string.format("Camera closing in: %.1f", timeLeft)

    -- Set text properties
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255) -- White color
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    -- Draw the text on the screen
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.8) -- Position (center of the screen)
end

-- Start the camera event
RegisterNetEvent('iski-fixview:client:StartCamera', function()
    SetCameraAtCoords()
end)

-- Check for controls to close the camera (manual close option)
CreateThread(function()
    while true do
        Wait(0) -- Allows the thread to run continuously

        if currentCamera ~= nil then
            if IsControlJustPressed(1, 177) then -- Example control to close camera (Backspace)
                CloseCamera()
            end
        end
    end
end)
