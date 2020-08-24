Scriptname IMPScriptMM_F4SEWorkshopAlias extends ReferenceAlias

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	if akReference
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.MarkerManagerF4SE.WorkshopOnGrabbed_PUBLIC(akReference)
	endif
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.WorkshopOnMoved_PUBLIC()
EndEvent