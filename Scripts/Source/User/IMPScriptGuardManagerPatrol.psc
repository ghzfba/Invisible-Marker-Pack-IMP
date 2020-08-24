Scriptname IMPScriptGuardManagerPatrol extends Quest Conditional

RefCollectionAlias property PatrolmanCollection auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory
ReferenceAlias property ActorNameAltAlias auto const mandatory
ReferenceAlias property PatrolRouteAlias auto const mandatory
LocationAlias property CurrentGuardShift01 auto const mandatory
LocationAlias property CurrentGuardShift02 auto const mandatory
Message property IMP_GuardManagerPatrolMenu01MESGb auto const mandatory
Message property IMP_GuardManagerPatrolMenu02AMESGb auto const mandatory
Message property IMP_GuardManagerPatrolMenu02BMESGb auto const mandatory
Message property IMP_GuardManagerPatrolType01MESGb auto const mandatory
Message property IMP_GuardManagerPatrolType02MESGb auto const mandatory
Message property IMP_GuardManagerPatrolMenu00AMESGb auto const mandatory
Message property IMP_GuardManagerPatrolMenu00BMESGb auto const mandatory
Message property IMP_GuardManagerPatrolMenuNotAtHomeMESGb auto const mandatory
Message property IMP_GuardManagerPatrolMarkerDeletedMESGn auto const mandatory
Message property IMP_GuardManagerPatrolRequirementMESGn auto const mandatory
Message property IMP_GuardManagerPatrolDeletedMESGn auto const mandatory
Message property IMP_GuardManagerPatrolUnassignedMESGn auto const mandatory
Message property IMP_GuardManagerPatrolSquadUnassignedMESGn auto const mandatory
Message property IMP_GuardManagerPatrolMarkerTutorialMESGn auto const mandatory
Message property IMP_GuardManagerLeaderUnvalidMESGn auto const mandatory

;= CONSTANTS =
Int MinMarkerRequired=2


;= VARIABLES =
IMPScriptMain IMP

Int ValidActionCount
ObjectReference[] MarkerRefs
ObjectReference[] IdlemarkerRefs
ObjectReference[] FollowerRefs
ObjectReference FirstIdlemarkerRef

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	MarkerRefs=new ObjectReference[0]
	IdlemarkerRefs=new ObjectReference[0]
	FollowerRefs=new ObjectReference[0]

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
EndEvent



;===================
; PATROL SETTING FUNCTIONS
;===================

Function GuardOnCommandModeEnter_PUBLIC(ObjectReference akGuardRef)
	if akGuardRef
		FirstIdlemarkerRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolidlemarker)
	endif
EndFunction


