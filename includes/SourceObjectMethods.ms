filein "SourceObjectData.ms"
filein "SharedMethods.ms"

function __processHairLengthOnSpline splineIndex data guideSplines =
(
    local lengths = getSegLengths guideSplines splineIndex
    local fullLength = lengths[lengths.count]
    if data.fMinLength > fullLength then data.fMinLength = fullLength
    if data.fMaxLength < fullLength then data.fMaxLength = fullLength
)

function __populateHairLengths data obj =
(
    local hairModRefObject = getHairAndFurModFromObject obj
    local guideSplines = hairModRefObject.ConvertGuidesToSplines instance:obj
    if numSplines guideSplines == 0 then
    (
        data.fMinLength = data.fMaxLength = 0
    )
    else
    (
        data.fMinLength = 999999.999
        data.fMaxLength = 0
        for i = 1 to numSplines guideSplines do
        (
            __processHairLengthOnSpline i data guideSplines
        )
    )
    delete guideSplines
)

function __populateHairCountPerArea data obj =
(
    local hairModRefObject = getHairAndFurModFromObject obj
    data.fHairCountPerArea = hairModRefObject.HairCount / calculateSurfaceArea obj
)

function buildReferenceObjectData obj =
(
    local data = SourceObjectData()

    __populateHairLengths data obj
    __populateHairCountPerArea data obj

    data -- return
)
