Scriptname IMPScriptPositionerRestrictedSandbox extends ObjectReference Const

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.RestrictedSandbox.RestrictedSandboxMarkerOnPlaced_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.RestrictedSandbox.RestrictedSandboxMarkerOnDestroyed_PUBLIC(Self)
EndEvent