Function AssignGuardToPatrolmarker_PUBLIC(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef

		Actor MarkerOwner=akTargetMarkerRef.GetActorRefOwner()
		IdlemarkerRefs=GetIdlemarkerRefChain()
		Int IdlemarkerCount=IdlemarkerRefs.length

		if MarkerOwner == NONE
			if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
				if FirstIdlemarkerRef == NONE
					PatrolmanCollection.AddRef(akGuardRef)
					FirstIdlemarkerRef=GetIdleMarkerRef(akTargetMarkerRef)
					AddMarkerToArray(akTargetMarkerRef)
					SetMarkersOwnership(akTargetMarkerRef, akGuardRef as Actor)

					ValidActionCount+=1

				else
					ObjectReference TargetIdlemarkerRef=GetIdleMarkerRef(akTargetMarkerRef)
					if IdlemarkerRefs.Find(TargetIdlemarkerRef) < 0
						PatrolmanCollection.AddRef(akGuardRef)
						ObjectReference PreviousIdlemarkerRef=IdlemarkerRefs[IdlemarkerCount-1]
						AddMarkerToArray(akTargetMarkerRef)
						PreviousIdlemarkerRef.SetLinkedRef(TargetIdlemarkerRef)
						SetMarkersOwnership(akTargetMarkerRef, akGuardRef as Actor)

						ValidActionCount+=1
					endif
				endif
				
				if ValidActionCount > 0
					akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
					(akGuardRef as Actor).EvaluatePackage()
				endif

				ActorNameAlias.ForceRefTo(akGuardRef)
				IMP_GuardManagerPatrolMarkerTutorialMESGn.Show()
				
			elseif akGuardRef.HasKeyword(IMP.ActorTypeNPC) &&  (akGuardRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				if FirstIdlemarkerRef == NONE
					PatrolmanCollection.AddRef(akGuardRef)
					FirstIdlemarkerRef=GetIdleMarkerRef(akTargetMarkerRef)
					AddMarkerToArray(akTargetMarkerRef)
					SetMarkersOwnership(akTargetMarkerRef, akGuardRef as Actor)

					ValidActionCount+=1

				else
					ObjectReference TargetIdlemarkerRef=GetIdleMarkerRef(akTargetMarkerRef)
					if IdlemarkerRefs.Find(TargetIdlemarkerRef) < 0
						PatrolmanCollection.AddRef(akGuardRef)
						ObjectReference PreviousIdlemarkerRef=IdlemarkerRefs[IdlemarkerCount-1]
						AddMarkerToArray(akTargetMarkerRef)
						PreviousIdlemarkerRef.SetLinkedRef(TargetIdlemarkerRef)
						SetMarkersOwnership(akTargetMarkerRef, akGuardRef as Actor)

						ValidActionCount+=1
					endif
				endif
				
				if ValidActionCount > 0
					akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
					(akGuardRef as Actor).EvaluatePackage()
				endif

				ActorNameAlias.ForceRefTo(akGuardRef)
				IMP_GuardManagerPatrolMarkerTutorialMESGn.Show()
				
			else
				ActorNameAlias.ForceRefTo(akGuardRef)
				IMP_GuardManagerLeaderUnvalidMESGn.Show()
				
			endif
			
		else
			if MarkerOwner == akGuardRef
				ShowMenu_SquadManager(akTargetMarkerRef)
			else
				ShowMenu_UnitManager(akGuardRef, akTargetMarkerRef)
			endif

		endif
		
	endif
EndFunction


Function CompleteAssignmentGuardToPatrolmarker(ObjectReference akGuardRef)
	if akGuardRef


		if ValidActionCount > 0
			Int IdlemarkerCount=IdlemarkerRefs.length

			if IdlemarkerCount > 1
				ObjectReference PatrolControllerRef=GetGuardPatrolControllerRef(akGuardRef)

				WorkshopScript WorkshopRef=akGuardRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
				
				if PatrolControllerRef == NONE
					;*** place controller if not existing ***
					PatrolControllerRef=WorkshopRef.PlaceAtMe(IMP.IMP_Controller_GuardPatrol, abDeleteWhenAble=False)
					if PatrolControllerRef as WorkshopObjectScript
						IMP.WorkshopParent.BuildObjectPUBLIC(PatrolControllerRef, WorkshopRef)
						PatrolControllerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
					
						akGuardRef.SetLinkedRef(PatrolControllerRef, IMP.IMP_LinkGuardPatrolController)
						PatrolControllerRef.SetValue(IMP.IMP_GuardPatrol_MarkerCount, IdlemarkerCount)
					
						IMP.WorkshopParent.AssignActorToObjectPUBLIC(akGuardRef as WorkshopNPCScript, PatrolControllerRef as WorkshopObjectScript)
					endif
				else
					;*** update marker count ***
					PatrolControllerRef.SetValue(IMP.IMP_GuardPatrol_MarkerCount, IdlemarkerCount)
				endif


				;*** choose patrolling style ***
				Int iButton=IMP_GuardManagerPatrolType01MESGb.Show()
				if iButton == 0
					IdlemarkerRefs[IdlemarkerCount-1].SetLinkedRef(NONE)

				elseif iButton == 1
					IdlemarkerRefs[IdlemarkerCount-1].SetLinkedRef(FirstIdlemarkerRef)

				endif

				iButton=IMP_GuardManagerPatrolType02MESGb.Show()
				if iButton == 0
					akGuardRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 0)

				elseif iButton == 1
					akGuardRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 1)

				endif


				;*** restore link to the first idle marker of the ref chain ***
				akGuardRef.SetLinkedRef(FirstIdlemarkerRef, IMP.IMP_LinkGuardPatrolidlemarker)
				
				
				;*** set positioners' safety value ***
				Int NewSafetyValue
				ObjectReference[] OwnerFollowerRefs=akGuardRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
				Int FollowerCount=OwnerFollowerRefs.length
				Int i=0
				while i < FollowerCount
					ObjectReference iFollowerRef=OwnerFollowerRefs[i]
					if iFollowerRef.HasKeyword(IMP.IMP_IsSettler)
						NewSafetyValue+=6
					elseif iFollowerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
						Race FollowerRace=(iFollowerRef as Actor).GetActorBase().GetRace()
						Int Index=IMP.GuardManager.IMP_GuardSupportCreatureRaces.Find(FollowerRace)
						if Index >= 0
							NewSafetyValue+=IMP.GuardManager.GuardSupportCreatureSafetyRatings[Index]
						endif			
					endif
					i+=1
				endwhile
				
				if NewSafetyValue > 0
					;*** update safety value on positioner ***
					ObjectReference[] OwnedWorkshopObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(akGuardRef as Actor)
					i=0
					while i < OwnedWorkshopObjectRefs.length
						ObjectReference iObjectRef=OwnedWorkshopObjectRefs[i]
						if iObjectRef as IMPScriptMarkerGuardPatrolMrk
							(iObjectRef as IMPScriptMarker).GetPositionerRef().SetValue(IMP.Safety, NewSafetyValue)
						endif
						i+=1
					endwhile								
				endif			
				
			else
				UnsetPatrolGuard(akGuardRef)
				IMP_GuardManagerPatrolRequirementMESGn.Show()
			endif

		endif

		(akGuardRef as Actor).EvaluatePackage()


		ValidActionCount=0
		MarkerRefs.Clear()
		IdlemarkerRefs.Clear()
		FirstIdlemarkerRef=NONE


	endif
EndFunction


Function GuardOnCommandModeExit_PUBLIC(ObjectReference akGuardRef)
	if akGuardRef
		CompleteAssignmentGuardToPatrolmarker(akGuardRef)
	endif
EndFunction


;=========


Function ShowGuardPatrolMarkerMenu_PUBLIC(ObjectReference akTargetPositionerRef)
	if akTargetPositionerRef
		Actor GuardRef=akTargetPositionerRef.GetActorRefOwner()

		if GuardRef
			FirstIdlemarkerRef=GuardRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolidlemarker)
			IdlemarkerRefs=GetIdlemarkerRefChain()
			Int IdlemarkerCount=IdlemarkerRefs.length
			ObjectReference MarkerRef=(akTargetPositionerRef as IMPScriptPositioner).GetMarkerRef()
			ObjectReference IdleMarkerRef=GetIdleMarkerRef(MarkerRef)

			ActorNameAlias.ForceRefTo(GuardRef)
			Int iButton=IMP_GuardManagerPatrolMenu00BMESGb.Show(IdlemarkerRefs.Find(IdleMarkerRef)+1, IdlemarkerCount)
			if iButton == 1
				ObjectReference[] FollowerRefsToCollection=GuardRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
				if FollowerRefsToCollection.length > 0
					FollowerRefsToCollection.Add(GuardRef)
					IMP.PIN.Pin_AddActorArrayToCollection_PUBLIC(FollowerRefsToCollection, PatrolRouteAlias.GetReference())
				else
					IMP.PIN.Pin_AddActorToCollection_PUBLIC(GuardRef, PatrolRouteAlias.GetReference())
				endif

			elseif iButton == 2
				ShowMenu_SquadManager(MarkerRef)
				
			elseif iButton == 3
				RemovePatrolMarkerFromChain(MarkerRef, GuardRef)

			endif

		else
			IMP_GuardManagerPatrolMenu00AMESGb.Show()
		endif

	endif
