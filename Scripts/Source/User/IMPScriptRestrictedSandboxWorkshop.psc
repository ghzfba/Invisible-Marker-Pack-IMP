Scriptname IMPScriptRestrictedSandboxWorkshop extends Quest

IMPScriptMain IMP

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorCaravanAssign")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorCaravanAssign")
EndEvent

;=========

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ObjectAssignedRef=akArgs[0] as ObjectReference
	ObjectReference OwnerRef=ObjectAssignedRef.GetActorRefOwner()
	IMP.RestrictedSandbox.IsCurrentJobIncompatible_PUBLIC(OwnerRef)
EndEvent


Event WorkshopParentScript.WorkshopActorCaravanAssign(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference AssignedActorRef=akArgs[0] as ObjectReference
	IMP.RestrictedSandbox.IsCurrentJobIncompatible_PUBLIC(AssignedActorRef)
EndEvent
