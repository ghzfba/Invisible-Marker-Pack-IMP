Scriptname IMPScriptAssemblyPointManager extends Quest Conditional

RefCollectionAlias property SettlerCollection auto const mandatory
RefCollectionAlias property WorkshopNoPackagesCollection auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory
Message property IMP_AssemblyPointSettlerAssignSuccededMESGn auto const mandatory
Message property IMP_AssemblyPointSettlerUnassignSuccededMESGn auto const mandatory
Message property IMP_BattlePositionReplaceOwnerMESGb auto const mandatory
Message property IMP_BattlePositionSettlerUnassignSuccededMESGn auto const mandatory
Message property IMP_BattlePositionSettlerAssignSuccededMESGn auto const mandatory
Message property IMP_AssemblyPointSettlerLinkRemoved01MESGn auto const mandatory
Message property IMP_AssemblyPointSettlerLinkRemoved02MESGn auto const mandatory
Message property IMP_AssemblyPointGuardNotAllowedMESGn auto const mandatory
Message property IMP_AssemblyPointReservistAssignedMESGn auto const mandatory
Message property IMP_AssemblyPointReservistUnassignedMESGn auto const mandatory

ObjectReference[] SettlerLinkedToSafehouseRefs

IMPScriptMain IMP


;= filled in v 3.11 =
Message property IMP_BattlePositionWantToUnassignMESGb auto

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	
	SettlerLinkedToSafehouseRefs=new ObjectReference[0]
	
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
EndEvent



;==================
; WORKSHOP PARENT EVENTS
;==================

;*** remove link to assembly point if settler has just been assigned to guard job ***
Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference
	Actor OwnerRef=WorkshopObjectRef.GetActorRefOwner()

	if OwnerRef as WorkshopNPCScript
		if (OwnerRef as WorkshopNPCScript).bIsGuard
			ObjectReference AssemblyPointRef=OwnerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarker)
			if AssemblyPointRef == NONE
				AssemblyPointRef=OwnerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			endif

			if AssemblyPointRef
				if AssemblyPointRef.HasKeyword(IMP.IMP_IsBattlePositionMarker) == False
					OwnerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
					
					OwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
					OwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)

					ActorNameAlias.ForceRefTo(OwnerRef)
					if AssemblyPointRef.HasKeyword(IMP.IMP_IsAssemblyPointMarker)
						IMP_AssemblyPointSettlerLinkRemoved01MESGn.Show()
					elseif AssemblyPointRef.HasKeyword(IMP.IMP_IsBattlePositionMarker)
						IMP_AssemblyPointSettlerLinkRemoved02MESGn.Show()
					endif
				endif
			endif
		endif
	endif
EndEvent



;======================
; FUNCTIONS USED BY COLLECTIONS
;======================

Function SettlerOnUnload_PUBLIC(ObjectReference akSettlerRef)
	UnsetAllPackagesAssemblyPoint_PUBLIC(akSettlerRef as Actor)
EndFunction


Function SettlerOnCombatStateChanged_PUBLIC(ObjectReference akSettlerRef, Int aeCombatState)
	if aeCombatState == 0
		UnsetAllPackagesAssemblyPoint_PUBLIC(akSettlerRef as Actor)
	endif
EndFunction

;---------

Function SettlerOnWorkshopNPCTransfer_PUBLIC(ObjectReference akSettlerRef)
	RemoveActorFromAssemblyPoint(akSettlerRef)
EndFunction

Function SettlerOnDeath_PUBLIC(ObjectReference akSettlerRef)
	RemoveActorFromAssemblyPoint(akSettlerRef)
EndFunction