EndFunction


Function ShowMenu_PatrolSettings(ObjectReference akTargetMarkerRef)
	if akTargetMarkerRef
		Actor GuardRef=akTargetMarkerRef.GetActorRefOwner()
		FirstIdlemarkerRef=GuardRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolidlemarker)
		IdlemarkerRefs=GetIdlemarkerRefChain()
		Int IdlemarkerCount=IdlemarkerRefs.length

		if GuardRef  &&  IdlemarkerCount >=MinMarkerRequired
			ValidActionCount+=1
			CompleteAssignmentGuardToPatrolmarker(GuardRef)
		endif
	endif
EndFunction


;=========


Function ReplaceGuard(ObjectReference akGuardRef, ObjectReference akMarkerRef)
	if akGuardRef && akMarkerRef
		(akGuardRef as Actor).SetCanDoCommand(False)
		
		;*** previous owner stuff ***
		Actor PreviousOwnerRef=akMarkerRef.GetActorRefOwner()
		FirstIdlemarkerRef=PreviousOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolidlemarker)
		ObjectReference PatrolControllerRef=PreviousOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolController)
		FollowerRefs=PreviousOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
		Int FollowerCount=FollowerRefs.length
		FollowerRefs.Remove(FollowerRefs.Find(akGuardRef))

		;*** follower stuff ***
		ObjectReference FollowerMarkerRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerPatrol)


		if FollowerMarkerRef
			;*** do this if the new leader is already a squad unit ***

			;*** set new leader ***
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerPatrol)
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			akGuardRef.SetLinkedRef(PatrolControllerRef, IMP.IMP_LinkGuardPatrolController)
			akGuardRef.SetLinkedRef(FirstIdlemarkerRef, IMP.IMP_LinkGuardPatrolidlemarker)
			akGuardRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, PreviousOwnerRef.GetValue(IMP.IMP_GuardPatrolTypeStopAtMarker))
			PatrolmanCollection.AddRef(akGuardRef)
			(PatrolControllerRef as WorkshopObjectScript).AssignActor(akGuardRef as WorkshopNPCScript)
			(akGuardRef as Actor).EvaluatePackage()


			;*** remove old leader ***
			PatrolmanCollection.RemoveRef(PreviousOwnerRef)
			PreviousOwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolController)
			PreviousOwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
			PreviousOwnerRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 0)

			PreviousOwnerRef.SetLinkedRef(akGuardRef, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			PreviousOwnerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerPatrol)
			FollowerMarkerRef.SetActorRefOwner(PreviousOwnerRef as Actor)
			(PreviousOwnerRef as Actor).EvaluatePackage()
		
			;*** change markers' ownership ***
			WorkshopScript WorkshopRef=akMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
			ObjectReference[] OwnedObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(PreviousOwnerRef)
			Int OwnedObjectCount=OwnedObjectRefs.length
			Int i=0
			while i < OwnedObjectCount
				ObjectReference iOwnedObjectRef=OwnedObjectRefs[i]			
				if iOwnedObjectRef as IMPScriptMarkerGuardPatrolMrk		
					SetMarkersOwnership(iOwnedObjectRef, akGuardRef as Actor)
				endif
				i+=1
			endwhile
			WorkshopRef.RecalculateWorkshopResources()	

		else
			;*** do this if the new leader is not a squad unit ***
			
			;*** remove new leader from former job ***
			IMP.WorkshopParent.UnassignActor(akGuardRef as WorkshopNPCScript)
			(akGuardRef as WorkshopNPCScript).bIsWorker=True
			(akGuardRef as WorkshopNPCScript).bIsGuard=True		
		
		
			;*** set new leader ***
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerPatrol)
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			akGuardRef.SetLinkedRef(PatrolControllerRef, IMP.IMP_LinkGuardPatrolController)
			akGuardRef.SetLinkedRef(FirstIdlemarkerRef, IMP.IMP_LinkGuardPatrolidlemarker)
			akGuardRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, PreviousOwnerRef.GetValue(IMP.IMP_GuardPatrolTypeStopAtMarker))
			PatrolmanCollection.AddRef(akGuardRef)
			PatrolControllerRef.SetActorRefOwner(akGuardRef as Actor)
			(akGuardRef as Actor).EvaluatePackage()


			;*** remove old leader ***
			PatrolmanCollection.RemoveRef(PreviousOwnerRef)
			PreviousOwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolController)
			PreviousOwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
			PreviousOwnerRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 0)
						
			WorkshopScript WorkshopRef=akMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
			FollowerMarkerRef=PreviousOwnerRef.PlaceAtMe(IMP.IMP_Controller_GuardPatrolFollower, abDeleteWhenAble=False)
			IMP.WorkshopParent.BuildObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
			FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
			

			PreviousOwnerRef.SetLinkedRef(akGuardRef, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			PreviousOwnerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerPatrol)
			FollowerMarkerRef.SetActorRefOwner(PreviousOwnerRef as Actor)
			(PreviousOwnerRef as Actor).EvaluatePackage()		


			;*** change markers' ownership ***
			ObjectReference[] OwnedObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(PreviousOwnerRef)
			Int OwnedObjectCount=OwnedObjectRefs.length
			Int i=0
			while i < OwnedObjectCount
				ObjectReference iOwnedObjectRef=OwnedObjectRefs[i]			
				if iOwnedObjectRef as IMPScriptMarkerGuardPatrolMrk		
					SetMarkersOwnership(iOwnedObjectRef, akGuardRef as Actor)
					ObjectReference iPositionerRef=(iOwnedObjectRef as IMPScriptMarker).GetPositionerRef()
					UpdateSafetyValue(iPositionerRef)
				endif
				i+=1
			endwhile
			WorkshopRef.RecalculateWorkshopResources()			
		
		endif


		;*** reset followers ***
		Int i=0
		while i < FollowerCount
			ObjectReference iFollowerRef=FollowerRefs[i]
			iFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			(iFollowerRef as Actor).EvaluatePackage()

			Utility.Wait(0.3)
			
			iFollowerRef.SetLinkedRef(akGuardRef, IMP.IMP_LinkGuardFollowerLeaderPatrol)
			(iFollowerRef as Actor).EvaluatePackage()		
			i+=1
		endwhile

	endif
