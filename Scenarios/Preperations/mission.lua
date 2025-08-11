-- SimRail - The Railway Simulator
-- LUA Scripting scenario
-- Version: 1.0
--

require("SimRailCore")
require("../../common/spawnTrains")

--- Player start position as Vector3 
StartPosition = {-11586, 270.5, 1533.25}
--- List of sounds with their keys
Sounds = {
    ['goodAfternoon'] = {
        [Languages.English]  = "welcomePrepare.wav"
    },
    ['driverReady'] = {
        [Languages.English]  = "driverReady.mp3"
    },
    ['pleaseMoveToSignal'] = {
        [Languages.English]  = "pleaseMoveToSignal.wav"
    },
    ['signalsForward'] = {
        [Languages.English]  = "signalsForward.wav"
    },
    ['wrongLength'] = {
        [Languages.English]  = "wrongLength.wav"
    },
    ['reverseAndCouple'] = {
        [Languages.English]  = "reverseAndCouple.wav"
    },
    ['copyToTrack3'] = {
        [Languages.English]  = "copyToTrack3.wav"
    },
    ['goBackwards'] = {
        [Languages.English]  = "goBackwards.wav"
    },
    ['goForward'] = {
        [Languages.English]  = "goForward.wav"
    },
    ['readyToTrack3'] = {
        [Languages.English]  = "readyToTrack3.mp3"
    },
    ['forgotToGrab'] = {
        [Languages.English]  = "forgotToGrab.mp3"
    },
    ['attached'] = {
        [Languages.English]  = "attached.mp3"
    },
    ['forgotToGrabNarator'] = {
        [Languages.English]  = "forgotToGrabNARRATOR.wav"
    }
}

stage = 0
VDReady = false
RadioClick = false

-- This code is so cursed but its my first scenario, will hopefully be better in my next one
-- if possible add fireman mode
-- if fireman mode possible then add this more as a function so it can be called like an AI mission thats working whilst other scenarios are being ran

DeveloperMode = function()
    return true
end

function SetVDReadyDEBUG()
    VDReady = true
end

function IncStageDEBUG()
    stage = stage + 1
end

function UnconditialCheck(e) -- Im keeping this typo to honor Eridor
    return true
end

--[[
function msgBoxSwitches(callback)
    local select = ""
    ShowDropdownMessageBox(
        "ChooseSwitch",
        {
            "Switch_z807",
            "Switch_z806",
            "Switch_z810"
        },
        {
            ["OnConfirm"] = function (s, i)
                local switchName = s:gsub("Switch_", "")
                VDSetSwitchPositionCarelessly(switchName, not positions[switchName])
                positions[switchName] = not positions[switchName]
                select = s
            end,
            ["OnSelect"] = function () end,
            ["ConfirmationText"] = "Switch"
        }
    )

    -- Run the wait logic in its own coroutine
    CreateCoroutine(function ()
        coroutine.yield(CoroutineYields.WaitUntil, function ()
            return select ~= ""
        end)
        if callback then callback(select) end
    end)
end

function OnPlayerRadioCall(trainsetInfo, radio_SelectionCall)
    if not RadioClick then
        RadioClick = true
        CreateCoroutine(function ()
            if VdReady then
                msgBoxSwitches(function ()
                    -- After switch is toggled, wait before allowing another call
                    coroutine.yield(CoroutineYields.WaitForSeconds, 2)
                    RadioClick = false
                end)
            else
                RadioClick = false
            end
        end)
    end
end
]]

function PrepareScenario() 
    SetPassengersAtPlatformMultiplier(2)
end

function EarlyStartScenario() 
end

function E13SignalTrigger() 
    CreateSignalTrigger(FindSignal("KO_E13"), 50, {
        check = UnconditialCheck, 
        result = function (state) 
            CreateCoroutine(function()
                if stage == 1 then
                    stage = 2
                elseif stage == 4 then
                    stage = 5
                end
            end)
        end
    })
end

function Tm13SignalTrigger() 
    CreateSignalTrigger(FindSignal("KO_Tm13"), 200, {
        check = UnconditialCheck, 
        result = function (state) 
            CreateCoroutine(function()
                if stage == 7 then
                    stage = 8
                elseif stage == 10 then
                    stage = 11
                end
            end)
        end
    })
end

trainSets = {}
function StartScenario()
    trainSets = spawnTrains(0)
    PlayNarrationAudioClip("goodAfternoon", 1)

    trainSets[0].SetRadioChannel(1, true)
    --trainset.SetPaperTimetable("Paper")
    E13SignalTrigger()

    SetCameraView(CameraView.FirstPersonWalkingOutside)
    DisplayChatText_Formatted("startText", GetUsername())
end

function PerformUpdate() 
end

function OnVirtualDispatcherReady() 

    -- AI train route
    --[[ Moved to after radio
    VDSetRoute("KO_M8", "KO_E18", VDOrderType.TrainRoute)
    VDSetRoute("KO_E18", "KZ_P", VDOrderType.TrainRoute)
    VDSetRoute("KZ_P", "KZ_E", VDOrderType.TrainRoute)
    VDSetRoute("KZ_E", "KZ_J2", VDOrderType.TrainRoute)
    ]]
    --AllowPassingStopSignal("KZ_J2", UnconditialCheck)

    VDSetSwitchPositionCarelessly("z560", false)
    VDSetSwitchPositionCarelessly("z561", false)
    train2Depart()
    VDReady = true
end

