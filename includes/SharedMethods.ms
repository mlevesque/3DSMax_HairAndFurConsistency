/**
    Removes attributes with the given name from the given modifier.

    @param modifierObj
        The modifier to remove the attributes from. This should be of type EmptyModifier.
    @param attributeName
        The name of the attribute to remove.
 */
 mapped function removeAttributeFromModifier modifierObj attributeName =
 (
     if classof modifierObj == EmptyModifier then
     (
         local c = CustAttributes.count modifierObj baseobject:false
         local toDelete = #()
         for i = 1 to c do
         (
             local att = custAttributes.get modifierObj i baseobject:false
             if att.name == attributeName then
             (
                 toDelete[toDelete.count + 1] = i
             )
         )
         for i = toDelete.count to 1 by -1 do
         (
             custAttributes.delete modifierObj toDelete[i] baseobject:false
         )
     )
 )
 
 /**
     Removes attributes with the given name from all modifiers of the given object.
 
     @param obj
         The scene object that the attributes will be removed from.
     @param attributeName
         The name of the attribute to remove.
  */
 mapped function removeAttributeFromObject obj attributeName =
 (
     for modObj in obj.modifiers do removeAttributeFromModifier modObj attributeName
 )
 
 /**
     Returns the first found instance of an Empty Modifier from the given object.
 
     @param obj
         The scene object to find an Empty Modifier from.
 
     @return The first found Empty Modifier. Returns undefined if none are found.
  */
 function getFirstEmptyModifier obj =
 (
     local a = for modObj in obj.modifiers where classof modObj == EmptyModifier collect modObj
     if a.count > 0 then
     (
         a[1] -- return
     )
     else
     (
         undefined -- return
     )
 )
 
 /**
     Removes all instances of the given attribute (by name) from the given object and then adds the given
     attribute to the first Empty Modifer in the given object. If the given object does not have an
     Empty Modifier, then the given attribute is not added to the given object.
 
     @param obj
         The scene object to replace the given attribute with.
     @param attributeObj
         The attribute to add.
  */
 mapped function replaceAttributeInObject obj attributeObj =
 (
     -- Remove attribute from all places on the object
     removeAttributeFromObject obj (attributeObj.name as string)
 
     -- Find Empty Modifier
     local modObj = getFirstEmptyModifier obj
 
     -- Add the atribute to the obj
     CustAttributes.add modObj attributeObj
 )
 
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
