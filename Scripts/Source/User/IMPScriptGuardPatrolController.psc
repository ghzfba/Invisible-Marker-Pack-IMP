Scriptname IMPScriptGuardPatrolController extends ObjectReference

Event OnLoad()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	GetActorRefOwner().SetLinkedRef(Self, IMP.IMP_LinkGuardPatrolController)
EndEvent

Event OnUnload()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	GetActorRefOwner().SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolController)
EndEvent