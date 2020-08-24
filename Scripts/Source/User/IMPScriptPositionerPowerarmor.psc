Scriptname IMPScriptPositionerPowerarmor extends ObjectReference Const

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.PowerarmorMarkerOnDestroyed_PUBLIC(Self)
EndEvent