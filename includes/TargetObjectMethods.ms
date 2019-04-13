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

function __calculateGuideSplineLengthScale shapeObj splineIndex sourceMinLength sourceMaxLength =
(
    local targetLength = getSplineLength shapeObj splineIndex
    local scaleRange = Point2 (sourceMinLength / targetLength) (sourceMaxLength / targetLength)
    random scaleRange.x scaleRange.y
)

function __modifyTargetGuideSplineLengths targetObj sourceData =
(
    -- create spline shape of hair guides
    local targetHairMod = getHairAndFurModFromObject targetObj
    local targetShape = targetHairMod.ConvertGuidesToSplines instance:targetObj
    for splineIndex = 1 to numSplines targetShape do
    (
        -- build transformation matrix to scale down spline so that length falls within range of our source data
        local rootPos = __getGuideRootPosition targetShape splineIndex
        local scaleValue = __calculateGuideSplineLengthScale targetShape splineIndex sourceData.fMinLength sourceData.fMaxLength
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
        targetHairMod.HairRootThickness = sourceData.fRootThickness * propertyScaling
        targetHairMod.HairTipThickness = sourceData.fTipThickness * propertyScaling
        __modifyTargetGuideSplineLengths targetObj sourceData
    )
)
