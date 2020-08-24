Scriptname IMPScriptGuardManagerScout extends Quest Conditional

IMPScriptMain IMP
Message property IMP_GuardManagerScoutRadiusMenuMESGb auto const mandatory
Message property IMP_GuardManagerScoutMenu01MESGb auto const mandatory
Message property IMP_GuardManagerScoutMenu02AMESGb auto const mandatory
Message property IMP_GuardManagerScoutMenu02BMESGb auto const mandatory
Message property IMP_GuardManagerScoutMenuNotAtHomeMESGb auto const mandatory
Message property IMP_GuardManagerLeaderUnvalidMESGn auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory 
ReferenceAlias property ActorNameAltAlias auto const mandatory 
LocationAlias property CurrentGuardShift01 auto const mandatory
LocationAlias property CurrentGuardShift02 auto const mandatory

Bool ShowCancelButtonRadiusMenu_cond Conditional

ObjectReference[] FollowerRefs
Int SquadUnitIndex

;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	FollowerRefs=new ObjectReference[0]

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
EndEvent


;=========


Function AssignGuardToScoutmarker_PUBLIC(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef
		(akGuardRef as Actor).SetCanDoCommand(False)

		Actor MarkerOwnerRef=akTargetMarkerRef.GetActorRefOwner()

		if MarkerOwnerRef == NONE
			if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
				ShowMenu_AssignLeader(akGuardRef, akTargetMarkerRef)
				
			elseif akGuardRef.HasKeyword(IMP.ActorTypeNPC)  &&  (akGuardRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				ShowMenu_AssignLeader(akGuardRef, akTargetMarkerRef)
			
			else
				ActorNameAlias.ForceRefTo(akGuardRef)
				IMP_GuardManagerLeaderUnvalidMESGn.Show()
			endif
		else
			ShowMenu_UnitManager(akGuardRef, akTargetMarkerRef)
		endif
	endif
EndFunction


Function ShowMenu_AssignLeader(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef
		ShowCancelButtonRadiusMenu_cond=False
		ShowRadiusMenu(akGuardRef, akTargetMarkerRef)
		IMP.JobAssigning.AssignActorToObject(akGuardRef as WorkshopNPCScript, akTargetMarkerRef as WorkshopObjectScript)
	endif
EndFunction

;=========

Int SquadManager_FollowerCount_cond Conditional
Bool SquadManager_bIsSquadAtHome_cond Conditional
Bool SquadManager_bCanBeLeader_cond Conditional
Int SquadManager_IsFollower_cond Conditional
Formlist property IMP_GuardScoutActivityList auto const mandatory
Formlist property IMP_GuardSquadRankList auto const mandatory

Function ShowMenu_SquadManager(ObjectReference akTargetMarkerRef)
	if akTargetMarkerRef
		Actor MarkerOwnerRef=akTargetMarkerRef.GetActorRefOwner()
		FollowerRefs=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)


		if MarkerOwnerRef
			;*** displayed data ***
			ActorNameAlias.ForceRefTo(MarkerOwnerRef)
			SquadManager_FollowerCount_cond=FollowerRefs.length
			
			Int GuardScoutRadiusID=MarkerOwnerRef.GetValue(IMP.IMP_GuardScoutRadiusID) as Int
			SquadManager_bIsSquadAtHome_cond = (akTargetMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation()==MarkerOwnerRef.GetCurrentLocation())
			Bool bGuardIsOnBreak

			;*** is guard on break? ***
			Int ShiftTimeTypeID=MarkerOwnerRef.GetValue(IMP.IMP_GuardShiftTypeID) as Int
			Int GuardRelaxCount=MarkerOwnerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
			if GuardRelaxCount > 0  &&  GuardScoutRadiusID > 0	&&  ShiftTimeTypeID>0
				Float Gamehour=IMP.Gamehour.GetValue()
				Float ShiftTimeStarting=MarkerOwnerRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
				Float ShiftTimeEnd=MarkerOwnerRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
				Int ShiftTimeMode
				if ShiftTimeEnd > ShiftTimeStarting
					ShiftTimeMode=1
				else
					ShiftTimeMode=2
				endif

				ObjectReference GuardMarkerRef=MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
				if GuardMarkerRef  &&  ShiftTimeMode== 1 && (Gamehour >= ShiftTimeStarting  &&  Gamehour < ShiftTimeEnd)
					bGuardIsOnBreak=True
				elseif GuardMarkerRef  &&  ShiftTimeMode==2 && (Gamehour < ShiftTimeStarting  ||  Gamehour >= ShiftTimeEnd)
					bGuardIsOnBreak=True
				endif
			endif


			;*** Squad Safety Rating ***
			Int SquadSafetyRating=6+GetSquadSafetyValue(MarkerOwnerRef)
			
			
			if SquadManager_bIsSquadAtHome_cond
				if bGuardIsOnBreak == False && GuardScoutRadiusID > 0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(GuardScoutRadiusID) as Location)
				elseif bGuardIsOnBreak && GuardScoutRadiusID > 0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(6) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(4) as Location)
				endif
			else
				if GuardScoutRadiusID==0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(5) as Location)
				elseif bGuardIsOnBreak
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(5) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(GuardScoutRadiusID) as Location)
				endif
			endif


			;*** show menu ***
			Int iButton=IMP_GuardManagerScoutMenu01MESGb.Show(SquadManager_FollowerCount_cond+1, SquadSafetyRating)
			if iButton==1
				ObjectReference[] FollowerRefsToCollection=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)
				if FollowerRefsToCollection.length > 0
					FollowerRefsToCollection.Add(MarkerOwnerRef)
					IMP.PIN.Pin_AddActorArrayToCollection_PUBLIC(FollowerRefsToCollection, (MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef())
				else
					IMP.PIN.Pin_AddActorToCollection_PUBLIC(MarkerOwnerRef, (MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef())
				endif
				
			elseif iButton==2
				SquadUnitIndex=-1
				ShowMenu_UnitManager(MarkerOwnerRef, akTargetMarkerRef)

			elseif iButton==3
				if SquadManager_bIsSquadAtHome_cond
					ShowCancelButtonRadiusMenu_cond=True
					ShowRadiusMenu(MarkerOwnerRef, akTargetMarkerRef)
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==4
				StopCurrentPatrol(MarkerOwnerRef)

			elseif iButton==5
				if SquadManager_bIsSquadAtHome_cond
					IMP.WorkshopParent.UnassignActor(MarkerOwnerRef as WorkshopNPCScript)
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			endif
		endif

	endif
EndFunction


Function ShowMenu_SquadManager_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	ShowMenu_SquadManager(MarkerRef)
EndFunction


Bool SquadManager_bAccessToInventory_cond Conditional

Function ShowMenu_UnitManager(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef

		Actor MarkerOwnerRef=akTargetMarkerRef.GetActorRefOwner()
		if MarkerOwnerRef

			;*** displayed data ***
			ActorNameAlias.ForceRefTo(MarkerOwnerRef)
			ActorNameAltAlias.ForceRefTo(akGuardRef)

			FollowerRefs=MarkerOwnerRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)
			SquadManager_FollowerCount_cond=FollowerRefs.length
			SquadUnitIndex=FollowerRefs.Find(akGuardRef)

			SquadManager_bIsSquadAtHome_cond = (akTargetMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation()==MarkerOwnerRef.GetCurrentLocation())


			if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
				SquadManager_bCanBeLeader_cond=True
			elseif akGuardRef.HasKeyword(IMP.ActorTypeNPC) && (akGuardRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				SquadManager_bCanBeLeader_cond=True
			else
				SquadManager_bCanBeLeader_cond=False
			endif

			Int GuardScoutRadiusID=MarkerOwnerRef.GetValue(IMP.IMP_GuardScoutRadiusID) as Int			
			
			
			;*** is guard on break? ***
			Bool bGuardIsOnBreak
			Int GuardRelaxCount=MarkerOwnerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
			if GuardRelaxCount > 0 &&  GuardScoutRadiusID > 0	
				Float Gamehour=IMP.Gamehour.GetValue()
			
				Float ShiftTimeStarting=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
				Float ShiftTimeEnd=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
				Int ShiftTimeMode
				if ShiftTimeEnd > ShiftTimeStarting
					ShiftTimeMode=1
				else
					ShiftTimeMode=2
				endif
				
				ObjectReference GuardMarkerRef=MarkerOwnerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
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


			if SquadManager_bIsSquadAtHome_cond
				if bGuardIsOnBreak == False && GuardScoutRadiusID > 0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(GuardScoutRadiusID) as Location)
				elseif bGuardIsOnBreak && GuardScoutRadiusID > 0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(6) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(4) as Location)
				endif
			else
				if GuardScoutRadiusID==0
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(5) as Location)
				elseif bGuardIsOnBreak
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(5) as Location)
				else
					CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(GuardScoutRadiusID) as Location)
				endif
			endif



			if akGuardRef == MarkerOwnerRef
				SquadManager_IsFollower_cond=0
				CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(0) as Location)
			else
				if akGuardRef.HasKeyword(IMP.ActorTypeNPC)
					CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(1) as Location)
				else
					CurrentGuardShift02.ForceLocationTo(IMP_GuardSquadRankList.GetAt(2) as Location)
				endif

				if akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout) == NONE
					SquadManager_IsFollower_cond=1
				else
					SquadManager_IsFollower_cond=2
				endif
			endif



			;*** Access to non-settlers' inventory? ***
			SquadManager_bAccessToInventory_cond=True
			Bool bIsWorkshopCreature=akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)
			if bIsWorkshopCreature
				if IMP.IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons.GetValue()==0
					SquadManager_bAccessToInventory_cond=False
				endif
			endif



			Int iButton
			if SquadManager_IsFollower_cond == 1
				iButton=IMP_GuardManagerScoutMenu02AMESGb.Show(UnitSafetyRating, SquadManager_FollowerCount_cond+1, SquadSafetyRating)
			else
				iButton=IMP_GuardManagerScoutMenu02BMESGb.Show(SquadUnitIndex+2, SquadManager_FollowerCount_cond+1, UnitSafetyRating)
			endif

			if iButton==1
				ShowMenu_SquadManager(akTargetMarkerRef)
				
			elseif iButton==2
				if SquadManager_bIsSquadAtHome_cond
					(akGuardRef as Actor).OpenInventory(True)
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==3
				if SquadManager_bIsSquadAtHome_cond
					IMP.Pin.Pin_AddActorToCollection_PUBLIC(akGuardRef, (akTargetMarkerRef as IMPScriptMarker).GetPositionerRef())
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==4
				if SquadManager_bIsSquadAtHome_cond
					if akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
						AddFollower(akGuardRef, MarkerOwnerRef)
					else
						AddFollowerCreature(akGuardRef, MarkerOwnerRef)
					endif
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==5
				if SquadManager_bIsSquadAtHome_cond
					ReplaceLeader(akGuardRef, MarkerOwnerRef)
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==6
				if SquadManager_bIsSquadAtHome_cond
					if akGuardRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
						RemoveFollower(akGuardRef)
					else
						RemoveFollowerCreature(akGuardRef)
					endif
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==7
				if SquadManager_bIsSquadAtHome_cond
					IMP.WorkshopParent.UnassignActor(MarkerOwnerRef as WorkshopNPCScript)
				else
					IMP_GuardManagerScoutMenuNotAtHomeMESGb.Show()
				endif
				
			elseif iButton==8
				SquadUnitIndex+=1
				if SquadUnitIndex < SquadManager_FollowerCount_cond
					ShowMenu_UnitManager(FollowerRefs[SquadUnitIndex], akTargetMarkerRef)
				else
					SquadUnitIndex=-1
					ShowMenu_UnitManager(MarkerOwnerRef, akTargetMarkerRef)
				endif
				
			endif

		endif
	endif