EndFunction



;===============
; UNSETTING FUNCTIONS
;===============

Function RemovePatrolMarkerFromChain(ObjectReference akMarkerRef, Actor akGuardRef)
	if akMarkerRef && akGuardRef
		FirstIdlemarkerRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolidlemarker)


		;*** put guard to wait state ***
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
		akGuardRef.EvaluatePackage()

		
		;*** get current, previous, and next idle marker refs ***
		ObjectReference IdlemarkerRef=GetIdleMarkerRef(akMarkerRef)
		ObjectReference[] PreviousIdlemarkerRefs=IdlemarkerRef.GetRefsLinkedToMe()
		ObjectReference PreviousIdlemarkerRef=PreviousIdlemarkerRefs[0]
		ObjectReference NextIdlemarkerRef=IdlemarkerRef.GetLinkedRef()


		;*** replace FirstIdlemarkerRef if akMarkerRef is the first of the ref chain ***
		if FirstIdlemarkerRef == IdlemarkerRef
			FirstIdlemarkerRef=NextIdlemarkerRef
		endif


		;*** null current marker ref ***
		IdlemarkerRef.SetLinkedRef(NONE)
		RemoveMarkerToArray(akMarkerRef)
		SetMarkersOwnership(akMarkerRef, NONE)
		
		ObjectReference PositionerRef=(akMarkerRef as IMPScriptMarker).GetPositionerRef()

		PositionerRef.SetValue(IMP.Safety, 0)

		;*** link previous to next ref ***
		PreviousIdlemarkerRef.SetLinkedRef(NextIdlemarkerRef)


		;*** update marker count ***
		ObjectReference PatrolControllerRef=GetGuardPatrolControllerRef(akGuardRef)
		Float NewMarkerCount=Math.Max(0, PatrolControllerRef.GetValue(IMP.IMP_GuardPatrol_MarkerCount)-1)
		PatrolControllerRef.SetValue(IMP.IMP_GuardPatrol_MarkerCount, NewMarkerCount)
		(PatrolControllerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript).RecalculateWorkshopResources()

		if NewMarkerCount >= MinMarkerRequired
			IMP_GuardManagerPatrolMarkerDeletedMESGn.Show()

			Utility.Wait(1)
			akGuardRef.SetLinkedRef(FirstIdlemarkerRef, IMP.IMP_LinkGuardPatrolidlemarker)
			akGuardRef.EvaluatePackage()

		else
			;*** it means there are no requirements for a patrol route: unset guard ***
			UnsetPatrolGuard(akGuardRef)
			IMP_GuardManagerPatrolRequirementMESGn.Show()

		endif

		
		FirstIdlemarkerRef=NONE			
	endif
EndFunction


;=========


Function UnsetPatrolGuard(ObjectReference akGuardRef)
	if akGuardRef
		WorkshopScript WorkshopRef=akGuardRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference PatrolControllerRef=GetGuardPatrolControllerRef(akGuardRef)


		;*** remove followers ***
		Int FollowerCount=akGuardRef.CountRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
		DismissFollowers(akGuardRef)


		;*** handle patrol markers ***
		Bool bDeletePatrolRoute=True
		ObjectReference[] OwnedObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(akGuardRef as Actor)
		Int OwnedObjectCount=OwnedObjectRefs.length
			
		if OwnedObjectCount > 0
			Int i=0
			while i < OwnedObjectCount
				ObjectReference iOwnedObjectRef=OwnedObjectRefs[i]			
				if iOwnedObjectRef as IMPScriptMarkerGuardPatrolMrk
					
					;*** marker and idle marker are no longer owned by akGuardRef ***
					SetMarkersOwnership(iOwnedObjectRef, NONE)
					(iOwnedObjectRef as IMPScriptMarker).GetPositionerRef().SetValue(IMP.Safety, 0)

					;*** all the idle markers are unlinked => patrol route deleted ***
					GetIdleMarkerRef(iOwnedObjectRef).SetLinkedRef(NONE)
						
				endif
				i+=1
			endwhile
		
			ActorNameAlias.ForceRefTo(akGuardRef)
			if FollowerCount == 0
				IMP_GuardManagerPatrolUnassignedMESGn.Show()
			else
				IMP_GuardManagerPatrolSquadUnassignedMESGn.Show()
			endif
		endif
			

		;*** handle patrol controller marker deletion ***
		IMP.WorkshopParent.RemoveObjectPUBLIC(PatrolControllerRef, WorkshopRef)
		PatrolControllerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
		PatrolControllerRef.SetValue(IMP.IMP_GuardPatrol_MarkerCount, 0)
		PatrolControllerRef.DisableNoWait()
		PatrolControllerRef.Delete()


		;*** handle guard stuff ***
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerPatrol)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolController)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
		akGuardRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 0)
		PatrolmanCollection.RemoveRef(akGuardRef)
		(akGuardRef as Actor).EvaluatePackage()

	endif
EndFunction

Function UnsetPatrolGuard_PUBLIC(ObjectReference akGuardRef)
	UnsetPatrolGuard(akGuardRef)
EndFunction



;=============
;      FOLLOWERS
;=============

