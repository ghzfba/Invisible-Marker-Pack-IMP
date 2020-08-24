Scriptname IMPScriptGuardFollowerController extends ObjectReference Const

Keyword property LinkFollowerMarkerKeyword auto const mandatory

Event OnLoad()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	ObjectReference OwnerRef=GetRefsLinkedToMe(LinkFollowerMarkerKeyword)[0]
	WorkshopObjectScript MyWorkshopObjectRef=(Self as ObjectReference) as WorkshopObjectScript

	if OwnerRef  &&  MyWorkshopObjectRef.RequiresActor() &&  MyWorkshopObjectRef.IsActorAssigned()==False
		MyWorkshopObjectRef.AssignActor(OwnerRef as WorkshopNPCScript)
	endif
EndEvent