EndFunction


Function ShowRadiusMenu(ObjectReference akGuardRef, ObjectReference akTargetMarkerRef)
	if akGuardRef && akTargetMarkerRef
		Int GuardScoutRadiusID=akGuardRef.GetValue(IMP.IMP_GuardScoutRadiusID) as Int
		CurrentGuardShift01.ForceLocationTo(IMP_GuardScoutActivityList.GetAt(GuardScoutRadiusID) as Location)

		Int iButton=IMP_GuardManagerScoutRadiusMenuMESGb.Show()
		if iButton ==  0
			ShowMenu_SquadManager(akTargetMarkerRef)

		elseif iButton ==  1
			akGuardRef.SetValue(IMP.IMP_GuardScoutRadiusID, 1)
			akGuardRef.SetLinkedRef(akTargetMarkerRef, IMP.IMP_LinkScoutMarker)
			SetScoutPackage(akGuardRef)

		elseif iButton ==  2
			akGuardRef.SetValue(IMP.IMP_GuardScoutRadiusID, 2)
			akGuardRef.SetLinkedRef(akTargetMarkerRef, IMP.IMP_LinkScoutMarker)
			SetScoutPackage(akGuardRef)

		elseif iButton ==  3
			akGuardRef.SetValue(IMP.IMP_GuardScoutRadiusID, 3)
			akGuardRef.SetLinkedRef(akTargetMarkerRef, IMP.IMP_LinkScoutMarker)
			SetScoutPackage(akGuardRef)

		endif

	endif