Function AddFollower(ObjectReference akFollowerRef, ObjectReference akLeaderRef)
	if akFollowerRef  &&  akLeaderRef
		(akFollowerRef as Actor).SetCanDoCommand(False)
				
		;*** make sure to reset if it's a scout guard ***
		if akFollowerRef.GetLinkedRef(IMP.IMP_LinkScoutMarker)
			IMP.GuardScout.RemoveScout(akFollowerRef)
		elseif akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerScout)
			if akFollowerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
				IMP.GuardScout.RemoveFollower(akFollowerRef)
			else
				IMP.GuardScout.RemoveFollowerCreature(akFollowerRef)
			endif
		endif		

		WorkshopScript WorkshopRef=akLeaderRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference FollowerMarkerRef=akFollowerRef.PlaceAtMe(IMP.IMP_Controller_GuardPatrolFollower, abDeleteWhenAble=False)
		IMP.WorkshopParent.BuildObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
		IMP.WorkshopParent.AssignActorToObjectPUBLIC(akFollowerRef as WorkshopNPCScript, FollowerMarkerRef as WorkshopObjectScript)
		FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
		WorkshopRef.RecalculateWorkshopResources()

		akFollowerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerPatrol)
		akFollowerRef.SetLinkedRef(akLeaderRef, IMP.IMP_LinkGuardFollowerLeaderPatrol)
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeMode, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeMode))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
		(akFollowerRef as Actor).EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference[] OwnedWorkshopObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(akLeaderRef as Actor)
		Int i=0
		while i < OwnedWorkshopObjectRefs.length
			ObjectReference iObjectRef=OwnedWorkshopObjectRefs[i]
			if iObjectRef as IMPScriptMarkerGuardPatrolMrk
				ObjectReference iPositionerRef=(iObjectRef as IMPScriptMarker).GetPositionerRef()
				UpdateSafetyValue(iPositionerRef)
			endif
			i+=1
		endwhile
	endif
EndFunction

Function RemoveFollower(ObjectReference akFollowerRef)
	if akFollowerRef
		(akFollowerRef as Actor).SetCanDoCommand(False)
		
		ObjectReference LeaderRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
		
		ObjectReference FollowerMarkerRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerPatrol)
		WorkshopScript WorkshopRef=FollowerMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		IMP.WorkshopParent.RemoveObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
		FollowerMarkerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)

		FollowerMarkerRef.DisableNoWait()
		FollowerMarkerRef.Delete()

		WorkshopRef.RecalculateWorkshopResources()

		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerPatrol)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolController)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPatrolidlemarker)
		akFollowerRef.SetValue(IMP.IMP_GuardPatrolTypeStopAtMarker, 0)
		(akFollowerRef as Actor).EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference[] OwnedWorkshopObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(LeaderRef as Actor)
		Int i=0
		while i < OwnedWorkshopObjectRefs.length
			ObjectReference iObjectRef=OwnedWorkshopObjectRefs[i]
			if iObjectRef as IMPScriptMarkerGuardPatrolMrk
				ObjectReference iPositionerRef=(iObjectRef as IMPScriptMarker).GetPositionerRef()
				UpdateSafetyValue(iPositionerRef)
			endif
			i+=1
		endwhile
	endif
EndFunction

;---------

Function AddFollowerCreature(ObjectReference akFollowerRef, ObjectReference akLeaderRef)
	if akFollowerRef  &&  akLeaderRef
		(akFollowerRef as Actor).SetCanDoCommand(False)
		
		;*** make sure to reset if it's a patrol guard ***
		if akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerScout)
			IMP.GuardScout.RemoveFollowerCreature(akFollowerRef)
		endif

		WorkshopScript WorkshopRef=akLeaderRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference FollowerMarkerRef=akFollowerRef.PlaceAtMe(IMP.IMP_Controller_GuardPatrolFollowerCreature, abDeleteWhenAble=False)
		FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
		FollowerMarkerRef.SetActorRefOwner(akFollowerRef as Actor)

		akFollowerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerPatrol)
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeMode, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeMode))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
		akFollowerRef.SetLinkedRef(akLeaderRef, IMP.IMP_LinkGuardFollowerLeaderPatrol)
		(akFollowerRef as Actor).EvaluatePackage()
		
		Int FollowerSafetyValue=akFollowerRef.GetValue(IMP.Safety) as Int
		if FollowerSafetyValue == 0
			akFollowerRef.SetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue, FollowerSafetyValue)
			
			Race FollowerRace=(akFollowerRef as Actor).GetActorBase().GetRace()
			Int Index=IMP.GuardManager.IMP_GuardSupportCreatureRaces.Find(FollowerRace)
			if Index >= 0
				FollowerSafetyValue=IMP.GuardManager.GuardSupportCreatureSafetyRatings[Index]
				akFollowerRef.SetValue(IMP.Safety, FollowerSafetyValue)
				
				;*** update safety value on positioner ***
				ObjectReference[] OwnedWorkshopObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(akLeaderRef as Actor)
				Int i=0
				while i < OwnedWorkshopObjectRefs.length
					ObjectReference iObjectRef=OwnedWorkshopObjectRefs[i]
					if iObjectRef as IMPScriptMarkerGuardPatrolMrk
						ObjectReference iPositionerRef=(iObjectRef as IMPScriptMarker).GetPositionerRef()
						UpdateSafetyValue(iPositionerRef)
					endif
					i+=1
				endwhile				
				
				WorkshopRef.RecalculateWorkshopResources()
			endif
		endif
	endif
EndFunction


Function RemoveFollowerCreature(ObjectReference akFollowerRef)
	if akFollowerRef
		(akFollowerRef as Actor).SetCanDoCommand(False)

		ObjectReference LeaderRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
		ObjectReference FollowerMarkerRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerPatrol)
		WorkshopScript WorkshopRef=FollowerMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript

		FollowerMarkerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
		FollowerMarkerRef.SetActorRefOwner(NONE)
		FollowerMarkerRef.DisableNoWait()
		FollowerMarkerRef.Delete()

		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerPatrol)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderPatrol)		
		
		Int GuardCreatureFollowerStartingSafetyValue=akFollowerRef.GetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue) as Int
		if GuardCreatureFollowerStartingSafetyValue > 0
			akFollowerRef.SetValue(IMP.Safety, GuardCreatureFollowerStartingSafetyValue)
			akFollowerRef.SetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue, 0)
		else
			akFollowerRef.SetValue(IMP.Safety, 0)
		endif
		
		;*** update safety value on positioner ***
		ObjectReference[] OwnedWorkshopObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(LeaderRef as Actor)
		Int i=0
		while i < OwnedWorkshopObjectRefs.length
			ObjectReference iObjectRef=OwnedWorkshopObjectRefs[i]
			if iObjectRef as IMPScriptMarkerGuardPatrolMrk
				ObjectReference iPositionerRef=(iObjectRef as IMPScriptMarker).GetPositionerRef()
				UpdateSafetyValue(iPositionerRef)
			endif
			i+=1
		endwhile			
		
		WorkshopRef.RecalculateWorkshopResources()
		
		(akFollowerRef as Actor).EvaluatePackage()
	endif