function setRoute(fromSignal, toSignal, orderType)
    return GetCurrentVDRequestResponse(VDSetRoute(fromSignal, toSignal, orderType)) == VDResponseCode.Accepted;
end

function OnPlayerRadioCall(trainset, radioCall, channel)
    if not VDReady then
        DisplayChatText("vdNotReadyText")
        return
    end

    if radioCall == 2 then 
        return
    end

    if stage == 0 then 

        CreateCoroutine(function()
        PlayNarrationAudioClip("driverReady", 1)

        coroutine.yield(CoroutineYields.WaitForSeconds, 10)

        DisplayChatText("Tm70ToEm13Text")
        train0Depart() -- arg not needed I believe
        PlayNarrationAudioClip("signalsForward", 1)
        stage = 1
        end)

    elseif stage == 1 then
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)
    elseif stage == 2 then

        if not getLocalOutOfWay() then
            DisplayChatText("waitForTrainOutOfWay")
            --PlayNarrationAudioClip("waitForTrainOutOfWay", 1)
            return
        end

        DisplayChatText("signalToOtherTrain")
        PlayNarrationAudioClip("reverseAndCouple", 1)
        VDSetRoute("KO_K", "KO_Tm29", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm29", "KO_Tm36", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm36", "KO_N5", VDOrderType.ManeuverRoute)

        train1Depart()

        stage = 3 --make sure route is set before going to next stage
    elseif stage == 3 then
        local trainset = RailstockGetPlayerTrainset()
        if #trainset.Vehicles ~= 4 then
            DisplayChatText("wrongLengthText")
            PlayNarrationAudioClip("wrongLength", 1)
            return
        end

        CreateCoroutine(function()
        PlayNarrationAudioClip("readyToTrack3", 1)

        coroutine.yield(CoroutineYields.WaitForSeconds, 5)
        
        DisplayChatText("copyToTrack3")
        PlayNarrationAudioClip("copyToTrack3", 1)

        VDSetRoute("KO_N5", "KO_Tm101", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm101", "t13335k", VDOrderType.ManeuverRoute)

        VDSetRoute("KO_M5", "KO_Tm33", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm33", "KO_E13", VDOrderType.ManeuverRoute)
        E13SignalTrigger();
        stage = 4
        end)

    elseif stage == 4 then
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)
    
    elseif stage == 5 then
        --VDSetRoute("KO_M5", "KO_N3", VDOrderType.TrainRoute) No need cus too long
        VDSetRoute("KO_Tm29", "KO_Tm35", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm35", "KO_N3", VDOrderType.ManeuverRoute)
        DisplayChatText("goBackwards")
        PlayNarrationAudioClip("goBackwards", 1)
        stage = 6

    elseif stage == 6 then
        local trainset = RailstockGetPlayerTrainset()
        if #trainset.Vehicles ~= 1 then
            DisplayChatText("disconnectCars")
            --PlayNarrationAudioClip("disconnectCars", 1)
            return
        end

        CreateCoroutine(function()
        PlayNarrationAudioClip("forgotToGrabNarator", 1)
        coroutine.yield(CoroutineYields.WaitForSeconds, 5)
        PlayNarrationAudioClip("forgotToGrab", 1)
        coroutine.yield(CoroutineYields.WaitForSeconds, 5)
        -- no problem, go forward, contact me when your are ready to reverse
        VDSetRoute("KO_M3", "KO_Tm32", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm32", "KO_Tm13", VDOrderType.ManeuverRoute)
        Tm13SignalTrigger();
        stage = 7;
        end)
    
    elseif stage == 7 then
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    elseif stage == 8 then
        DisplayChatText("goBackwards")
        PlayNarrationAudioClip("goBackwards", 1)
        --VDSetRoute("KO_Tm29", "t9599k", VDOrderType.ManeuverRoute)
        VDSetSwitchPositionCarelessly("z_KO_33b", false)
        VDSetSwitchPositionCarelessly("z_KO_33c", false)
        AllowPassingStopSignal("KO_Tm21", UnconditialCheck)
        VDSetManualSignalLightsState("KO_Tm21", SignalLightType.Blue, LuaSignalLightState.AlwaysOff)
        VDSetManualSignalLightsState("KO_Tm21", SignalLightType.White1, LuaSignalLightState.AlwaysOn)
        stage = 9


    elseif stage == 9 then
        local trainset = RailstockGetPlayerTrainset()
        if #trainset.Vehicles ~= 2 then
            DisplayChatText("wrongLengthText")
            PlayNarrationAudioClip("wrongLength", 1)
            return
        end

        PlayNarrationAudioClip("attached", 1)
        VDSetRoute("KO_Tm39", "KO_Tm13", VDOrderType.ManeuverRoute)
        Tm13SignalTrigger();
        -- Copy that, go forward bla bla
        stage = 10

    elseif stage == 10 then
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    elseif stage == 11 then
        DisplayChatText("goBackwards")
        PlayNarrationAudioClip("goBackwards", 1)
        VDSetRoute("KO_Tm21", "KO_Tm35", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm35", "KO_N3", VDOrderType.ManeuverRoute)
        stage = 12

    elseif stage == 12 then
        local trainset = RailstockGetPlayerTrainset()
        if #trainset.Vehicles ~= 5 then
            DisplayChatText("wrongLengthEndText")
            PlayNarrationAudioClip("wrongLengthEnd", 1)
            return
        end
        FinishMission(MissionResultEnum.Success)
    end
end