Function RemoveActorFromAssemblyPoint(ObjectReference akActorRef)
	ObjectReference MarkerRef=akActorRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarker)
	if MarkerRef == NONE
		MarkerRef=akActorRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
	endif
	MarkerRef.SetActorRefOwner(NONE)
	(MarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(NONE)

	akActorRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
	SettlerCollection.RemoveRef(akActorRef)
	WorkshopNoPackagesCollection.RemoveRef(akActorRef)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
	(akActorRef as Actor).EvaluatePackage()
EndFunction



;==============================
; FUNCTIONS USED BY WorkshopJobAssign Script
;==============================

Bool bIsLinkedToAssemblyPoint Conditional
Bool bIsReservist Conditional
Bool bIsChild Conditional
Message property IMP_AssemblyPointSettlerMenu01aMESGb auto const mandatory
Message property IMP_AssemblyPointSettlerMenu01bMESGb auto const mandatory
Message property IMP_AssemblyPointSettlerMenu02MESGb auto const mandatory

Function AssignSettlerToAssemblyPointMarker_PUBLIC(ObjectReference akSettlerRef, ObjectReference akMarkerRef)
	if akSettlerRef && akMarkerRef

		if (akSettlerRef as WorkshopNPCScript).bIsGuard
			IMP_AssemblyPointGuardNotAllowedMESGn.Show()

		else
			ActorNameAlias.ForceRefTo(akSettlerRef)
			ObjectReference LinkedMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			ObjectReference SelectedMarkerRef=akMarkerRef

			bIsReservist =akSettlerRef.HasKeyword(IMP.IMP_IsReservist)

			if LinkedMarkerRef == SelectedMarkerRef
				bIsLinkedToAssemblyPoint=True
			else
				bIsLinkedToAssemblyPoint=False
			endif

			bIsChild=(akSettlerRef as Actor).IsChild()

			Int iButton
			if bIsReservist == False
				if LinkedMarkerRef == NONE
					iButton=IMP_AssemblyPointSettlerMenu01aMESGb.Show()
				else
					iButton=IMP_AssemblyPointSettlerMenu01bMESGb.Show()
				endif
			else
				iButton=IMP_AssemblyPointSettlerMenu02MESGb.Show()
			endif

			if iButton == 0
				;Do nothing

			elseif iButton == 1
				if LinkedMarkerRef == NONE
					akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarker)
					akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
					(akSettlerRef  as Actor).EvaluatePackage()

					IMP_AssemblyPointSettlerAssignSuccededMESGn.Show()
			
				elseif LinkedMarkerRef != SelectedMarkerRef
					;*** do this to reset IMP_LinkSettlerAssemblypointMarkerForced package target ***
					akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
					akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
					(akSettlerRef  as Actor).EvaluatePackage()

					Utility.Wait(0.5)

					akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarker)
					akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
					(akSettlerRef as Actor).EvaluatePackage()

					IMP_AssemblyPointSettlerAssignSuccededMESGn.Show()
				endif


			elseif iButton == 2
				akSettlerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
				(akSettlerRef  as Actor).EvaluatePackage()

				IMP_AssemblyPointSettlerUnassignSuccededMESGn.Show()						


			elseif iButton == 3
				akSettlerRef.AddKeyword(IMP.IMP_IsReservist)
				akSettlerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)

				IMP_AssemblyPointReservistAssignedMESGn.Show()


			elseif iButton == 4
				akSettlerRef.RemoveKeyword(IMP.IMP_IsReservist)

				IMP_AssemblyPointReservistUnassignedMESGn.Show()

			endif
		endif
		
	endif
EndFunction

;=========

Message property IMP_AssemblyPointEntryMenuMESGb auto const mandatory
Int SettlerLinkedToSafehouseCount_cond Conditional

Function ShowAssemblyPointMenu_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	
		if MarkerRef.CountRefsLinkedToMe(IMP.IMP_LinkSettlerAssemblypointMarker) > 0
			SettlerLinkedToSafehouseRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerAssemblypointMarker)
		else
			SettlerLinkedToSafehouseRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
		endif
		SettlerLinkedToSafehouseCount_cond=SettlerLinkedToSafehouseRefs.length
		
		Int iButton=IMP_AssemblyPointEntryMenuMESGb.Show(SettlerLinkedToSafehouseCount_cond)
		if iButton==1
			IMP.Pin.Pin_AddActorArrayToCollection_PUBLIC(SettlerLinkedToSafehouseRefs, akPositionerRef)
		endif
	endif