EndFunction

;---------

Function DismissFollowers(ObjectReference akLeaderRef)
	if akLeaderRef
		FollowerRefs=akLeaderRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
		Int i=0
		while i < FollowerRefs.length
			ObjectReference iFollowerRef=FollowerRefs[i]
			if iFollowerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
				RemoveFollower(iFollowerRef)
			else
				RemoveFollowerCreature(iFollowerRef)
			endif
			i+=1
		endwhile
	endif
EndFunction

;---------

Formlist property IMP_GuardPatrolActivityList auto const mandatory
Formlist property IMP_GuardSquadRankList auto const mandatory
Bool PatrolManager_bIsSquadAtHome_cond Conditional
Bool PatrolManager_bCanBeLeader_cond Conditional
Int PatrolManager_FollowerCount_cond Conditional
Int PatrolManager_IsFollower_cond Conditional
Int PatrolUnitIndex

Function ShowMenu_SquadManager(ObjectReference akTargetMarkerRef)
	if akTargetMarkerRef
		Actor MarkerOwnerRef=akTargetMarkerRef.GetActorRefOwner()
		(MarkerOwnerRef as Actor).SetCanDoCommand(False)

		FollowerRefs=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)

		if MarkerOwnerRef
			;*** displayed data ***
			ActorNameAlias.ForceRefTo(MarkerOwnerRef)


			PatrolManager_FollowerCount_cond=FollowerRefs.length
			PatrolManager_bIsSquadAtHome_cond = (akTargetMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation()==MarkerOwnerRef.GetCurrentLocation())


			;*** is guard on break? ***
			Bool bGuardIsOnBreak
			Int GuardRelaxCount=MarkerOwnerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
			ObjectReference GuardMarkerRef=MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
			if GuardRelaxCount > 0  &&  GuardMarkerRef
				Float Gamehour=IMP.Gamehour.GetValue()
			
				Float ShiftTimeStarting=MarkerOwnerRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
				Float ShiftTimeEnd=MarkerOwnerRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
				Int ShiftTimeMode
				if ShiftTimeEnd > ShiftTimeStarting
					ShiftTimeMode=1
				else
					ShiftTimeMode=2
				endif
				
				if GuardMarkerRef  &&  ShiftTimeMode== 1 && (Gamehour >= ShiftTimeStarting  &&  Gamehour < ShiftTimeEnd)
					bGuardIsOnBreak=True
				elseif GuardMarkerRef  &&  ShiftTimeMode==2 && (Gamehour < ShiftTimeStarting  ||  Gamehour >= ShiftTimeEnd)
					bGuardIsOnBreak=True
				endif
			endif


			;*** Squad Safety Rating ***
			Int SafetyRating=6+GetSquadSafetyValue(MarkerOwnerRef)


			if PatrolManager_bIsSquadAtHome_cond
				if bGuardIsOnBreak == False
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(1) as Location)
				elseif bGuardIsOnBreak == True
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(4) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(2) as Location)
				endif
			else
				if bGuardIsOnBreak == False
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(1) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(3) as Location)
				endif
			endif


			;*** show menu ***
			Int iButton=IMP_GuardManagerPatrolMenu01MESGb.Show(PatrolManager_FollowerCount_cond+1, SafetyRating)
			if iButton==1
				ObjectReference[] FollowerRefsToCollection=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
				if FollowerRefsToCollection.length > 0
					FollowerRefsToCollection.Add(MarkerOwnerRef)
					IMP.PIN.Pin_AddActorArrayToCollection_PUBLIC(FollowerRefsToCollection, PatrolRouteAlias.GetReference())
				else
					IMP.PIN.Pin_AddActorToCollection_PUBLIC(MarkerOwnerRef, PatrolRouteAlias.GetReference())
				endif

			elseif iButton==2
				PatrolUnitIndex=-1
				ShowMenu_UnitManager(MarkerOwnerRef, akTargetMarkerRef)

			elseif iButton==3
				if PatrolManager_bIsSquadAtHome_cond
					ShowMenu_PatrolSettings(akTargetMarkerRef)
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==4
				if PatrolManager_bIsSquadAtHome_cond
					IMP.WorkshopParent.UnassignActor(MarkerOwnerRef as WorkshopNPCScript)
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			endif
		endif

	endif
EndFunction


Bool PatrolManager_bAccessToInventory_cond Conditional