EndFunction


Function StopCurrentPatrol(ObjectReference akGuardRef)
	if akGuardRef
		akGuardRef.SetValue(IMP.IMP_GuardScoutTaskEnd, Utility.GetCurrentGametime())
		akGuardRef.SetValue(IMP.IMP_GuardScoutTaskStart, Utility.GetCurrentGametime() + 1)
		(akGuardRef as Actor).EvaluatePackage()
	endif
EndFunction


Function SetScoutPackage(ObjectReference akGuardRef)
	if akGuardRef
		Float CurrentGametime=Utility.GetCurrentGametime()
		if CurrentGametime >= akGuardRef.GetValue(IMP.IMP_GuardScoutTaskStart) 
			Float TaskEndTime=CurrentGametime + 8/24.0000
			akGuardRef.SetValue(IMP.IMP_GuardScoutTaskEnd, TaskEndTime)
			Float TaskStartTime=CurrentGametime + 1.0000 + 8/24.0000
			akGuardRef.SetValue(IMP.IMP_GuardScoutTaskStart, TaskStartTime)
			(akGuardRef as Actor).EvaluatePackage()
		endif
	endif
EndFunction


Function SetScoutPackage_PUBLIC(ObjectReference akGuardRef)
	SetScoutPackage(akGuardRef)
