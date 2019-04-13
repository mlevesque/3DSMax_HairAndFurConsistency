filein "includes/SourceObjectMethods.ms"
filein "includes/TargetObjectMethods.ms"

(
    local test = transMatrix [1,2,3]
    print test

    local sourceObj = getNodeByName "source" exact:true
    local targetObj = getNodeByName "target" exact:true
    local sourceData = buildSourceObjectData sourceObj
    print "MLEVESQUE ======================="
    print sourceObj
    print targetObj
    print sourceHairInstance
    print sourceData
    print "+++++++++++++++++++++++++++++++++"
    modifyTargetWithSourceData targetObj sourceData
)