Function ShowMenu_UnitManager(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef		
		(akGuardRef as Actor).SetCanDoCommand(False)

		Actor MarkerOwnerRef=akTargetMarkerRef.GetActorRefOwner()
		(MarkerOwnerRef as Actor).SetCanDoCommand(False)

		if MarkerOwnerRef
			;*** displayed data ***
			ActorNameAlias.ForceRefTo(MarkerOwnerRef)
			ActorNameAltAlias.ForceRefTo(akGuardRef)

			FollowerRefs=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
			PatrolManager_FollowerCount_cond=FollowerRefs.length
			PatrolUnitIndex=FollowerRefs.Find(akGuardRef)


			PatrolManager_bIsSquadAtHome_cond = (akTargetMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation()==MarkerOwnerRef.GetCurrentLocation())


			if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
				PatrolManager_bCanBeLeader_cond=True
			elseif akGuardRef.HasKeyword(IMP.ActorTypeNPC) && (akGuardRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				PatrolManager_bCanBeLeader_cond=True
			else
				PatrolManager_bCanBeLeader_cond=False
			endif
			

			;*** is guard on break? ***
			Bool bGuardIsOnBreak
			Int ShiftTimeTypeID=akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID) as Int
			Int GuardRelaxCount=MarkerOwnerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
			ObjectReference GuardMarkerRef=MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
			if GuardRelaxCount > 0  &&  GuardMarkerRef  &&  ShiftTimeTypeID > 0
				Float Gamehour=IMP.Gamehour.GetValue()
			
				Float ShiftTimeStarting=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
				Float ShiftTimeEnd=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
				Int ShiftTimeMode
				if ShiftTimeEnd > ShiftTimeStarting
					ShiftTimeMode=1
				else
					ShiftTimeMode=2
				endif
				
				if GuardMarkerRef  &&  ShiftTimeMode== 1 && (Gamehour >= ShiftTimeStarting  &&  Gamehour < ShiftTimeEnd)
					bGuardIsOnBreak=True
				elseif GuardMarkerRef  &&  ShiftTimeMode==2 && (Gamehour < ShiftTimeStarting  ||  Gamehour >= ShiftTimeEnd)
					bGuardIsOnBreak=True
				endif
			endif


			;*** Squad Safety Rating ***
			Int SquadSafetyRating=6+GetSquadSafetyValue(MarkerOwnerRef)


			;*** Unit Safety Rating ***
			Int UnitSafetyRating		
			if akGuardRef.HasKeyword(IMP.IMP_IsSettler)
				UnitSafetyRating=6
			elseif akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
				Race FollowerRace=(akGuardRef as Actor).GetActorBase().GetRace()
				Int Index=IMP.GuardManager.IMP_GuardSupportCreatureRaces.Find(FollowerRace)
				if Index >= 0
					UnitSafetyRating=IMP.GuardManager.GuardSupportCreatureSafetyRatings[Index]
				endif			
			endif
			

			if PatrolManager_bIsSquadAtHome_cond
				if bGuardIsOnBreak == False
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(1) as Location)
				elseif bGuardIsOnBreak == True
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(4) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(2) as Location)
				endif
			else
				if bGuardIsOnBreak == False
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(1) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardPatrolActivityList.GetAt(3) as Location)
				endif
			endif



			if akGuardRef == MarkerOwnerRef
				PatrolManager_IsFollower_cond=0
				CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(0) as Location)
			else
				if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
					CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(1) as Location)
				else
					CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(2) as Location)
				endif

				if akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol) == NONE
					PatrolManager_IsFollower_cond=1
				else
					PatrolManager_IsFollower_cond=2
				endif
			endif



			;*** Access to non-settlers' inventory? ***
			PatrolManager_bAccessToInventory_cond=True
			Bool bIsWorkshopCreature=akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
			if bIsWorkshopCreature
				if IMP.IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons.GetValue()==0
					PatrolManager_bAccessToInventory_cond=False
				endif
			endif
			


			Int iButton
			if PatrolManager_IsFollower_cond == 1
				iButton=IMP_GuardManagerPatrolMenu02AMESGb.Show(UnitSafetyRating, PatrolManager_FollowerCount_cond+1, SquadSafetyRating)
			else
				iButton=IMP_GuardManagerPatrolMenu02BMESGb.Show(PatrolUnitIndex+2, PatrolManager_FollowerCount_cond+1, UnitSafetyRating)
			endif

			if iButton==1
				ShowMenu_SquadManager(akTargetMarkerRef)

			elseif iButton==2
				if PatrolManager_bIsSquadAtHome_cond
					(akGuardRef as Actor).OpenInventory(True)
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif

			elseif iButton==3
				if PatrolManager_bIsSquadAtHome_cond
					IMP.Pin.Pin_AddActorToCollection_PUBLIC(akGuardRef, PatrolRouteAlias.GetReference())
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==4
				if PatrolManager_bIsSquadAtHome_cond
					if akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
						AddFollower(akGuardRef, MarkerOwnerRef)
					else
						AddFollowerCreature(akGuardRef, MarkerOwnerRef)
					endif
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==5
				if PatrolManager_bIsSquadAtHome_cond
					ReplaceGuard(akGuardRef, akTargetMarkerRef)
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==6
				if PatrolManager_bIsSquadAtHome_cond
					if akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
						RemoveFollower(akGuardRef)
					else
						RemoveFollowerCreature(akGuardRef)
					endif
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==7
				if PatrolManager_bIsSquadAtHome_cond
					IMP.WorkshopParent.UnassignActor(MarkerOwnerRef as WorkshopNPCScript)
				else
					IMP_GuardManagerPatrolMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==8
				PatrolUnitIndex+=1
				if PatrolUnitIndex < PatrolManager_FollowerCount_cond
					ShowMenu_UnitManager(FollowerRefs[PatrolUnitIndex], akTargetMarkerRef)
				else
					PatrolUnitIndex=-1
					ShowMenu_UnitManager(MarkerOwnerRef, akTargetMarkerRef)
				endif
			endif

		endif
	endif
EndFunction



;=============
; MARKER FUNCTIONS
;=============

Function GuardPatrolMarkerOnLoad_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		UpdateSafetyValue(akPositionerRef)
	endif
EndFunction

Function GuardPatrolMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference IdleMarkerRef=akPositionerRef.PlaceAtMe(IMP.IMP_PatrolIdleMarker, abDeleteWhenAble=False)
		IdleMarkerRef.MoveTo(akPositionerRef)
		IdleMarkerRef.SetFactionOwner(IMP.IMP_GuardPatrol_IdlemarkerGuardOwnership)


		ObjectReference MarkerRef
		Float EndLoopTime=Utility.GetCurrentRealTime()+5
		while MarkerRef == NONE && EndLoopTime > Utility.GetCurrentRealTime()		
			MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		endwhile

		(MarkerRef as IMPScriptMarkerGuardPatrolMrk).SetIdleMarkerRef(IdleMarkerRef)
	endif