EndFunction


;=========


Function RemoveScout(ObjectReference akGuardRef)
	if akGuardRef
		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(akGuardRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)	

		DismissFollowers(akGuardRef)

		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkScoutMarker)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerScout)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
		akGuardRef.SetValue(IMP.IMP_GuardScoutRadiusID, 0)
		akGuardRef.SetValue(IMP.IMP_GuardScoutTaskEnd, 0)
		akGuardRef.SetValue(IMP.IMP_GuardScoutTaskStart, 0)
		(akGuardRef as Actor).EvaluatePackage()	
	endif
EndFunction



;=========================================
;						FOLLOWERS
;=========================================

Function AddFollower(ObjectReference akFollowerRef, ObjectReference akLeaderRef)
	if akFollowerRef  &&  akLeaderRef
		(akFollowerRef as Actor).SetCanDoCommand(False)
		
		;*** make sure to reset if it's a patrol guard ***
		if akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolController)
			IMP.GuardPatrol.UnsetPatrolGuard(akFollowerRef)
		elseif akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerPatrol)
			if akFollowerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
				IMP.GuardPatrol.RemoveFollower(akFollowerRef)
			else
				IMP.GuardPatrol.RemoveFollowerCreature(akFollowerRef)
			endif
		endif

		WorkshopScript WorkshopRef=akLeaderRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference FollowerMarkerRef=akFollowerRef.PlaceAtMe(IMP.IMP_Controller_GuardScoutFollower, abDeleteWhenAble=False)
		IMP.WorkshopParent.BuildObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
		IMP.WorkshopParent.AssignActorToObjectPUBLIC(akFollowerRef as WorkshopNPCScript, FollowerMarkerRef as WorkshopObjectScript)
		FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
		WorkshopRef.RecalculateWorkshopResources()

		akFollowerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerScout)
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeMode, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeMode))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
		akFollowerRef.SetLinkedRef(akLeaderRef, IMP.IMP_LinkGuardFollowerLeaderScout)
		(akFollowerRef as Actor).EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(akLeaderRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)
	endif
