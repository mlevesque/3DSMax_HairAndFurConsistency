filein "includes/SourceObjectData.ms"

plugin modifier hairAndFurControllerModifier
name:"Hair and Fur Controller"
classID:#(0x48483ee2, 0x3fd00394)
replaceUI:off
silentErrors:off
version:1
(
    /* Filters */
    fn filterHairAndFur obj = (for m in obj.modifiers where classof m == HairMod collect m).count > 0

    /*=============================================================================================
                    PARAMETERS
    */
    parameters main rollout:mainRollout
    (
        sourceObjects type:#nodeTab tabSizeVariable:true
        targetObjects type:#nodeTab tabSizeVariable:true
        enableHairLength type:#boolean default:true ui:ui_chkHairLengths
        enableHairProps type:#boolean default:true ui:ui_chkHairProps
        enableDynamics type:#boolean default:true ui:ui_chkDynamics
        selectedSourceIndex type:#integer ui:ui_dropdown
        selectedTargetIndexes type:#intTab tabSizeVariable:true
    )

    /*=============================================================================================
                    ROLLOUT
    */
    rollout mainRollout "Hair and Fur Controller"
    (
        /* UI */
        multiListBox ui_multiListSource "Source Objects"
        pickButton ui_pbAddSource "Add" filter:filterHairAndFur width:45 align:#left across:3
        button ui_bSelectSource "Select" enabled:false width:45 align:#center
        button ui_bRemoveSource "Remove" enabled:false width:45 align:#right
        label ui_lblBlank1 ""
        multiListBox ui_multiListTarget "Target Objects"
        pickButton ui_pbAddTarget "Add" filter:filterHairAndFur width:45 align:#left across:3
        button ui_bSelectTarget "Select" enabled:false width:45 align:#center
        button ui_bRemoveTarget "Remove" enabled:false width:45 align:#right
        label ui_lblBlank2 ""
        dropdownlist ui_dropdown "Select Source"
        checkbox ui_chkHairLengths "Hair Length" checked:enableHairLength
        checkbox ui_chkHairProps "Hair Props" checked:enableHairProps
        checkbox ui_chkDynamics "Dynamics" checked:enableDynamics
        button ui_bUpdateTargets "Update Targets" enabled:false
        listbox ui_lbSelectedTargets "Selected Targets" readOnly:true


        /* Methods */
        fn getDropdownSourceObj = (local index = ui_dropdown.selection; if index > 0 then sourceObjects[index] else undefined)
        fn getSelectedIndexes lb = (local s = lb.selection; for i = 1 to s.count where s[i] == true collect i)
        fn getObjectsByIndexes indexArray nt = (for i in indexArray collect nt[i])

        fn refreshListBox lb arr = (lb.items = for obj in arr collect obj.name)
        fn refreshButtonEnables b lb = (b.enabled = not lb.selection.isEmpty)
        fn removeSelected lb arr = 
        (
            local toRemove = for i = lb.selection.count to 1 by -1 where lb.selection[i] == true collect i
            for i in toRemove do deleteItem arr i
        )
        fn addObject objectToAdd objectList otherObjectList affectTargetIndexes =
        (
            -- add to object list as long as it hasn't already been added
            appendIfUnique objectList objectToAdd

            -- remove it from other list if it is there
            local index = findItem otherObjectList objectToAdd
            if index > 0 then 
            (
                deleteItem otherObjectList index

                -- if removal may affect target indexes, then be sure to remove that index
                if affectTargetIndexes == true then
                (
                    local pos = findItem selectedTargetIndexes index
                    if pos > 0 then deleteItem selectedTargetIndexes index
                )
            )
        )
        fn selectObjectsFromListSelection lb nt = (select (getObjectsByIndexes (getSelectedIndexes lb) nt))

        fn refreshNodeTab nt isTarget = 
        (
            local toDelete = for i = nt.count to 1 by -1 where nt[i] == undefined collect i
            for index in toDelete do deleteItem nt index

            -- if we are dealing with the target object list, then we need to also
            --  remove indexes in selected targets that match those that we are removing
            if isTarget == true then
            (
                for index in toDelete do
                (
                    local pos = findItem selectedTargetIndexes index
                    if pos > 0 then deleteItem selectedTargetIndexes pos
                )
            )
        )
        fn refreshSourceButtons = (refreshButtonEnables ui_bRemoveSource ui_multiListSource; refreshButtonEnables ui_bSelectSource ui_multiListSource)
        fn refreshSourceList = (refreshListBox ui_multiListSource sourceObjects; refreshSourceButtons())
        fn refreshTargetButtons = (refreshButtonEnables ui_bRemoveTarget ui_multiListTarget; refreshButtonEnables ui_bSelectTarget ui_multiListTarget)
        fn refreshTargetList = (refreshListBox ui_multiListTarget targetObjects; refreshTargetButtons())
        fn refreshDropDown = (refreshListBox ui_dropdown sourceObjects)
        fn refreshUpdateButton = (ui_bUpdateTargets.enabled = ui_dropdown.selection != 0 AND ui_lbSelectedTargets.items.count > 0)
        fn refreshSelectedTargets = 
        (
            -- make selections in Target list box
            local ba = #{}
            for index in selectedTargetIndexes do ba[index] = true
            ui_multiListTarget.selection = ba

            -- populate selected targets list box
            local selectedTargets = getObjectsByIndexes selectedTargetIndexes targetObjects
            ui_lbSelectedTargets.items = for obj in selectedTargets collect obj.name
            refreshUpdateButton()
        )
        fn refreshAll = 
        (
            refreshSourceList(); refreshTargetList(); refreshSourceButtons()
            refreshTargetButtons(); refreshDropDown(); refreshSelectedTargets()
        )


        /* Events */
        on mainRollout open do (refreshNodeTab sourceObjects false; refreshNodeTab targetObjects true; refreshAll())
        on mainRollout reload do (refreshNodeTab sourceObjects false; refreshNodeTab targetObjects true; refreshAll())

        on ui_pbAddSource picked obj do (addObject obj sourceObjects targetObjects true; refreshSourceList(); refreshDropDown(); refreshTargetList())
        on ui_bSelectSource pressed do (selectObjectsFromListSelection ui_multiListSource sourceObjects)
        on ui_bRemoveSource pressed do (removeSelected ui_multiListSource sourceObjects; refreshSourceList(); refreshDropDown())
        on ui_multiListSource selectionEnd do (refreshSourceButtons())
        on ui_multiListSource rightClick do (ui_multiListSource.selection = #(); refreshSourceButtons())
        on ui_multiListSource doubleClick do (ui_multiListSource.selection = #{1..sourceObjects.count}; refreshSourceButtons())

        on ui_pbAddTarget picked obj do (addObject obj targetObjects sourceObjects false; refreshTargetList(); refreshSourceList(); refreshDropDown())
        on ui_bSelectTarget pressed do (selectObjectsFromListSelection ui_multiListTarget targetObjects)
        on ui_bRemoveTarget pressed do (removeSelected ui_multiListTarget targetObjects; selectedTargetIndexes = #(); refreshTargetList(); refreshSelectedTargets())
        on ui_multiListTarget selectionEnd do (refreshTargetButtons(); selectedTargetIndexes = getSelectedIndexes ui_multiListTarget; refreshSelectedTargets())
        on ui_multiListTarget rightClick do 
        (
            ui_multiListTarget.selection = #()
            selectedTargetIndexes = getSelectedIndexes ui_multiListTarget;
            refreshTargetButtons()
            refreshSelectedTargets()
        )
        on ui_multiListTarget doubleClick do 
        (
            ui_multiListTarget.selection = #{1..targetObjects.count}
            selectedTargetIndexes = getSelectedIndexes ui_multiListTarget;
            refreshTargetButtons()
            refreshSelectedTargets()
        )

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
                    local selectedTargets = getObjectsByIndexes selectedTargetIndexes targetObjects

                    -- get source data
                    local sourceData = SourceObjectData()
                    sourceData.initialize sourceObject
                    sourceData.calculateHairLengths()
                    sourceData.calculateObjectMeasurements()

                    -- modify targets
                    for obj in selectedTargets do (sourceData.modifyTargetObject obj enableHairLength enableHairProps enableDynamics)
                )
            )
        )
    )

    rollout analyzerRollout "Analyze Object"
    (
        pickButton ui_pbObject "Pick Object" filter:filterHairAndFur autoDisplay:true width:100 align:#center
        edittext ui_etDescription "" readOnly:true height:80

        on ui_pbObject picked obj do
        (
            local d = SourceObjectData()
            d.initialize obj
            d.calculateHairLengths()
            d.calculateObjectMeasurements()

            local ssDesc = StringStream ""
            local minl = d.getMinHairLength()
            local maxl = d.getMaxHairLength()
            local hc = d.getHairCountPerArea()
            local avg = d.getAverageDimension()
            format "MinLength: %\nMaxLength: %\nHairCnt/Area: %\nAvgDimension: %" minl maxl hc avg to:ssDesc
            ui_etDescription.text = (ssDesc as string)
        )
    )
)
