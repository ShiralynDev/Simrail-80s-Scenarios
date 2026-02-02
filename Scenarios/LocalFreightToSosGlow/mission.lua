-- SimRail - The Railway Simulator
-- LUA Scripting scenario
-- Version: 1.0
--

require("SimRailCore")
require("../../common/spawnTrains")
require("../../common/locomotiveSelection")

--- Player start position as Vector3 
StartPosition = {-12123.03, 274.35, 1506.13}
--- List of sounds with their keys
Sounds = {
    ['goodAfternoon'] = {
        [Languages.English]  = "welcomeLocalFreight.wav"
    },
    ['signalsForward'] = {
        [Languages.English]  = "../../../sounds/signalsForward.wav"
    },
    ['pleaseMoveToSignal'] = {
        [Languages.English]  = "../../../sounds/pleaseMoveToSignal.wav"
    },
    ['SG_copyLeftMost'] = {
        [Languages.English]  = "SG_copyLeftMost.wav"
    },
    ['SG_EAOS'] = {
        [Languages.English]  = "SG_EAOS.wav"
    },
    ['SG_UACS'] = {
        [Languages.English]  = "SG_UACS.wav"
    },
    ['SGCopyWillGiveSignal'] = {
        [Languages.English]  = "SGCopyWillGiveSignal.wav"
    },
    ['SG_412W'] = {
        [Languages.English]  = "SG_412W.wav"
    },
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

function UnconditialCheck(e) -- Im keeping this typo to honor Eridor -- move to common 
    return true
end

function PrepareScenario() 
    SetPassengersAtPlatformMultiplier(2)
end

function EarlyStartScenario() 
end

trainSets = {}
function StartScenario()
    ShowLocomotiveSelectionDropdown(function(selectedIndex)
        trainSets = spawnTrains(5, selectedIndex)
        trainSets[5].SetRadioChannel(1, true)

        CreateDateTimeTrigger(DateTimeCreate(1981, 7, 28, 13, 0, 0), function()
            CreateCoroutine(function()
                train0Depart()
                train1Depart()
                train2Depart()
            end)
        end)

        PlayNarrationAudioClip("goodAfternoon", 1)
        SetCameraView(CameraView.FirstPersonWalkingOutside)
        DisplayChatText_Formatted("startText", GetUsername())

        CreateSignalTrigger(FindSignal("SG_R2"), 100, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    stage = 1
                end)
            end
        })
    end)
end

function PerformUpdate() 
end

function OnVirtualDispatcherReady() 
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
        -- Ready to depart (VOICE)

        if not getShuntTrainOutOfWay() then
            -- please wait for the shunt train to get out of the way  (VOICE)
            DisplayChatText("waitForShuntLoco")
            return
        end
        
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)
        
    elseif stage == 1 then
        -- "Hello dispatch, looking to enter your station to deliver some wagons"
        PlayNarrationAudioClip("SG_copyLeftMost")
        VDSetSwitchPositionCarelessly("z_SG_42c", false)
        VDSetSwitchPositionCarelessly("z_SG_40d", false)
        VDSetSwitchPositionCarelessly("z_SG_36", false)
        VDSetSwitchPositionCarelessly("z_SG_35", false)
        VDSetSwitchPositionCarelessly("z_SG_31", false)
        AllowPassingStopSignal("SG_Tm35", UnconditialCheck)
        VDSetManualSignalLightsState("SG_Tm35", SignalLightType.Blue, LuaSignalLightState.AlwaysOff)
        VDSetManualSignalLightsState("SG_Tm35", SignalLightType.White1, LuaSignalLightState.AlwaysOn)
        AllowPassingStopSignal("SG_R2", UnconditialCheck)
        VDSetManualSignalLightsState("SG_R2", SignalLightType.Red1, LuaSignalLightState.AlwaysOff)
        VDSetManualSignalLightsState("SG_R2", SignalLightType.White1, LuaSignalLightState.AlwaysOn)
        

        CreateTrackTrigger(FindTrack("t9339"), 145, 1, 
        {
            check = UnconditialCheck,
            result = function(trainset)
                stage = 3
            end
        })

        stage = 2

    elseif stage == 2 then
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    elseif stage == 3 then
        -- ready to reverse
        PlayNarrationAudioClip("SGCopyWillGiveSignal")

        VDSetSwitchPositionCarelessly("z_SG_31", true)
        VDSetManualSignalLightsState("SG_N13", SignalLightType.Red1, LuaSignalLightState.AlwaysOff)
        VDSetManualSignalLightsState("SG_N13", SignalLightType.White1, LuaSignalLightState.AlwaysOn)
        AllowPassingStopSignal("SG_N13", UnconditialCheck)
        CreateTrackTrigger(FindTrack("t9388"), 78, 1, 
        {
            check = UnconditialCheck,
            result = function(trainset)
                stage = 5
            end
        })

        stage = 4

    elseif stage == 4 then -- bro just do a else at this point
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    elseif stage == 5 then
        if #trainSets[5].Vehicles ~= 8 then
            PlayNarrationAudioClip("SG_412W")
            return
        end

        CreateTrackTrigger(FindTrack("t9339"), 145, 1, 
        {
            check = UnconditialCheck,
            result = function(trainset)
                stage = 7
            end
        })
        stage = 6

    elseif stage == 6 then 
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    elseif stage == 7 then
        CreateTrackTrigger(FindTrack("t9388"), 78, 1, 
        {
            check = UnconditialCheck,
            result = function(trainset)
                stage = 9
            end
        })
        stage = 8

    elseif stage == 8 then 
        DisplayChatText("pleaseMoveToCorrectSignalText")
        PlayNarrationAudioClip("pleaseMoveToSignal", 1)

    end
end