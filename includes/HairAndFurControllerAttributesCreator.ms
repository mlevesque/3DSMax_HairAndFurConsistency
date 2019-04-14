filein "SharedMethods.ms"
filein "definitions.ms"
filein "SourceObjectMethods.ms"
filein "TargetObjectMethods.ms"

struct HFObject
(
    furGroup,
    obj
)

mapped function buildHairAndFurControllerAttributes obj =
(
    local att = attributes HairAndFurController_Attributes
    (
        rollout HairAndFurControllerRollout "Hair & Fur Controller"
        (
            local DEF = HFCDefinitions()

            local aSourceObjects = #()
            local aTargetObjects = #()

            MultiListBox listSourceObjects "Source Objects" readOnly:true
            button butSelectSourceObject "Select" enabled6:false width:65 align:#left across:2
            button butRefreshSourceObjects "Refresh" enabled:true width:65 align:#right
            button butTargetUpdateFromSourceList "Modify Target(s)" enabled:false
            label lblBlank1 ""
            MultiListBox listTargetObjects "Target Objects" readOnly:true
            button butSelectTargetObject "Select" enabled:false width:65 align:#left across:2
            button butRefreshTargetObjects "Refresh" enabled:true width:65 align:#right
            button butTargetUpdateFromTargetList "Modify Target(s)" enabled:false
            label lblBlank2 ""
            button butRemove "Remove Controller" enabled:true


            function sortFunc element1 element2 =
            (
                case of
                (
                    (element1.furGroup < element2.furGroup): -1
                    (element1.furGroup > element2.furGroup): 1
                    default: 0
                )
            )

            function getObjectsSelectedFromListBox list objectArray =
            (
                -- returns array of object containers that were selected in list
                for i = 1 to list.selection.count where list.selection[i] == true collect objectArray[i]
            )

            function getFurGroupsSelectedFromListBox list objectArray =
            (
                -- returns array of fur groups that were selected in list
                local arr = for i = 1 to list.selection.count where list.selection[i] == true collect objectArray[i].furGroup
                makeUniqueArray arr
            )

            function getIndexOfFoundFurGroupInArray furGroup arr =
            (
                local indexMin = 1
                local indexMax = arr.count
                local found = false
                -- find an object with the given fur group
                -- since the list should be sorted, we will use binary search (O(logn)) to find a match
                if arr.count > 0 then
                (
                    do
                    (
                        local index = floor (indexMin + ((indexMax - indexMin) / 2))
                        local fg = arr[index].furGroup
                        case of
                        (
                            (fg < furGroup): (indexMax = index - 1)
                            (fg > furGroup): (indexMin = index + 1)
                            default: (found = true)
                        )
                    ) while indexMin < indexMax AND found == false
                )

                if found == true then index else 0
            )

            mapped function getSourceObjectByFurGroup furGroup =
            (
                -- do binary search to find index
                local foundIndex = getIndexOfFoundFurGroupInArray furGroup aSourceObjects

                -- return found object, or undefined if not found
                if foundIndex == 0 then undefined else aSourceObjects[foundIndex].obj
            )

            mapped function getTargetObjectsByFurGroup furGroup =
            (
                -- do binary search to find index
                local foundIndex = getIndexOfFoundFurGroupInArray furGroup aTargetObjects

                local foundObjects = #()

                -- only continue if we found a match
                if foundIndex != 0 then
                (
                    -- there may be more than one match, so collect all matches
                    -- collect from index and descending
                    foundObjects = for i = foundIndex to 1 by -1 while aTargetObjects[i].furGroup == furGroup collect aTargetObjects[i].obj
                    --collect from index+1 and ascending
                    join foundObjects (for i = foundIndex+1 to aTargetObjects.count by 1 while aTargetObjects[i].furGroup == furGroup collect aTargetObjects[i].obj)
                )

                foundObjects -- return
            )

            function populateListBox list arr =
            (
                local items = #()
                for index = 1 to arr.count do
                (
                    local ssText = StringStream ""
                    format "% - %" (arr[index].furGroup as string) arr[index].obj.name to:ssText
                    append items (ssText as string)
                )
                list.items = items
            )

            function refreshObjectSet arr appdataType =
            (
                for obj in objects where getAppData obj DEF.APPDATA_INDEX_FUR == appdataType do
                (
                    local fg = (getAppData obj DEF.APPDATA_INDEX_FUR_GROUP) as integer
                    if fg != undefined AND fg >= DEF.MIN_FUR_GROUP AND fg <= DEF.MAX_FUR_GROUP then
                    (
                        append arr (HFObject furGroup:fg obj:obj)
                    )
                )

                -- sort by fur group
                qsort arr sortFunc
            )

            function refreshSourceObjects =
            (
                free aSourceObjects
                aSourceObjects = #()
                refreshObjectSet aSourceObjects DEF.APPDATA_VALUE_FUR_SOURCE
                populateListBox listSourceObjects aSourceObjects
            )

            function refreshTargetObjects =
            (
                free aTargetObjects
                aTargetObjects = #()
                refreshObjectSet aTargetObjects DEF.APPDATA_VALUE_FUR_TARGET
                populateListBox listTargetObjects aTargetObjects
            )

            function updateSourceObjectsButtons =
            (
                butSelectSourceObject.enabled = butTargetUpdateFromSourceList.enabled = (not listSourceObjects.selection.isEmpty)
            )

            function updateTargetObjectsButtons =
            (
                butSelectTargetObject.enabled = butTargetUpdateFromTargetList.enabled = (not listTargetObjects.selection.isEmpty)
            )


            /* ====== UI EVENTS ====== */

            -- ROLLOUT EVENTS
            on HairAndFurControllerRollout open do 
            (
                refreshSourceObjects()
                refreshTargetObjects()
                updateSourceObjectsButtons()
                updateTargetObjectsButtons()
            )

            -- LISTBOX EVENTS
            on listSourceObjects selectionEnd do (updateSourceObjectsButtons())
            on listTargetObjects selectionEnd do (updateTargetObjectsButtons())
            on listSourceObjects rightClick do
            (
                listSourceObjects.selection = 0
                updateSourceObjectsButtons()
            )
            on listTargetObjects rightClick do
            (
                listTargetObjects.selection = 0
                updateTargetObjectsButtons()
            )

            -- REFRESH BUTTON EVENTS
            on butRefreshSourceObjects pressed do (refreshSourceObjects())
            on butRefreshTargetObjects pressed do (refreshTargetObjects())

            -- SELECT BUTTON EVENTS
            on butSelectSourceObject pressed do 
            (
                local objectContainers = getObjectsSelectedFromListBox listSourceObjects aSourceObjects
                select (for c in objectContainers collect c.obj)
            )
            on butSelectTargetObject pressed do
            (
                local objectContainers = getObjectsSelectedFromListBox listTargetObjects aTargetObjects
                select (for c in objectContainers collect c.obj)
            )

            -- UPDATE TARGET OBJECTS FROM SELECTED SOURCE LIST
            on butTargetUpdateFromSourceList pressed do
            (
                -- get all fur groups selected
                local furGroupList = getFurGroupsSelectedFromListBox listSourceObjects aSourceObjects

                -- modifiy all target objects for each fur group
                for fg in furGroupList do 
                (
                    local sourceObject = getSourceObjectByFurGroup fg

                    if sourceObject != undefined then
                    (
                        local sourceData = buildSourceObjectData sourceObject
                        local targetObjectList = getTargetObjectsByFurGroup fg
                        for obj in targetObjectList do
                        (
                            modifyTargetWithSourceData obj sourceData
                        )
                    )
                )
            )

            -- UPDATE TARGET OBJECTS FROM SELECTED TARGET LIST
            on butTargetUpdateFromTargetList pressed do
            (
                local targetObjectContainerList = getObjectsSelectedFromListBox listTargetObjects aTargetObjects
                local fg = 0
                local sourceData = undefined
                for targetObjectContainer in targetObjectContainerList do
                (
                    -- since the target object container list should be sorted, we can do the following small optimization regarding caching the sourceData
                    if fg != targetObjectContainer.furGroup then
                    (
                        fg = targetObjectContainer.furGroup
                        local sourceObject = getSourceObjectByFurGroup fg
                        if sourceObject == undefined then sourceData = undefined else sourceData = buildSourceObjectData sourceObject
                    )

                    -- update target object but only if we have the source data
                    if sourceData != undefined then
                    (
                        modifyTargetWithSourceData targetObjectContainer.obj sourceData
                    )
                )
            )

            -- REMOVE CONTROLLER BUTTON EVENT
            on butRemove pressed do
            (
                removeAttributeFromObject $ "HairAndFurController_Attributes"
            )
        )
    )
    replaceAttributeInObject obj att
)
