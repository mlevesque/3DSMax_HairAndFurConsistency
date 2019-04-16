filein "includes/SourceObjectMethods.ms"
filein "includes/TargetObjectMethods.ms"

plugin modifier hairAndFurControllerModifier
name:"Hair and Fur Controller"
classID:#(0x48483ee2, 0x3fd00394)
replaceUI:off
silentErrors:off
version:1
(
    local APPDATA_INDEX_FUR_GROUP = 2

    /*=============================================================================================
                    PARAMETERS
    */
    parameters main
    (
        sourceObjects type:#nodeTab tabSizeVariable:true
        targetObjects type:#nodeTab tabSizeVariable:true
    )

    /*=============================================================================================
                    ROLLOUT
    */
    rollout mainRollout "Source Objects"
    (
        fn filterHairAndFur obj = (for m in obj.modifiers where classof m == HairMod collect m).count > 0


        multiListBox ui_multiListSource "Source Objects"
        pickButton ui_pbAddSource "Add" filter:filterHairAndFur width:50 align:#left across:2
        button ui_bRemoveSource "Remove" enabled:false width:50 align:#right

        label ui_lblBlank1 ""

        multiListBox ui_multiListTarget "Target Objects"
        pickButton ui_pbAddTarget "Add" filter:filterHairAndFur width:50 align:#left across:2
        button ui_bRemoveTarget "Remove" enabled:false width:50 align:#right

        label ui_lblBlank2 ""

        dropdownlist ui_dropdown "Select Source"
        button ui_bUpdateTargets "Update Targets" enabled:false
        listbox ui_lbSelectedTargets "Selected Targets" readOnly:true


        fn getDropdownSourceObj = (local index = ui_dropdown.selection; if index > 0 then sourceObjects[index] else undefined)
        fn getSelectedTargets = (local s = ui_multiListTarget.selection; for i = 1 to s.count where s[i] == true collect targetObjects[i])

        fn refreshListBox lb arr = (lb.items = for obj in arr collect obj.name)
        fn refreshButtonEnables b lb = (b.enabled = not lb.selection.isEmpty)
        fn removeSelected lb arr = 
        (
            local toRemove = for i = lb.selection.count to 1 by -1 where lb.selection[i] == true collect i
            for i in toRemove do deleteItem arr i
        )

        fn refreshNodeTab nt = 
        (
            local toDelete = for i = nt.count to 1 by -1 where nt[i] == undefined collect i
            for index in toDelete do deleteItem nt index
        )
        fn refreshSourceButtons = (refreshButtonEnables ui_bRemoveSource ui_multiListSource)
        fn refreshSourceList = (refreshListBox ui_multiListSource sourceObjects; refreshSourceButtons())
        fn refreshTargetButtons = (refreshButtonEnables ui_bRemoveTarget ui_multiListTarget)
        fn refreshTargetList = (refreshListBox ui_multiListTarget targetObjects; refreshTargetButtons())
        fn refreshDropDown = (refreshListBox ui_dropdown sourceObjects)
        fn refreshUpdateButton = (ui_bUpdateTargets.enabled = ui_dropdown.selection != 0 AND ui_lbSelectedTargets.items.count > 0)
        fn refreshSelectedTargets = 
        (
            local selectedTargets = getSelectedTargets()
            ui_lbSelectedTargets.items = for obj in selectedTargets collect obj.name
            refreshUpdateButton()
        )
        fn refreshAll = 
        (
            refreshSourceList(); refreshTargetList(); refreshSourceButtons()
            refreshTargetButtons(); refreshDropDown(); refreshSelectedTargets()
        )


        on mainRollout open do (refreshNodeTab sourceObjects; refreshNodeTab targetObjects; refreshAll())
        on mainRollout reload do (refreshNodeTab sourceObjects; refreshNodeTab targetObjects; refreshAll())

        on ui_pbAddSource picked obj do (appendIfUnique sourceObjects obj; refreshSourceList(); refreshDropDown())
        on ui_bRemoveSource pressed do (removeSelected ui_multiListSource sourceObjects; refreshSourceList(); refreshDropDown())
        on ui_multiListSource selectionEnd do (refreshSourceButtons())
        on ui_multiListSource rightClick do (ui_multiListSource.selection = #(); refreshSourceButtons())
        on ui_multiListSource doubleClick do (ui_multiListSource.selection = #{1..sourceObjects.count}; refreshSourceButtons())

        on ui_pbAddTarget picked obj do (appendIfUnique targetObjects obj; refreshTargetList())
        on ui_bRemoveTarget pressed do (removeSelected ui_multiListTarget targetObjects; refreshTargetList(); refreshSelectedTargets())
        on ui_multiListTarget selectionEnd do (refreshTargetButtons() refreshSelectedTargets();)
        on ui_multiListTarget rightClick do (ui_multiListTarget.selection = #(); refreshTargetButtons(); refreshSelectedTargets())
        on ui_multiListTarget doubleClick do (ui_multiListTarget.selection = #{1..targetObjects.count}; refreshTargetButtons(); refreshSelectedTargets())

        on ui_dropdown selected index do (refreshUpdateButton())
        on ui_bUpdateTargets pressed do
        (
            undo "Update Hair and Fur Targets" on
            (
                -- get source
                local sourceObject = getDropdownSourceObj()
                if sourceObject != undefined then
                (
                    -- get targets
                    local selectedTargets = getSelectedTargets()

                    -- get source data
                    local sourceData = buildSourceObjectData sourceObject

                    -- modify targets
                    for obj in selectedTargets do modifyTargetWithSourceData obj sourceData
                )
            )
        )
    )
)