EndFunction


Function GuardPatrolMarkerOnMoved_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		MarkerRef.MoveTo(akPositionerRef)
		GetIdleMarkerRef(MarkerRef).MoveTo(akPositionerRef)
	endif
EndFunction


Function GuardPatrolMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		Actor OwnerRef=(MarkerRef as IMPScriptMarkerGuardPatrolMrk).GetIdlemarkerRef().GetActorRefOwner()
		RemovePatrolMarkerFromChain(MarkerRef, OwnerRef)
		(MarkerRef as IMPScriptMarkerGuardPatrolMrk).DeleteIdleMarker()
	endif
EndFunction



;=============
; UTILITY FUNCTIONS
;=============

ObjectReference Function GetIdleMarkerRef(ObjectReference akMarkerRef)
	return (akMarkerRef as IMPScriptMarkerGuardPatrolMrk).GetIdleMarkerRef()
EndFunction


;=========


Function SetMarkersOwnership(ObjectReference akMarkerRef, Actor akGuardRef)
	akMarkerRef.SetActorRefOwner(akGuardRef)
	(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(akGuardRef)
	if akGuardRef
		(akMarkerRef as IMPScriptMarkerGuardPatrolMrk).GetIdleMarkerRef().SetActorRefOwner(akGuardRef)
	else
		(akMarkerRef as IMPScriptMarkerGuardPatrolMrk).GetIdleMarkerRef().SetFactionOwner(IMP.IMP_GuardPatrol_IdlemarkerGuardOwnership)
	endif
EndFunction


;=========


ObjectReference[] Function GetIdlemarkerRefChain()
	if FirstIdlemarkerRef
	
		ObjectReference[] ResultIdlemarkerRefs=new ObjectReference[0]

		ObjectReference[] LinkedRefChain=FirstIdlemarkerRef.GetLinkedRefChain()
		LinkedRefChain.Remove(LinkedRefChain.Find(FirstIdlemarkerRef))

		if LinkedRefChain.length == 0
			ResultIdlemarkerRefs.Add(FirstIdlemarkerRef)
		else
			ResultIdlemarkerRefs=LinkedRefChain
			ResultIdlemarkerRefs.Insert(FirstIdlemarkerRef, 0)
		endif

		return ResultIdlemarkerRefs
	endif
EndFunction


;=========


ObjectReference Function GetGuardPatrolControllerRef(ObjectReference akGuardRef)
	if akGuardRef
		ObjectReference WorkshopRef=akGuardRef.GetLinkedRef(IMP.WorkshopItemKeyword)
		ObjectReference[] OwnedObjectRefs=WorkshopRef.GetWorkshopOwnedObjects(akGuardRef as Actor)
		Int OwnedObjectCount=OwnedObjectRefs.length
		Int i=0
		while i < OwnedObjectCount
			ObjectReference iOwnedObjectRef=OwnedObjectRefs[i]
			if iOwnedObjectRef.GetBaseObject() == (IMP.IMP_Controller_GuardPatrol)
				i=OwnedObjectCount
				return iOwnedObjectRef
			endif
			i+=1
		endwhile
	endif
EndFunction


;=========


Function AddMarkerToArray(ObjectReference akMarkerRef)
	if akMarkerRef && MarkerRefs.Find(akMarkerRef) < 0
		MarkerRefs.Add(akMarkerRef)
		ObjectReference IdleMarkerRef=GetIdleMarkerRef(akMarkerRef)
		if IdleMarkerRef && IdlemarkerRefs.Find(IdleMarkerRef) < 0
			IdlemarkerRefs.Add(IdleMarkerRef)
		endif
	endif
EndFunction

Function RemoveMarkerToArray(ObjectReference akMarkerRef)
	if  akMarkerRef
		MarkerRefs.Remove(MarkerRefs.Find(akMarkerRef))
		IdlemarkerRefs.Remove(IdlemarkerRefs.Find(GetIdleMarkerRef(akMarkerRef)))
	endif
EndFunction


;=========


Int Function GetSquadSafetyValue(ObjectReference akLeaderRef)
	if akLeaderRef
		Int NewSafetyValue
	
		if akLeaderRef
			ObjectReference[] LeaderFollowerRefs=akLeaderRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol)
			Int FollowerCount=LeaderFollowerRefs.length
			Int i=0
			while i < FollowerCount
				ObjectReference iFollowerRef=LeaderFollowerRefs[i]
				if iFollowerRef.HasKeyword(IMP.IMP_IsSettler)
					NewSafetyValue+=6
				elseif iFollowerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
					Race FollowerRace=(iFollowerRef as Actor).GetActorBase().GetRace()
					Int Index=IMP.GuardManager.IMP_GuardSupportCreatureRaces.Find(FollowerRace)
					if Index >= 0
						NewSafetyValue+=IMP.GuardManager.GuardSupportCreatureSafetyRatings[Index]
					endif			
				endif
				i+=1
			endwhile
		endif
		
		return NewSafetyValue
	endif
EndFunction

Function UpdateSafetyValue(ObjectReference akPositionerRef)
	if akPositionerRef
		Actor LeaderRef=akPositionerRef.GetActorRefOwner()
		akPositionerRef.SetValue(IMP.Safety, GetSquadSafetyValue(LeaderRef))	
	endif
EndFunction


;==================
; WORKSHOP PARENT EVENTS
;==================

Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference

	if WorkshopObjectRef.HasKeyword(IMP.IMP_IsGuardPatrolController) == True
		if WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardPatrolController)[0]
			Actor OwnerRef=(WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardPatrolController)[0] as Actor)
			UnsetPatrolGuard(OwnerRef)
			
		elseif WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerMarkerPatrol)[0]
			Actor OwnerRef=(WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerMarkerPatrol)[0] as Actor)
			RemoveFollower(OwnerRef)
		endif
	endif
	
EndEvent

