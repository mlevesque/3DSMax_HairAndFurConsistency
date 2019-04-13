filein "SharedMethods.ms"
filein "definitions.ms"

mapped function buildHairAndFurObjectAttributes obj =
(
    local att = attributes HairAndFurObject_Attributes
    (
        local DEF = HFCDefinitions()

        rollout HairAndFurObjectRollout "Hair & Fur Object"
        (
            spinner ui_spinnerFurGroup "Fur Group" range:[DEF.MIN_FUR_GROUP, DEF.MAX_FUR_GROUP, DEF.DEFAULT_FUR_GROUP] type:#integer align:#left
            button ui_buttonRemove "Remove" align:#center

            on ui_spinnerFurGroup changed val do
            (
                setAppData $ DEF.APPDATA_INDEX_FUR_GROUP (val as string)
            )

            on ui_buttonRemove pressed do
            (
                deleteAppData $ DEF.APPDATA_INDEX_FUR
                deleteAppData $ DEF.APPDATA_INDEX_FUR_GROUP
                removeAttributeFromObject $ "HairAndFurObject_Attributes"
            )
        )
    )
    replaceAttributeInObject obj att
)

mapped function onCreateHairAndFurTargetObject obj =
(
    local DEF = HFCDefinitions()

    -- setup marker so that the controller can find this
    setAppData obj DEF.APPDATA_INDEX_FUR DEF.APPDATA_VALUE_FUR_TARGET
    setAppData obj DEF.APPDATA_INDEX_FUR_GROUP (DEF.DEFAULT_FUR_GROUP as string)
)

mapped function onCreateHairAndFurSourceObject obj =
(
    local DEF = HFCDefinitions()

    -- setup marker so that the controller can find this
    setAppData obj DEF.APPDATA_INDEX_FUR DEF.APPDATA_VALUE_FUR_SOURCE
    setAppData obj DEF.APPDATA_INDEX_FUR_GROUP (DEF.DEFAULT_FUR_GROUP as string)
)
