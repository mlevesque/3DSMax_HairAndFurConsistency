filein "SourceObjectData.ms"
filein "SharedMethods.ms"

function __processHairLengthOnSpline splineIndex sourceData guideSplines =
(
    local fullLength = getSplineLength guideSplines splineIndex
    if sourceData.fMinLength > fullLength then sourceData.fMinLength = fullLength
    if sourceData.fMaxLength < fullLength then sourceData.fMaxLength = fullLength
)

function __populateHairLengths sourceData sourceObj sourceHairMod =
(
    -- create spline shape of the hair guides in order to calculate lengths
    local guideSplines = sourceHairMod.ConvertGuidesToSplines instance:sourceObj
    if numSplines guideSplines == 0 then
    (
        sourceData.fMinLength = sourceData.fMaxLength = 0
    )
    else
    (
        sourceData.fMinLength = 999999.999
        sourceData.fMaxLength = 0
        for splineIndex = 1 to numSplines guideSplines do
        (
            __processHairLengthOnSpline splineIndex sourceData guideSplines
        )
    )
    -- clean up spline shape
    delete guideSplines
)

function __populateHairCountPerArea sourceData sourceObj sourceHairMod =
(
    sourceData.fHairCountPerArea = sourceHairMod.HairCount / calculateSurfaceArea sourceObj
)

function __populateAverageDimension sourceData sourceObj =
(
    --first disable hair and fur because we don't want it to contribute to the dimensions
    local sourceHairMod = getHairAndFurModFromObject sourceObj
    sourceHairMod.enabled = false
    sourceData.fAvgDimension = calculateAverageDimension sourceObj
    sourceHairMod.enabled = true
)

function buildSourceObjectData sourceObj =
(
    local sourceData = SourceObjectData()

    local sourceHairMod = getHairAndFurModFromObject sourceObj
    __populateHairLengths sourceData sourceObj sourceHairMod
    __populateHairCountPerArea sourceData sourceObj sourceHairMod
    __populateAverageDimension sourceData sourceObj
    sourceData.fRootThickness = sourceHairMod.HairRootThickness
    sourceData.fTipThickness = sourceHairMod.HairTipThickness

    sourceData -- return
)
