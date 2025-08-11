-- SimRail - The Railway Simulator
-- LUA Scripting scenario
-- Version: 1.0
--

require("SimRailCore")
require("../../common/spawnTrains")

--- Player start position as Vector3 
StartPosition = {-10915.85, 273, 1585.25}
--- List of sounds with their keys
Sounds = {
    ['goodAfternoon'] = {
        [Languages.English]  = "../../../sounds/goodAfternoon.wav"
    },
    ['signalsForward'] = {
        [Languages.English]  = "../../../sounds/signalsForward.wav"
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
    trainSets = spawnTrains(2);
    trainSets[2].SetRadioChannel(1, true)

    PlayNarrationAudioClip("goodAfternoon", 1)
    SetCameraView(CameraView.FirstPersonWalkingOutside)
    DisplayChatText_Formatted("startText", GetUsername())

    CreateSignalTrigger(FindSignal("l139_bry_c"), 150, {
        check = UnconditialCheck,
        result = function (trainset) 
            CreateCoroutine(function()
                FinishMission(MissionResultEnum.Success)
            end)
        end
    })
end

function PerformUpdate() 
end

function OnVirtualDispatcherReady() 
    VDReady = true
    train1Depart()
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
        -- Ready to depart
        PlayNarrationAudioClip("signalsForward", 1)
        DisplayChatText(Tm70ToEm13Text) --rename lang tag
        train2Depart()
    end
end