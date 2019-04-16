 /**
    Returns the fist found Hair and Fur modifier on the given scene object.

    @param obj
        The scene object to get the Hair and Fur modifier from.

    @return
        The Hair and Fur modifier found on the given object. If none was found, then returns undefined.
  */
 function getHairAndFurModFromObject obj =
 (
     local furMods = for modObj in obj.modifiers where classof modObj == HairMod collect modObj
     if furMods.count > 0 then
    (
        furMods[1] -- return
    )
    else
    (
        undefined -- return
    )
 )

 /**
    Calculates the surface area of the given object.

    @param obj
        The scene object to get the surface area from.

    @return
        The surface area.
  */
 function calculateSurfaceArea obj =
 (
    local faceAreas = for i = 1 to polyop.getNumFaces obj collect polyop.getFaceArea obj i
    local surfaceArea = 0
    for a in faceAreas do surfaceArea += a
    surfaceArea -- return
 )

 /**
    Returns the length of the spline at the given index of the given shape object.

    @param splineObject
        The spline object that contains the spline we want to get the length from.
    @param splineIndex
        The index of the spline within the given spline object that we want the length from.

    @return
        The length of the spline.
  */
 function getSplineLength splineObject splineIndex =
 (
    local lengths = getSegLengths splineObject splineIndex
    lengths[lengths.count]
 )

 /**
    Returns the averaged dimensions of the given scene object.

    @param obj
        The scene object to get the average dimension from.

    @return The average dimension value of the given object.
  */
 function calculateAverageDimension obj =
 (
    local dimensions = obj.max - obj.min
    (dimensions.x + dimensions.y + dimensions.z) / 3
 )
 