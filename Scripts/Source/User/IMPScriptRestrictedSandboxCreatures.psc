Scriptname IMPScriptRestrictedSandboxCreatures extends Quest Conditional

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
RefCollectionAlias property CreatureCollection auto const mandatory
ReferenceAlias property CreatureAliasTemplateEXT auto const mandatory
LocationAlias property SettlementNameAlias auto const mandatory

Message property IMP_RestrictedSandboxAssignCreatureOnlyMESGn auto const mandatory
Message property IMP_RestrictedSandboxUnassignedCreatureFromWorkMESGn auto const mandatory

IMPScriptMain IMP


RefCollectionAlias property WorkshopWorkObjectCollection auto const mandatory
RefCollectionAlias property WorkshopWorkObjectBLOCKEDCollection auto const mandatory


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	InitializeCollections()

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectBuilt")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectBuilt")
EndEvent

;=========

Event WorkshopParentScript.WorkshopObjectBuilt(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ResourceRef=akArgs[0] as ObjectReference

	if ResourceRef.HasKeyword(IMP.WorkshopWorkObject) 
		if ResourceRef.HasKeyword(IMP.IMP_IsCreaturePositioner) == False  &&\
		ResourceRef.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner) == False  &&\
		ResourceRef.HasKeyword(IMP.IMP_IsGuardPatrolPositioner) == False  &&\
		ResourceRef.HasKeyword(IMP.IMP_IsGuardScoutPositioner) == False
			WorkshopWorkObjectCollection.AddRef(ResourceRef)
		endif
	endif
EndEvent


;=====================
; FUNCTION FOR INITIALIZATION
;=====================

Function InitializeCollections()
	;*** workshop collection ***
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)

	;*** settler collection ***
	Int i=0
	while i<WorkshopCollectionEXT.GetCount()
		ObjectReference iWorkshopRef=WorkshopCollectionEXT.GetAt(i)
		if iWorkshopRef.Is3DLoaded()
			GetSettlementCreatures(iWorkshopRef)
		endif
		i+=1
	endwhile
EndFunction


Function GetSettlementCreatures(ObjectReference akWorkshopRef)
	if akWorkshopRef
		CreatureCollection.RemoveAll()

		ObjectReference[] WorkshopResourceRefs=akWorkshopRef.GetWorkshopResourceObjects()
		Int WorkshopResourceCount=WorkshopResourceRefs.length

		if WorkshopResourceCount > 0
			Int i=0
			while i < WorkshopResourceCount
				ObjectReference iResourceRef=WorkshopResourceRefs[i]

				if \
				iResourceRef as Actor && \
				iResourceRef.HasKeyword(IMP.ActorTypeTurret) == False  && \
				iResourceRef.HasKeyword(IMP.ActorTypeNPC) == False  && \
				iResourceRef.HasKeyword(IMP.ActorTypeRobot) == False  && \
				(iResourceRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction) == False
					SetCreature(iResourceRef)
				endif


				if iResourceRef.HasKeyword(IMP.WorkshopWorkObject)
					if iResourceRef.HasKeyword(IMP.IMP_IsCreaturePositioner) == False  &&\
					iResourceRef.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner) == False  &&\
					iResourceRef.HasKeyword(IMP.IMP_IsGuardPatrolPositioner) == False  &&\
					iResourceRef.HasKeyword(IMP.IMP_IsGuardScoutPositioner) == False
						WorkshopWorkObjectCollection.AddRef(iResourceRef)
					endif
				endif


				i+=1
			endwhile
		endif
	endif
EndFunction


;=========


Function SetCreature(ObjectReference akCreatureRef)
	if akCreatureRef
		akCreatureRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, (akCreatureRef.HasKeyword(IMP.WorkshopAllowCommand) as Bool) as Int)
		akCreatureRef.AddKeyword(IMP.WorkshopAllowCommand)
		CreatureAliasTemplateEXT.ApplyToRef(akCreatureRef)
		CreatureCollection.AddRef(akCreatureRef)
	endif
EndFunction

Function SetCreature_PUBLIC(ObjectReference akCreatureRef)
	SetCreature(akCreatureRef)
