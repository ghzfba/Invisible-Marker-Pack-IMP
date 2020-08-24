Scriptname IMPScriptMarkerPreexMarkerEditor extends ObjectReference

ObjectReference PreexMarkerDisabledRef

Function HandleUnload()
	PreexMarkerDisabledRef.EnableNoWait()
	PreexMarkerDisabledRef=NONE
EndFunction

Function SetPreexMarkerDisabledRef(ObjectReference akMarkerRef)
	PreexMarkerDisabledRef=akMarkerRef
EndFunction