EndFunction


Function RemoveFollower(ObjectReference akFollowerRef)
	if akFollowerRef
		(akFollowerRef as Actor).SetCanDoCommand(False)

		ObjectReference LeaderRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
		
		ObjectReference FollowerMarkerRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerScout)
		WorkshopScript WorkshopRef=FollowerMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		IMP.WorkshopParent.RemoveObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
		FollowerMarkerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)

		FollowerMarkerRef.DisableNoWait()
		FollowerMarkerRef.Delete()

		WorkshopRef.RecalculateWorkshopResources()
		
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkScoutMarker)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerScout)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutRadiusID, 0)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutTaskEnd, 0)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutTaskStart, 0)		
		(akFollowerRef as Actor).EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(LeaderRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)
	endif
EndFunction

;---------

Function AddFollowerCreature(ObjectReference akFollowerRef, ObjectReference akLeaderRef)
	if akFollowerRef  &&  akLeaderRef
		(akFollowerRef as Actor).SetCanDoCommand(False)
		
		;*** make sure to reset if it's a patrol guard ***
		if akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerPatrol)
			IMP.GuardPatrol.RemoveFollowerCreature(akFollowerRef)
		endif

		WorkshopScript WorkshopRef=akLeaderRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference FollowerMarkerRef=akFollowerRef.PlaceAtMe(IMP.IMP_Controller_GuardScoutFollowerCreature, abDeleteWhenAble=False)
		FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
		FollowerMarkerRef.SetActorRefOwner(akFollowerRef as Actor)

		akFollowerRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerScout)
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeMode, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeMode))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
		akFollowerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akLeaderRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
		akFollowerRef.SetLinkedRef(akLeaderRef, IMP.IMP_LinkGuardFollowerLeaderScout)
		(akFollowerRef as Actor).EvaluatePackage()
		
		Int FollowerSafetyValue=akFollowerRef.GetValue(IMP.Safety) as Int
		if FollowerSafetyValue == 0
			akFollowerRef.SetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue, FollowerSafetyValue)
			
			Race FollowerRace=(akFollowerRef as Actor).GetActorBase().GetRace()
			Int Index=IMP.GuardManager.IMP_GuardSupportCreatureRaces.Find(FollowerRace)
			if Index >= 0
				FollowerSafetyValue=IMP.GuardManager.GuardSupportCreatureSafetyRatings[Index]
				akFollowerRef.SetValue(IMP.Safety, FollowerSafetyValue)
				WorkshopRef.RecalculateWorkshopResources()
			endif
		endif

		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(akLeaderRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)
	endif
EndFunction


