fileIn "SharedMethods.ms"

function __constructGuideSplineMatrix rootPos scaleValue =
(
    local result = scaleMatrix [scaleValue,scaleValue,scaleValue]
    preTranslate result [-rootPos.x,-rootPos.y,-rootPos.z]
    translate result rootPos
    result -- return
)

function __getGuideRootPosition shapeObj splineIndex =
(
    getKnotPoint shapeObj splineIndex 1
)

function __calculateGuideSplineLengthScale targetShape sourceMinLength sourceMaxLength =
(
    local targetLength = 0
    for splineIndex = 1 to numSplines targetShape do
    (
        local l = getSplineLength targetShape splineIndex
        if l > targetLength then targetLength = l
    )
    if targetLength == 0 then targetLength = 1
    local scaleRange = Point2 (sourceMinLength / targetLength) (sourceMaxLength / targetLength)
    random scaleRange.x scaleRange.y
)

function __modifyTargetGuideSplineLengths targetObj sourceData =
(
    -- create spline shape of hair guides
    local targetHairMod = getHairAndFurModFromObject targetObj
    local targetShape = targetHairMod.ConvertGuidesToSplines instance:targetObj
    local scaleValue = __calculateGuideSplineLengthScale targetShape sourceData.fMinLength sourceData.fMaxLength
    for splineIndex = 1 to numSplines targetShape do
    (
        -- build transformation matrix to scale down spline so that length falls within range of our source data
        local rootPos = __getGuideRootPosition targetShape splineIndex
        local trans = __constructGuideSplineMatrix rootPos scaleValue

        -- use the transform on each knot
        for knotIndex = 1 to numKnots targetShape splineIndex do
        (
            local knotPos = getKnotPoint targetShape splineIndex knotIndex
            setKnotPoint targetShape splineIndex knotIndex (knotPos * trans)
        )
    )
    -- set modified shape back to hair mod and clean up spline shape
    updateShape targetShape
    targetHairMod.RecombFromSplines targetShape
    delete targetShape
)

function __calculateTargetHairCount targetObj hairCountPerArea =
(
    local targetSurfaceArea = calculateSurfaceArea targetObj
    ceil (targetSurfaceArea * hairCountPerArea)
)

function __calculateHairPropertyScaling targetObj targetHairMod sourceAvgDimension =
(
    -- temporarily disable hair when calculating dimensions so hair isn't included
    targetHairMod.enabled = false
    local targetAvgDimension = calculateAverageDimension targetObj
    targetHairMod.enabled = true

    -- if our source dimension is larger than our target, then we need to swap them
    --  in order for our scaling to be correct
    local a = sourceAvgDimension
    local b = targetAvgDimension
    if a > b then swap a b
    a / b -- return
)

mapped function modifyTargetWithSourceData targetObj sourceData =
(
    local targetHairMod = getHairAndFurModFromObject targetObj
    if targetHairMod != undefined then
    (
        local propertyScaling = __calculateHairPropertyScaling targetObj targetHairMod sourceData.fAvgDimension
        targetHairMod.HairCount = __calculateTargetHairCount targetObj sourceData.fHairCountPerArea

        targetHairMod.HairRootThickness = sourceData.p2Thickness.x * propertyScaling
        targetHairMod.HairTipThickness = sourceData.p2Thickness.y * propertyScaling
        targetHairMod.HairSegments = sourceData.fHairSegments
        targetHairMod.HairPasses = sourceData.fHairPasses
        targetHairMod.FlyawayPerc = sourceData.fFlyawayPercentage
        targetHairMod.FlyawayStren = sourceData.fFlyawayStrength
        targetHairMod.MessStren = sourceData.fMessStrength
        targetHairMod.Clumps = sourceData.iClumps
        targetHairMod.ClumpsStren = sourceData.fClumpsStren
        targetHairMod.ClumpsScruff = sourceData.fClumpsScruff
        targetHairMod.ClumpsRot = sourceData.fClumpsRot
        targetHairMod.ClumpsOffset = sourceData.fClumpsOffset
        targetHairMod.ClumpsColors = sourceData.fClumpsColors
        targetHairMod.ClumpsRand = sourceData.fClumpsRand
        targetHairMod.ClumpsFlat = sourceData.fClumpsFlat
        targetHairMod.FrizzRoot = sourceData.p2Frizz.x
        targetHairMod.FrizzTip = sourceData.p2Frizz.y
        targetHairMod.FrizzFreqX = sourceData.p3FrizzFreq.x
        targetHairMod.FrizzFreqY = sourceData.p3FrizzFreq.y
        targetHairMod.FrizzFreqZ = sourceData.p3FrizzFreq.z
        targetHairMod.KinkRoot = sourceData.p2Kink.x
        targetHairMod.KinkTip = sourceData.p2Kink.y
        targetHairMod.KinkFreqX = sourceData.p3KinkFreq.x
        targetHairMod.KinkFreqY = sourceData.p3KinkFreq.y
        targetHairMod.KinkFreqZ = sourceData.p3KinkFreq.z
        targetHairMod.MultiStrandCount = sourceData.iMultiStrandCount
        targetHairMod.MultiStrandRootSplay = sourceData.p2MultiStrandSplay.x
        targetHairMod.MultiStrandTipSplay = sourceData.p2MultiStrandSplay.y
        targetHairMod.MultiRandomize = sourceData.fMultiRandomize
        targetHairMod.MultiStrandTwist = sourceData.fMultiStrandTwist
        targetHairMod.MultiStrandOffset = sourceData.fMultiStrandOffset
        targetHairMod.MultiStrandAspect = sourceData.fMultiStrandAspect
        targetHairMod.DynamicsStiffness = sourceData.fDynamicsStiffness
        targetHairMod.DynamicsRootHold = sourceData.fDynamicsRootHold
        targetHairMod.DynamicsDampen = sourceData.fDynamicsDampen
        targetHairMod.DynamicsGravity = sourceData.fDynamicsGravity

        __modifyTargetGuideSplineLengths targetObj sourceData
    )
)
