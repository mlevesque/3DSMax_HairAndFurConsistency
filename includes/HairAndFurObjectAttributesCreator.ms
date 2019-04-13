filein "SharedMethods.ms"
filein "globals.ms"

mapped function buildHairAndFurObjectAttributes obj =
(
    local att = attributes HairAndFurObject_Attributes
    (
        rollout HairAndFurObjectRollout "Hair & Fur Object"
        (
            spinner ui_spinnerFurGroup "Fur Group" range:[0, 999999, DEFAULT_FUR_GROUP] type:#integer align:#left
            button ui_buttonRemove "Remove" align:#center

            on ui_spinnerFurGroup changed val do
            (
                setAppData $ APPDATA_INDEX_FUR_GROUP (val as string)
            )

            on ui_buttonRemove pressed do
            (
                deleteAppData $ APPDATA_INDEX_FUR
                deleteAppData $ APPDATA_INDEX_FUR_GROUP
                removeAttributeFromObject $ "HairAndFurObject_Attributes"
            )
        )
    )
    replaceAttributeInObject obj att
)

mapped function onCreateHairAndFurTargetObject obj =
(
    -- setup marker so that the controller can find this
    setAppData obj APPDATA_INDEX_FUR APPDATA_VALUE_FUR_TARGET
    setAppData obj APPDATA_INDEX_FUR_GROUP (DEFAULT_FUR_GROUP as string)
)

mapped function onCreateHairAndFurSourceObject obj =
(
    -- setup marker so that the controller can find this
    setAppData obj APPDATA_INDEX_FUR APPDATA_VALUE_FUR_SOURCE
    setAppData obj APPDATA_INDEX_FUR_GROUP (DEFAULT_FUR_GROUP as string)
)