EndFunction


Function UnsetCreature(ObjectReference akCreatureRef)
	if akCreatureRef
		Bool bRestoreKeyword=akCreatureRef.GetValue(IMP.IMP_HasCreatureCommandKeyword) as Bool
		if bRestoreKeyword
			akCreatureRef.AddKeyword(IMP.WorkshopAllowCommand)
		else
			akCreatureRef.RemoveKeyword(IMP.WorkshopAllowCommand)
		endif
		CreatureCollection.RemoveRef(akCreatureRef)
	endif
EndFunction



;===============================
; MENUS
;===============================

Message property IMP_RestrictedSanboxAssigningSuccededMESGn auto const mandatory
Message property IMP_RestrictedSanboxUnassigningSuccededMESGn auto const mandatory
Message property IMP_RestrictedSandboxUnassignMESGb auto const mandatory
ReferenceAlias property SettlerNameAlias auto const mandatory

Function AssignSandboxerCreatureToMarker(ObjectReference akCreatureRef, ObjectReference akMarkerRef)
	if akCreatureRef && akMarkerRef
		Actor CreatureActorRef=akCreatureRef as Actor

		if akCreatureRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker) == False
			akCreatureRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			SettlerNameAlias.ForceRefTo(akCreatureRef)
			IMP_RestrictedSanboxAssigningSuccededMESGn.Show()

		elseif akMarkerRef == akCreatureRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			SettlerNameAlias.ForceRefTo(akCreatureRef)
			Int iButton=IMP_RestrictedSandboxUnassignMESGb.Show()
			if iButton==1
				akCreatureRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
				IMP_RestrictedSanboxUnassigningSuccededMESGn.Show()
			endif

		elseif akMarkerRef != akCreatureRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			SettlerNameAlias.ForceRefTo(akCreatureRef)
			akCreatureRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			(akCreatureRef as Actor).EvaluatePackage()
			Utility.Wait(0.5)
			akCreatureRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			(akCreatureRef as Actor).EvaluatePackage()
			IMP_RestrictedSanboxAssigningSuccededMESGn.Show()
			
		endif

	endif
EndFunction

Function AssignSandboxerCreatureToMarker_PUBLIC(ObjectReference akCreatureRef, ObjectReference akMarkerRef)
	AssignSandboxerCreatureToMarker(akCreatureRef, akMarkerRef)
EndFunction

;=========

Message property IMP_RestrictedSandboxCreatureEntryMenuMESGb auto const mandatory
Int CreatureLinkedToSandboxMarkerCount_cond Conditional
ObjectReference[] CreatureLinkedToSandboxMarkerRefs

