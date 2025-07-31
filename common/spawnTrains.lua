require("SimRailCore")

function UnconditialCheck(e) -- Im keeping this typo to honor Eridor
    return true
end

globalMainTrain = 0

function spawnTrains(mainTrain)

    --local coldStart = false -- does not do much on Ty2 sadly, thats why its removed

    local trainsets = {}
    local isTrainMain = false;
    globalMainTrain = mainTrain

    isTrainMain = mainTrain == 0
    trainsets[0] = SpawnTrainsetOnSignal(nil, FindSignal("KO_Tm70"), 100, false, isTrainMain, not isTrainMain, false,
    {
        CreateNewSpawnVehicleDescriptor(LocomotiveNames.Ty2_540, false)
    })

    isTrainMain = mainTrain == 1
    trainsets[1] = SpawnTrainsetOnSignal(nil, FindSignal("KO_M8"), 10, false, isTrainMain, not isTrainMain, false,
    {
        CreateNewSpawnVehicleDescriptor(LocomotiveNames.Ty2_477, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bcdu_5051_5978_003_8_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Adnu_5051_1908_095_8_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Adnu_5051_1908_095_8_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bcdu_5051_5978_003_8_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Adnu_5051_1908_095_8_The80s, false)
    })
    if not isTrainMain then
        SetBotSpeed(trainsets[1], 50)
        CreateSignalTrigger(FindSignal("MW_W"), 50, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    DespawnTrainset(trainsets[1])
                end)
            end
        })
    end

    isTrainMain = mainTrain == 2
    trainsets[2] = SpawnTrainsetOnSignal(nil, FindSignal("KO_N10"), 10, true, isTrainMain, not isTrainMain, false,
    {
        CreateNewSpawnVehicleDescriptor(LocomotiveNames.Ty2_477, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false)
    })
    if not isTrainMain then
        SetBotSpeed(trainsets[2], 50)
        CreateSignalTrigger(FindSignal("l139_bry_c"), 50, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    DespawnTrainset(trainsets[2])
                end)
            end
        })
    end

    isTrainMain = mainTrain == 3
    trainsets[3] = SpawnTrainsetOnSignal(nil, FindSignal("KO_N5"), 10, false, isTrainMain, not isTrainMain, false,
    {
        CreateNewSpawnVehicleDescriptor(LocomotiveNames.Ty2_477, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false),
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Bdnu_5051_2008_607_7_The80s, false)
    })
    if not isTrainMain then
        SetBotSpeed(trainsets[3], 25)
    end

    trainsets[4] = SpawnTrainset(nil, FindTrack("t9599"), 70, false, false, false, false, {
        CreateNewSpawnVehicleDescriptor(PassengerWagonNames.Adnu_5051_1908_095_8_The80s, false)
    })

    return trainsets

end

function train0Depart(trainSet)
    CreateCoroutine(function()
        VDSetRoute("KO_Tm70", "KO_Tm64", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm64", "KO_M3", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_M3", "KO_Tm32", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm32", "KO_E13", VDOrderType.ManeuverRoute)
    end)
    if globalMainTrain ~= 0 then
        SetBotSpeed(trainSet, 50)
    end
end

function train1Depart() 
    CreateCoroutine(function()
        VDSetRoute("KO_M8", "KO_E18", VDOrderType.TrainRoute)
        VDSetRoute("KO_E18", "KZ_P", VDOrderType.TrainRoute)
        VDSetRoute("KZ_P", "KZ_E", VDOrderType.TrainRoute)
        VDSetRoute("KZ_E", "KZ_J2", VDOrderType.TrainRoute)
        VDSetRoute("KZ_J2", "KZ_Jbl", VDOrderType.TrainRoute)
    end)
end

function train2Depart()
    VDSetRouteWithVariant("KO_N10", "l139_bry_c", VDOrderType.TrainRoute, { -- make it go on right track and make radio tell preperations train to wait for us to pass
        GetMidPointVariant("z_KO_82", true),
        GetMidPointVariant("z_KO_84", true),
        GetMidPointVariant("z_KO_86", true),
        GetMidPointVariant("z_KO_93", true)
    })
end