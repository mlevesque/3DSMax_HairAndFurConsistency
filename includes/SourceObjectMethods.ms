filein "SourceObjectData.ms"
filein "SharedMethods.ms"

function __processHairLengthOnSpline splineIndex sourceData guideSplines hairScale =
(
    local len = hairScale * getSplineLength guideSplines splineIndex
    if sourceData.fMinLength > len then sourceData.fMinLength = len
    if sourceData.fMaxLength < len then sourceData.fMaxLength = len
)

function __populateHairLengths sourceData sourceObj sourceHairMod =
(
    -- create spline shape of the hair guides in order to calculate lengths
    local guideSplines = sourceHairMod.ConvertGuidesToSplines instance:sourceObj
    local hairScale = sourceHairMod.HairScale / 100.0
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
            __processHairLengthOnSpline splineIndex sourceData guideSplines hairScale
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
    
    sourceData.p2Thickness = [sourceHairMod.HairRootThickness,sourceHairMod.HairTipThickness]
    sourceData.fHairSegments = sourceHairMod.HairSegments
    sourceData.fHairPasses = sourceHairMod.HairPasses
    sourceData.fHairRandScale = sourceHairMod.HairRandScale
    sourceData.fFlyawayPercentage = sourceHairMod.FlyawayPerc
    sourceData.fFlyawayStrength = sourceHairMod.FlyawayStren
    sourceData.fMessStrength = sourceHairMod.MessStren
    sourceData.iClumps = sourceHairMod.Clumps
    sourceData.fClumpsStren = sourceHairMod.ClumpsStren
    sourceData.fClumpsScruff = sourceHairMod.ClumpsScruff
    sourceData.fClumpsRot = sourceHairMod.ClumpsRot
    sourceData.fClumpsOffset = sourceHairMod.ClumpsOffset
    sourceData.fClumpsColors = sourceHairMod.ClumpsColors
    sourceData.fClumpsRand = sourceHairMod.ClumpsRand
    sourceData.fClumpsFlat = sourceHairMod.ClumpsFlat
    sourceData.p2Frizz = [sourceHairMod.FrizzRoot,sourceHairMod.FrizzTip]
    sourceData.p3FrizzFreq = [sourceHairMod.FrizzFreqX,sourceHairMod.FrizzFreqY,sourceHairMod.FrizzFreqZ]
    sourceData.p2Kink = [sourceHairMod.KinkRoot,sourceHairMod.KinkTip]
    sourceData.p3KinkFreq = [sourceHairMod.KinkFreqX,sourceHairMod.KinkFreqY,sourceHairMod.KinkFreqZ]
    sourceData.iMultiStrandCount = sourceHairMod.MultiStrandCount
    sourceData.p2MultiStrandSplay = [sourceHairMod.MultiStrandRootSplay,sourceHairMod.MultiStrandTipSplay]
    sourceData.fMultiRandomize = sourceHairMod.MultiRandomize
    sourceData.fMultiStrandTwist = sourceHairMod.MultiStrandTwist
    sourceData.fMultiStrandOffset = sourceHairMod.MultiStrandOffset
    sourceData.fMultiStrandAspect = sourceHairMod.MultiStrandAspect
    sourceData.fDynamicsStiffness = sourceHairMod.DynamicsStiffness
    sourceData.fDynamicsRootHold = sourceHairMod.DynamicsRootHold
    sourceData.fDynamicsDampen = sourceHairMod.DynamicsDampen
    sourceData.fDynamicsGravity = sourceHairMod.DynamicsGravity

    sourceData -- return
)