EndFunction



;====================
; FUNCTIONS USED BY PACKAGES
;====================

Function FindAssemblyPoint_PUBLIC(Actor akActorRef)
	SettlerCollection.AddRef(akActorRef)
	ObjectReference AssemblyPointRef=akActorRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
	if AssemblyPointRef == NONE
		AssemblyPointRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_AssemblyPoint, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())
	endif
	
	if \
	AssemblyPointRef == NONE || \
	AssemblyPointRef.IsDisabled() || \
	AssemblyPointRef.IsDeleted()	
		akActorRef.SetValue(IMP.IMP_AssemblyPointReached, -1)
		akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
	else
		akActorRef.SetLinkedRef(AssemblyPointRef, IMP.IMP_LinkSettlerAssemblypointMarker)
	endif


	akActorRef.EvaluatePackage()
EndFunction


Function SetHoldPositionAtAssemblyPoint_PUBLIC(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_AssemblyPointReached, 1)
	WorkshopNoPackagesCollection.AddRef(akActorRef)
	akActorRef.EvaluatePackage()
EndFunction


Function UnsetAllPackagesAssemblyPoint_PUBLIC(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
	SettlerCollection.RemoveRef(akActorRef)
	WorkshopNoPackagesCollection.RemoveRef(akActorRef)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
	akActorRef.EvaluatePackage()
EndFunction



;================================
; FUNCTIONS USED BY ASSEMBLY POINT POSITIONER
;================================

Function AssemblyPointMarkerOnPlaced_PUBLIC(ObjectReference akWorkshopRef)
	if akWorkshopRef
		;*** increase marker count ***
		Int AssemblyPointMarkerCount=akWorkshopRef.GetValue(IMP.IMP_WorkshopSafehouseCount) as Int
		akWorkshopRef.SetValue(IMP.IMP_WorkshopSafehouseCount, AssemblyPointMarkerCount+1)
																															
		Int ActorCount=SettlerCollection.GetCount()
		if ActorCount > 0
			Int i=0
			while i < ActorCount
				ObjectReference iActorRef=SettlerCollection.GetAt(i)
				if iActorRef.GetValue(IMP.IMP_AssemblyPointReached) == -1
					iActorRef.SetValue(IMP.IMP_AssemblyPointReached, 1)
				endif
				i+=1
			endwhile

			SettlerCollection.EvaluateAll()
		endif
	endif
EndFunction


Function AssemblyPointMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		;*** decrease marker count ***
		Int AssemblyPointMarkerCount=akWorkshopRef.GetValue(IMP.IMP_WorkshopSafehouseCount) as Int
		akWorkshopRef.SetValue(IMP.IMP_WorkshopSafehouseCount, Math.Max(0, AssemblyPointMarkerCount-1))
		
		;*** unlink settlers from this marker ***
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		ObjectReference[] SettlerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerAssemblypointMarker)
		ObjectReference[] SettlerForcedRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
		Int SettlerCount=Math.Max(SettlerRefs.length, SettlerForcedRefs.length) as Int

		if SettlerCount > 0
			Int i=0
			while i < SettlerCount
				ObjectReference iSettlerRef=SettlerRefs[i]
				if iSettlerRef
					iSettlerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
					iSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
					if iSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced) == MarkerRef
						iSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
					endif
				endif

				ObjectReference iSettlerForcedRef=SettlerForcedRefs[i]
				if iSettlerForcedRef
					iSettlerForcedRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
					iSettlerForcedRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
					iSettlerForcedRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
				endif

				i+=1
			endwhile
			
			SettlerCollection.EvaluateAll()

		endif
	endif
EndFunction



;==============================
;========= BATTLE POSITION =========
;==============================

;==============================
; FUNCTIONS USED BY WorkshopJobAssign Script
;==============================

