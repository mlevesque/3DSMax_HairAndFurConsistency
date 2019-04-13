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

function __modifyTargetGuideSplineLengths targetObject sourceData =
(
    -- create spline shape of hair guides
    local targetHairMod = getHairAndFurModFromObject targetObject
    local targetShape = targetHairMod.ConvertGuidesToSplines instance:targetObject
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

function __calculateTargetHairCount targetObject hairCountPerArea =
(
    local targetSurfaceArea = calculateSurfaceArea targetObject
    ceil (targetSurfaceArea * hairCountPerArea)
)

mapped function modifyTargetWithSourceData targetObject sourceData =
(
    local targetHairMod = getHairAndFurModFromObject targetObject
    if targetHairMod != undefined then
    (
        targetHairMod.HairCount = __calculateTargetHairCount targetObject sourceData.fHairCountPerArea
        __modifyTargetGuideSplineLengths targetObject sourceData
    )
)
