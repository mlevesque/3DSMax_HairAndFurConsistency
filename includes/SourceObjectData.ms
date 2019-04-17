struct SourceObjectData
(
    private
    /** Reference to source object and hair modifier */
    nSourceObject, mHairMod,
    /** Hair Length Range Calculations. Min (x) and Max (y) */
    p2HairLength, bCalculatedLengths = false,
    /** Average of bounding dimensions and numbre of hairs per squared area */
    fHairCountPerArea, fAvgDimension, bCalculatedObjectMeasurements = false,


    fn __getHairModFromObject obj =
    (
        local furMods = for modObj in obj.modifiers where classof modObj == HairMod collect modObj
        if furMods.count > 0 then furMods[1] else undefined -- return
    ),

    fn __getSplineLength shapeObj splineIndex =
    (
        local splineLengths = getSegLengths shapeObj splineIndex
        splineLengths[splineLengths.count] -- return
    ),

    fn __calculateHairLengthsOnObject obj hMod =
    (
        -- create spline shape of the hair guides in order to calculate lengths
        local guideSplines = hMod.ConvertGuidesToSplines instance:obj
        local hairScale = hMod.HairScale / 100.0
        local p2Result = Point2 0 0
        if numSplines guideSplines > 0 then
        (
            p2Result.x = 999999.999
            p2Result.y = 0
            for splineIndex = 1 to numSplines guideSplines do
            (
                local len = hairScale * (__getSplineLength guideSplines splineIndex)
                if p2Result.x > len then p2Result.x = len
                if p2Result.y < len then p2Result.y = len
            )
        )
        -- clean up spline shape
        delete guideSplines

        --return
        p2Result
    ),

    fn __getFaceAreas op obj = (for i = 1 to op.getNumFaces obj collect op.getFaceArea obj i),

    fn __calculateSurfaceArea obj hMod =
    (
        -- The hair and fur modifier needs to be disabled in order for the classof check to work
        hMod.enabled = false
        case (classof obj) of
        (
            Editable_Poly: (faceAreas = __getFaceAreas polyop obj)
            PolyMeshObject: (faceAreas = __getFaceAreas polyop obj)
            Editable_Mesh: (faceAreas = __getFaceAreas meshop obj)
            default: (faceAreas = #(1))
        )
        hMod.enabled = true
        local surfaceArea = 0.0
        for a in faceAreas do surfaceArea += a
        surfaceArea -- return
    ),

    fn __calculateHairCountPerArea obj hMod =
    (
        (hMod.HairCount as float) / (__calculateSurfaceArea obj hMod)
    ),
    
    fn __calculateAverageDimension obj hMod =
    (
        --first disable hair and fur because we don't want it to contribute to the dimensions
        hMod.enabled = false
        local dimensions = obj.max - obj.min
        local result = (dimensions.x + dimensions.y + dimensions.z) / 3
        hMod.enabled = true
        result -- return
    ),

    fn __constructGuideSplineMatrix rootPos scaleValue =
    (
        local result = scaleMatrix [scaleValue,scaleValue,scaleValue]
        preTranslate result [-rootPos.x,-rootPos.y,-rootPos.z]
        translate result rootPos
        result -- return
    ),

    fn __getGuideRootPosition shapeObj splineIndex =
    (
        getKnotPoint shapeObj splineIndex 1
    ),

    fn __calculateGuideSplineLengthScale targetShape =
    (
        local targetLength = 0
        for splineIndex = 1 to numSplines targetShape do
        (
            local len = __getSplineLength targetShape splineIndex
            if targetLength < len then targetLength = len
        )
        if targetLength == 0 then targetLength = 1
        local scaleRange = Point2 (p2HairLength.x / targetLength) (p2HairLength.y / targetLength)
        random scaleRange.x scaleRange.y
    ),

    fn __modifyTargetGuideSplineLengths targetObj targetHairMod =
    (
        -- create spline shape of hair guides
        local targetShape = targetHairMod.ConvertGuidesToSplines instance:targetObj
        local scaleValue = __calculateGuideSplineLengthScale targetShape
        local splineCount = numSplines targetShape
        for splineIndex = 1 to splineCount do
        (
            -- build transformation matrix to scale down spline so that length falls within range of our source data
            local rootPos = __getGuideRootPosition targetShape splineIndex
            local trans = __constructGuideSplineMatrix rootPos scaleValue

            -- use the transform on each knot
            local knotCount = numKnots targetShape splineIndex
            for knotIndex = 1 to knotCount do
            (
                local knotPos = getKnotPoint targetShape splineIndex knotIndex
                local transformedPos = knotPos * trans
                setKnotPoint targetShape splineIndex knotIndex transformedPos
            )
        )
        -- set modified shape back to hair mod and clean up spline shape
        updateShape targetShape
        targetHairMod.RecombFromSplines targetShape
        delete targetShape
    ),

    fn __calculateHairPropertyScaling targetObj targetHairMod =
    (
        local targetAvgDimension = __calculateAverageDimension targetObj targetHairMod

        -- if our source dimension is larger than our target, then we need to swap them
        --  in order for our scaling to be correct
        local a = fAvgDimension
        local b = targetAvgDimension
        if a > b then swap a b
        a / b -- return
    ),

    fn __calculateTargetHairCount targetObj targetHairMod =
    (
        local targetSurfaceArea = __calculateSurfaceArea targetObj targetHairMod
        ceil (targetSurfaceArea * fHairCountPerArea)
    ),


    public

    fn getMinHairLength = (p2HairLength.x),
    fn getMaxHairLength = (p2HairLength.y),
    fn getHairCountPerArea = (fHairCountPerArea),
    fn getAverageDimension = (fAvgDimension),

    fn initialize sourceObject = 
    (
        nSourceObject = sourceObject
        mHairMod = __getHairModFromObject nSourceObject
        bCalculatedLengths = bCalculatedObjectMeasurements = false
    ),

    fn calculateHairLengths =
    (
        p2HairLength = __calculateHairLengthsOnObject nSourceObject mHairMod
        bCalculatedLengths = true
    ),

    fn calculateObjectMeasurements =
    (
        fHairCountPerArea = __calculateHairCountPerArea nSourceObject mHairMod
        fAvgDimension = __calculateAverageDimension nSourceObject mHairMod
        bCalculatedObjectMeasurements = true
    ),

    fn modifyTargetObject targetObj bUseHairLengths bUseHairProperties bUseDynamics =
    (
        local targetHairMod = __getHairModFromObject targetObj

        if bUseHairProperties == true then
        (
            if bCalculatedObjectMeasurements == false then calculateObjectMeasurements()
            local propertyScale = __calculateHairPropertyScaling targetObj targetHairMod
            targetHairMod.HairCount = __calculateTargetHairCount targetObj targetHairMod
            targetHairMod.HairRootThickness = mHairMod.HairRootThickness * propertyScale
            targetHairMod.HairTipThickness = mHairMod.HairTipThickness * propertyScale
            targetHairMod.HairSegments = mHairMod.HairSegments
            targetHairMod.HairPasses = mHairMod.HairPasses
            targetHairMod.HairDensity = mHairMod.HairDensity
            targetHairMod.HairScale = 100.0
            targetHairMod.HairCutLength  = mHairMod.HairCutLength
            targetHairMod.HairRandScale = mHairMod.HairRandScale
            targetHairMod.HairDisplacement = mHairMod.HairDisplacement
            targetHairMod.MaterialTipFade = mHairMod.MaterialTipFade
            targetHairMod.FlyawayPerc = mHairMod.FlyawayPerc
            targetHairMod.FlyawayStren = mHairMod.FlyawayStren
            targetHairMod.MessStren = mHairMod.MessStren
            targetHairMod.Clumps = mHairMod.Clumps
            targetHairMod.ClumpsStren = mHairMod.ClumpsStren
            targetHairMod.ClumpsScruff = mHairMod.ClumpsScruff
            targetHairMod.ClumpsRot = mHairMod.ClumpsRot
            targetHairMod.ClumpsOffset = mHairMod.ClumpsOffset
            targetHairMod.ClumpsColors = mHairMod.ClumpsColors
            targetHairMod.ClumpsRand = mHairMod.ClumpsRand
            targetHairMod.ClumpsFlat = mHairMod.ClumpsFlat
            targetHairMod.FrizzRoot = mHairMod.FrizzRoot
            targetHairMod.FrizzTip = mHairMod.FrizzTip
            targetHairMod.FrizzFreqX = mHairMod.FrizzFreqX
            targetHairMod.FrizzFreqY = mHairMod.FrizzFreqY
            targetHairMod.FrizzFreqZ = mHairMod.FrizzFreqZ
            targetHairMod.KinkRoot = mHairMod.KinkRoot
            targetHairMod.KinkTip = mHairMod.KinkTip
            targetHairMod.KinkFreqX = mHairMod.KinkFreqX
            targetHairMod.KinkFreqY = mHairMod.KinkFreqY
            targetHairMod.KinkFreqZ = mHairMod.KinkFreqZ
            targetHairMod.MultiStrandCount = mHairMod.MultiStrandCount
            targetHairMod.MultiStrandRootSplay = mHairMod.MultiStrandRootSplay
            targetHairMod.MultiStrandTipSplay = mHairMod.MultiStrandTipSplay
            targetHairMod.MultiRandomize = mHairMod.MultiRandomize
            targetHairMod.MultiStrandTwist = mHairMod.MultiStrandTwist
            targetHairMod.MultiStrandOffset = mHairMod.MultiStrandOffset
            targetHairMod.MultiStrandAspect = mHairMod.MultiStrandAspect
        )

        if bUseDynamics == true then
        (
            targetHairMod.DynamicsStiffness = mHairMod.DynamicsStiffness
            targetHairMod.DynamicsRootHold = mHairMod.DynamicsRootHold
            targetHairMod.DynamicsDampen = mHairMod.DynamicsDampen
            targetHairMod.DynamicsGravity = mHairMod.DynamicsGravity
        )

        if bUseHairLengths == true then
        (
            if bCalculatedLengths == false then calculateHairLengths()
            __modifyTargetGuideSplineLengths targetObj targetHairMod
        )
    )
)