Function ShowRestrictedSandboxCreatureMarkerMenu(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	
		CreatureLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		CreatureLinkedToSandboxMarkerCount_cond=CreatureLinkedToSandboxMarkerRefs.length
		
		Int iButton=IMP_RestrictedSandboxCreatureEntryMenuMESGb.Show(CreatureLinkedToSandboxMarkerCount_cond)
		if iButton==1
			IMP.Pin.Pin_AddActorArrayToCollection_PUBLIC(CreatureLinkedToSandboxMarkerRefs, akPositionerRef)
		elseif iButton==2
			IMP.RestrictedSandbox.ShowRestrictedSandboxRadiusMenu_PUBLIC(akPositionerRef)
			CreatureCollection.EvaluateAll()
		endif
	endif
EndFunction

Function ShowRestrictedSandboxCreatureMarkerMenu_PUBLIC(ObjectReference akPositionerRef)
	ShowRestrictedSandboxCreatureMarkerMenu(akPositionerRef)
EndFunction


;======================
; FUNCTIONS USED BY COLLECTIONS
;======================

Message property IMP_RestrictedSanboxCreatureAssigningAborted01MESGn auto const mandatory
Message property IMP_RestrictedSanboxCreatureAssigningAborted02MESGn auto const mandatory

Function CreatureCommandModeGiveCommand_PUBLIC(ObjectReference akCreatureRef, ObjectReference akTarget)
	if akCreatureRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
		if akTarget.HasKeyword(IMP.WorkshopWorkObject)
			if akTarget as IMPScriptPositioner
				HandleCreatureCommandModeGiveCommand(akCreatureRef, akTarget)
			endif
		endif
	endif
EndFunction


Function HandleCreatureCommandModeGiveCommand(ObjectReference akCreatureRef, ObjectReference akTarget)
	if akCreatureRef && akTarget
		(akCreatureRef as Actor).SetCanDoCommand(False)

		ObjectReference MarkerRef=(akTarget as IMPScriptPositioner).GetMarkerRef()	
				
		if akTarget.HasKeyword(IMP.IMP_IsCreaturePositioner)
			;*** set ownership for this marker so it can be used during creatures' sandbox packages ***
			IMP.CommandMode.HandleSandboxMarkerOwnership_PUBLIC(akSettlerRef=akCreatureRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)

		elseif akTarget.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner)
			;*** assign creature to marker ***
			if CreatureCollection.Find(akCreatureRef) < 0
				SettlementNameAlias.ForceLocationTo(akCreatureRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
				IMP_RestrictedSandboxAssignCreatureOnlyMESGn.Show()

			elseif akCreatureRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)  ||  akCreatureRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)  ||  (akCreatureRef as WorkshopNPCScript).bIsGuard
				SettlerNameAlias.ForceRefTo(akCreatureRef)
				IMP_RestrictedSanboxCreatureAssigningAborted02MESGn.Show()

			else
				AssignSandboxerCreatureToMarker(akCreatureRef, MarkerRef)

			endif

		elseif akTarget.HasKeyword(IMP.IMP_IsGuardPatrolPositioner)
			;*** assign actor to guard patrol marker ***
			IMP.GuardPatrol.AssignGuardToPatrolmarker_PUBLIC(akCreatureRef, MarkerRef)

		elseif akTarget.HasKeyword(IMP.IMP_IsGuardScoutPositioner)
			;*** assign actor to guard scout  marker ***
			IMP.GuardScout.AssignGuardToScoutmarker_PUBLIC(akCreatureRef, MarkerRef)

		else		
			IMP_RestrictedSanboxCreatureAssigningAborted01MESGn.Show()

		endif
	endif
EndFunction

Function HandleCreatureCommandModeGiveCommand_PUBLIC(ObjectReference akCreatureRef, ObjectReference akTarget)
	HandleCreatureCommandModeGiveCommand(akCreatureRef, akTarget)
EndFunction


Function CreatureOnCommandModeEnter_PUBLIC()
	WorkshopWorkObjectBLOCKEDCollection.AddRefCollection(WorkshopWorkObjectCollection)
EndFunction


Function CreatureOnCommandModeExit_PUBLIC()
	WorkshopWorkObjectBLOCKEDCollection.RemoveAll()
EndFunction


Function CreatureOnUnload_PUBLIC(ObjectReference akCreatureRef)
	UnsetCreature(akCreatureRef)
EndFunction

;=========

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	GetSettlementCreatures(akWorkshopRef)
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction

;=========

Function WorkshopObjectOnUnload_PUBLIC(ObjectReference akObjectRef)
	WorkshopWorkObjectCollection.RemoveRef(akObjectRef)
	WorkshopWorkObjectBLOCKEDCollection.RemoveRef(akObjectRef)
EndFunction



;==================
; WORKSHOP NPC TRANSFER
;==================
; Do this because there is no default event to manage NPC transfers

ObjectReference RegisteredWorkshopRef

Function RegisterForWorkshopMode_PUBLIC(ObjectReference akWorkshopRef)
	RegisterForMenuOpenCloseEvent("Workshop_CaravanMenu")
	RegisteredWorkshopRef=akWorkshopRef
EndFunction

Function UnregisterForWorkshopMode_PUBLIC()
	UnregisterForMenuOpenCloseEvent("Workshop_CaravanMenu")
	RegisteredWorkshopRef=NONE
EndFunction

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	if asMenuName== "Workshop_CaravanMenu"
		if abOpening == False
			ObjectReference WorkshopRef=RegisteredWorkshopRef
			GetSettlementCreatures(WorkshopRef)
       	endif
	endif
endEvent