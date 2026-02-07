require("SimRailCore")

function UnconditialCheck(e) -- Im keeping this typo to honor Eridor
    return true
end

globalMainTrain = 0
globalTrainSets = {}
globalShuntTrainOutOfWay = false
globalLocalOutOfWay = false

local locomotiveMap = {
    [1] = LocomotiveNames.Ty2_70,
    [2] = LocomotiveNames.Ty2_347,
    [3] = LocomotiveNames.Ty2_447,
    [4] = LocomotiveNames.Ty2_540
}

function spawnTrains(mainTrain, locomotiveIndex)

    --local coldStart = false -- does not do much on Ty2 sadly, thats why its removed

    local trainsets = {}
    local isTrainMain = false;
    globalMainTrain = mainTrain
    
    local selectedLocomotive = locomotiveIndex and locomotiveMap[locomotiveIndex] or LocomotiveNames.Ty2_540

    local currentDateTime = GetDateTime()
    local targetDateTime = DateTimeCreate(1981, 7, 28, 13, 0, 0)
    local timespan = currentDateTime - targetDateTime

    if timespan.TotalMinutes <= 5 then

        isTrainMain = mainTrain == 0
        trainsets[0] = SpawnTrainsetOnSignal(nil, FindSignal("KO_Tm70"), 100, false, isTrainMain, not isTrainMain, false,
        {
            CreateNewSpawnVehicleDescriptor(isTrainMain and selectedLocomotive or LocomotiveNames.Ty2_540, false)
        })
        trainsets[0].SetState(DynamicState.dsAccSlow, TrainsetState.tsShunting, false)

        CreateSignalTrigger(FindSignal("KO_M3"), 100, 
        {
            check = UnconditialCheck,
            result = function(trainset)
                train5Depart()
                globalShuntTrainOutOfWay = true
            end
        })

        isTrainMain = mainTrain == 1
        trainsets[1] = SpawnTrainsetOnSignal(nil, FindSignal("KO_M8"), 10, false, isTrainMain, not isTrainMain, false,
        {
            CreateNewSpawnVehicleDescriptor(isTrainMain and selectedLocomotive or LocomotiveNames.Ty2_477, false),
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
            CreateNewSpawnVehicleDescriptor(isTrainMain and selectedLocomotive or LocomotiveNames.Ty2_477, false),
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
            CreateNewSpawnVehicleDescriptor(isTrainMain and selectedLocomotive or LocomotiveNames.Ty2_477, false),
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

        isTrainMain = mainTrain == 5
        trainsets[5] = SpawnTrainset("SG local", FindTrack("t12685"), 25, false, isTrainMain, not isTrainMain, false,
        {
            CreateNewSpawnVehicleDescriptor(isTrainMain and selectedLocomotive or LocomotiveNames.Ty2_540, false),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.UACS_3351_9307_587_6, false, "", 55, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.UACS_3351_9307_587_6, false, "", 55, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.UACS_3351_9307_587_6, false, "", 55, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.UACS_3351_9307_587_6, false, "", 55, BrakeRegime.G),
            ---
            CreateNewSpawnVehicleDescriptor(FreightWagonNames.EAOS_3151_5351_989_9, false),
            CreateNewSpawnVehicleDescriptor(FreightWagonNames.EAOS_3151_5351_989_9, false),
            CreateNewSpawnVehicleDescriptor(FreightWagonNames.EAOS_3151_5351_989_9, false),
            ---
            CreateNewSpawnVehicleDescriptor(FreightWagonNames.SGS_3151_3944_773_6, false),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.SGS_3151_3944_773_6, false, FreightLoads_412W.Concrete_slab, 40, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.SGS_3151_3944_773_6, false, FreightLoads_412W.Pipeline, 10, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.SGS_3151_3944_773_6, false, FreightLoads_412W.T_beam, 40, BrakeRegime.G),
            CreateNewSpawnFullVehicleDescriptor(FreightWagonNames.SGS_3151_3944_773_6, false, FreightLoads_412W.Sheet_metal, 20, BrakeRegime.G),
        })
        trainsets[5].SetState(DynamicState.dsAccSlow, TrainsetState.tsShunting, true)

        CreateSignalTrigger(FindSignal("KO_E15"), 1, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    LocalOutOfWay = true
                end)
            end
        })
    end


    globalTrainSets = trainsets
    return trainsets

end

function train0Depart()
    CreateCoroutine(function()
        VDSetRoute("KO_Tm70", "KO_Tm64", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm64", "KO_M3", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_M3", "KO_Tm32", VDOrderType.ManeuverRoute)
        VDSetRoute("KO_Tm32", "KO_E13", VDOrderType.ManeuverRoute)
    end)
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

function train5Depart() 
    VDSetRoute("KO_Tm56", "KO_M7", VDOrderType.ManeuverRoute)
    
    VDSetRouteWithVariant("KO_M7", "KO_E15", VDOrderType.TrainRoute, {
        GetMidPointVariant("z_KO_55", true),
        GetMidPointVariant("z_KO_53", true),
        GetMidPointVariant("z_KO_37cd", true),
        GetMidPointVariant("z_KO_37ab", true)
    })
    VDSetRouteWithVariant("KO_E15", "KZ_O", VDOrderType.TrainRoute, {
        GetMidPointVariant("z_KO_25", false),
        GetMidPointVariant("z_KO_22", false),
        GetMidPointVariant("z_KO_13cd", true),
        GetMidPointVariant("z_KO_13ab", false),
        GetMidPointVariant("z_KO_6cd", false),
        GetMidPointVariant("z_KO_6ab", false)
    })
    VDSetRouteWithVariant("KZ_O", "KZ_D2", VDOrderType.TrainRoute, {
        GetMidPointVariant("z_KZ_52cd", false),
        GetMidPointVariant("z_KZ_52ab", false),
        GetMidPointVariant("z_KZ_48cd", false),
        GetMidPointVariant("z_KZ_48ab", false)
    })
    VDSetRoute("KZ_D2", "KZ_B2bl", VDOrderType.TrainRoute)
    VDSetRoute("SG_Y", "SG_R2", VDOrderType.TrainRoute)

    if globalMainTrain ~= 5 then
        CreateSignalTrigger(FindSignal("SG_R2"), 100, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    DespawnTrainset(trainset)
                end)
            end
        })

        CreateSignalTrigger(FindSignal("KO_E15"), 20, {
            check = UnconditialCheck,
            result = function (trainset) 
                CreateCoroutine(function()
                    globalLocalOutOfWay = true;
                end)
            end
        })
    end
end

function getShuntTrainOutOfWay()
    return globalShuntTrainOutOfWay
end

function getLocalOutOfWay()
    return globalLocalOutOfWay
end