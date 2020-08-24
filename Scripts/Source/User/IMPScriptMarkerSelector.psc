Scriptname IMPScriptMarkerSelector extends ObjectReference Const

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerMenu.HandleSelector_PUBLIC(Self)
EndEvent