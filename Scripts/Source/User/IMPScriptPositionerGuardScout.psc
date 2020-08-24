Scriptname IMPScriptPositionerGuardScout extends ObjectReference Const

Event OnLoad()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardScout.GuardScoutMarkerOnLoad_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardScout.GuardScoutMarkerOnMoved_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardScout.GuardScoutMarkerOnDestroyed_PUBLIC(Self)
EndEvent