Function AssignSettlerToBattlePositionMarker_PUBLIC(ObjectReference akSettlerRef, ObjectReference akMarkerRef)
	if akSettlerRef && akMarkerRef
	
		ActorNameAlias.ForceRefTo(akSettlerRef)
		ObjectReference LinkedMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
		ObjectReference SelectedMarkerRef=akMarkerRef
		Actor CurrentOwner=akMarkerRef.GetActorRefOwner()

		if CurrentOwner != NONE  &&  CurrentOwner != akSettlerRef
			Int iButton=IMP_BattlePositionReplaceOwnerMESGb.Show()
			if iButton == 1
				CurrentOwner.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
				CurrentOwner.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
				CurrentOwner.EvaluatePackage()

				akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarker)
				akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
				(akSettlerRef  as Actor).EvaluatePackage()
			
				akMarkerRef.SetActorRefOwner(akSettlerRef as Actor)
				(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(akSettlerRef as Actor)

				IMP_BattlePositionSettlerAssignSuccededMESGn.Show()				
			endif

		elseif LinkedMarkerRef == NONE
			akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarker)
			akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			(akSettlerRef  as Actor).EvaluatePackage()

			akMarkerRef.SetActorRefOwner(akSettlerRef as Actor)
			(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(akSettlerRef as Actor)

			IMP_BattlePositionSettlerAssignSuccededMESGn.Show()
		

		elseif LinkedMarkerRef != SelectedMarkerRef
			;*** do this to reset IMP_LinkSettlerAssemblypointMarkerForced package target ***
			akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
			akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			(akSettlerRef  as Actor).EvaluatePackage()

			Utility.Wait(0.5)

			akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarker)
			akSettlerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			(akSettlerRef as Actor).EvaluatePackage()

			akMarkerRef.SetActorRefOwner(akSettlerRef as Actor)
			(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(akSettlerRef as Actor)

			IMP_BattlePositionSettlerAssignSuccededMESGn.Show()


		elseif LinkedMarkerRef == SelectedMarkerRef
			Int iButton=IMP_BattlePositionWantToUnassignMESGb.Show()
			if iButton == 1
				UnsetBattlePositionMarker(SelectedMarkerRef)					
			endif			
		endif

	endif
EndFunction

Function UnsetBattlePositionMarker(ObjectReference akMarkerRef)
	if akMarkerRef
		;*** unlink settlers from this marker ***
		ObjectReference SettlerRef=akMarkerRef.GetActorRefOwner()
		SettlerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
		SettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
		SettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)
		(SettlerRef as Actor).EvaluatePackage()

		akMarkerRef.SetActorRefOwner(NONE)
		(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(NONE)

		IMP_BattlePositionSettlerUnassignSuccededMESGn.Show()						
	endif
EndFunction



;================================
; FUNCTIONS USED BY BATTLE POSITION POSITIONER
;================================

Message property IMP_BattlePositionUnassignOwner00MESGb auto const mandatory
Message property IMP_BattlePositionUnassignOwner01MESGb auto const mandatory

Function BattlePositionMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	UnsetBattlePositionMarker(MarkerRef)
EndFunction


Function ShowBattlePositionMenu_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()

		Actor OwnerRef=MarkerRef.GetActorRefOwner()
		Message BattlePositionUnassignOwner
		if OwnerRef
			ActorNameAlias.ForceRefTo(OwnerRef)
			BattlePositionUnassignOwner=IMP_BattlePositionUnassignOwner01MESGb
		else
			BattlePositionUnassignOwner=IMP_BattlePositionUnassignOwner00MESGb
		endif

		Int iButton=BattlePositionUnassignOwner.Show()
		if iButton==1
			IMP.Pin.Pin_AddActorToCollection_PUBLIC(OwnerRef, akPositionerRef)
		elseif iButton==2
			UnsetBattlePositionMarker(MarkerRef)
		endif
	endif
EndFunction