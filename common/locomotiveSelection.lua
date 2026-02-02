require("SimRailCore")

function ShowLocomotiveSelectionDropdown(onConfirmCallback)
    ShowDropdownMessageBox(
        "selectLocomotive",
        {
            "Ty2-1",
            "Ty2-2",
            "Ty2-3",
            "Ty2-4"
        },
        {
            ["ConfirmationText"] = "selectTrain",
            ["OnConfirm"] = function(selectedKey, selectedIndex)
                if onConfirmCallback then
                    onConfirmCallback(selectedIndex)
                end
            end
        }
    )
end