Function RemoveFollowerCreature(ObjectReference akFollowerRef)
	if akFollowerRef
		(akFollowerRef as Actor).SetCanDoCommand(False)

		ObjectReference LeaderRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
		ObjectReference FollowerMarkerRef=akFollowerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerScout)
		WorkshopScript WorkshopRef=FollowerMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript

		FollowerMarkerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
		FollowerMarkerRef.SetActorRefOwner(NONE)
		FollowerMarkerRef.DisableNoWait()
		FollowerMarkerRef.Delete()

		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkScoutMarker)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerScout)
		akFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutRadiusID, 0)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutTaskEnd, 0)
		akFollowerRef.SetValue(IMP.IMP_GuardScoutTaskStart, 0)		
		
		Int FollowerSafetyValue=akFollowerRef.GetValue(IMP.Safety) as Int
		Int GuardCreatureFollowerStartingSafetyValue=akFollowerRef.GetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue) as Int
		if GuardCreatureFollowerStartingSafetyValue > 0
			akFollowerRef.SetValue(IMP.Safety, GuardCreatureFollowerStartingSafetyValue)
			akFollowerRef.SetValue(IMP.IMP_GuardCreatureFollowerStartingSafetyValue, 0)
		else
			akFollowerRef.SetValue(IMP.Safety, 0)
		endif		
		WorkshopRef.RecalculateWorkshopResources()
		
		(akFollowerRef as Actor).EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(LeaderRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)
	endif
EndFunction


;---------

Function DismissFollowers(ObjectReference akLeaderRef)
	if akLeaderRef
		FollowerRefs=akLeaderRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)																											

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

Function ReplaceLeader(ObjectReference akNewLeaderRef, ObjectReference akOldLeaderRef)
	if akNewLeaderRef &&  akOldLeaderRef
		(akNewLeaderRef as Actor).SetCanDoCommand(False)

		FollowerRefs=akOldLeaderRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)
		Int FollowerCount=FollowerRefs.length
		FollowerRefs.Remove(FollowerRefs.Find(akNewLeaderRef))
		
		ObjectReference ScoutMarkerRef=akOldLeaderRef.GetLinkedRef(IMP.IMP_LinkScoutMarker)
		Objectreference FollowerMarkerRef=akNewLeaderRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerMarkerScout)

		
		if FollowerMarkerRef
			;*** do this if the new leader is already a squad unit ***

			;*** set new leader ***
			akNewLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerScout)
			akNewLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
			akNewLeaderRef.SetLinkedRef(ScoutMarkerRef, IMP.IMP_LinkScoutMarker)
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutRadiusID, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutRadiusID))
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutTaskEnd, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutTaskEnd))
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutTaskStart, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutTaskStart))
			ScoutMarkerRef.SetActorRefOwner(akNewLeaderRef as Actor)
			(akNewLeaderRef as Actor).EvaluatePackage()


			;*** set old leader as follower ***
			akOldLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkScoutMarker)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutRadiusID, 0)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutTaskEnd, 0)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutTaskStart, 0)

			FollowerMarkerRef.SetActorRefOwner(akOldLeaderRef as Actor)
			akOldLeaderRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerScout)
			akOldLeaderRef.SetLinkedRef(akNewLeaderRef, IMP.IMP_LinkGuardFollowerLeaderScout)
			(akOldLeaderRef as Actor).EvaluatePackage()
			
		else
			;*** do this if the new leader is not a squad unit ***
			
			;*** remove new leader from former job ***
			IMP.WorkshopParent.UnassignActor(akNewLeaderRef as WorkshopNPCScript)
			(akNewLeaderRef as WorkshopNPCScript).bIsWorker=True
			(akNewLeaderRef as WorkshopNPCScript).bIsGuard=True
			
			;*** set new leader ***
			akNewLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerMarkerScout)
			akNewLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
			akNewLeaderRef.SetLinkedRef(ScoutMarkerRef, IMP.IMP_LinkScoutMarker)
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutRadiusID, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutRadiusID))
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutTaskEnd, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutTaskEnd))
			akNewLeaderRef.SetValue(IMP.IMP_GuardScoutTaskStart, akOldLeaderRef.GetValue(IMP.IMP_GuardScoutTaskStart))
			ScoutMarkerRef.SetActorRefOwner(akNewLeaderRef as Actor)
			(akNewLeaderRef as Actor).EvaluatePackage()


			;*** set old leader as follower ***
			akOldLeaderRef.SetLinkedRef(NONE, IMP.IMP_LinkScoutMarker)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutRadiusID, 0)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutTaskEnd, 0)
			akOldLeaderRef.SetValue(IMP.IMP_GuardScoutTaskStart, 0)

			WorkshopScript WorkshopRef=akOldLeaderRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
			FollowerMarkerRef=akOldLeaderRef.PlaceAtMe(IMP.IMP_Controller_GuardScoutFollower, abDeleteWhenAble=False)
			IMP.WorkshopParent.BuildObjectPUBLIC(FollowerMarkerRef as WorkshopObjectScript, WorkshopRef)
			FollowerMarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)

			FollowerMarkerRef.SetActorRefOwner(akOldLeaderRef as Actor)
			akOldLeaderRef.SetLinkedRef(FollowerMarkerRef, IMP.IMP_LinkGuardFollowerMarkerScout)
			akOldLeaderRef.SetLinkedRef(akNewLeaderRef, IMP.IMP_LinkGuardFollowerLeaderScout)
			(akOldLeaderRef as Actor).EvaluatePackage()
			

			;*** update safety value on positioner ***
			ObjectReference LeaderPositionerRef=(ScoutMarkerRef as IMPScriptMarker).GetPositionerRef()
			UpdateSafetyValue(LeaderPositionerRef)
			WorkshopRef.RecalculateWorkshopResources()
			
		endif
		
		
		;*** reset followers ***
		Int i=0
		while i < FollowerCount
			Actor iFollowerRef=FollowerRefs[i] as Actor
			iFollowerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardFollowerLeaderScout)
			iFollowerRef.EvaluatePackage()
			
			Utility.Wait(0.3)
			
			iFollowerRef.SetLinkedRef(akNewLeaderRef, IMP.IMP_LinkGuardFollowerLeaderScout)
			iFollowerRef.EvaluatePackage()
			i+=1
		endwhile		
	endif
EndFunction



;=========================================
;						POSITIONER
;=========================================

Function GuardScoutMarkerOnLoad_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		UpdateSafetyValue(akPositionerRef)
	endif
EndFunction

Function GuardScoutMarkerOnMoved_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		Actor OwnerRef=(MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkScoutMarker)[0] as Actor)
		
		Int StartingGuardScoutRadiusID=OwnerRef.GetValue(IMP.IMP_GuardScoutRadiusID) as Int
		OwnerRef.SetValue(IMP.IMP_GuardScoutRadiusID, -1)
		OwnerRef.EvaluatePackage()
		OwnerRef.SetValue(IMP.IMP_GuardScoutRadiusID, StartingGuardScoutRadiusID)
		OwnerRef.EvaluatePackage()

		;*** update safety value on positioner ***
		ObjectReference LeaderPositionerRef=(OwnerRef.GetLinkedRef(IMP.IMP_LinkScoutMarker) as IMPScriptMarker).GetPositionerRef()
		UpdateSafetyValue(LeaderPositionerRef)
	endif
EndFunction

Function GuardScoutMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		Actor OwnerRef=(MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkScoutMarker)[0] as Actor)
		RemoveScout(OwnerRef)
	endif
EndFunction


;=========


Int Function GetSquadSafetyValue(ObjectReference akLeaderRef)
	if akLeaderRef
		Int NewSafetyValue

		if akLeaderRef
			ObjectReference[] LeaderFollowerRefs=akLeaderRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout)
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
		if LeaderRef
			akPositionerRef.SetValue(IMP.Safety, GetSquadSafetyValue(LeaderRef))	
		endif
	endif
EndFunction



;=========================================
;						REMOTE EVENTS
;=========================================

Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference

	if WorkshopObjectRef.HasKeyword(IMP.IMP_IsGuardScoutController) == True
		if WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkScoutMarker)[0]
			Actor OwnerRef=(WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkScoutMarker)[0] as Actor)
			RemoveScout(OwnerRef)

		elseif WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerMarkerScout)[0]
			Actor OwnerRef=(WorkshopObjectRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardFollowerMarkerScout)[0] as Actor)
			RemoveFollower(OwnerRef)
		endif
	endif
EndEvent