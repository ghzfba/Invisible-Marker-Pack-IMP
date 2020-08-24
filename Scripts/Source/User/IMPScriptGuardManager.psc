Scriptname IMPScriptGuardManager extends Quest Conditional

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
RefCollectionAlias property GuardCollection auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory
LocationAlias property LocationNameAlias auto const mandatory
LocationAlias property CurrentGuardShift01 auto const mandatory
LocationAlias property CurrentGuardShift02 auto const mandatory
LocationAlias property CurrentGuardShift03 auto const mandatory
Message property IMP_GuardManagerShiftCustomTimeGuardMESGn auto const mandatory
Message property IMP_GuardManagerGuardUnvalidMESGn auto const mandatory
Message property IMP_GuardManagerShiftTypeMenuMESGb auto const mandatory
Message property IMP_GuardManagerEntryMenu00MESGb auto const mandatory
Message property IMP_GuardManagerEntryMenu01MESGb auto const mandatory

Int[] property GuardSupportCreatureSafetyRatings auto const mandatory
Formlist property IMP_GuardSupportCreatureRaces auto const mandatory

IMPScriptMain IMP


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	InitializeCollections()

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
EndEvent



;==================
; WORKSHOP PARENT EVENTS
;==================

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ResourceRef=akArgs[0] as ObjectReference

	if ResourceRef.HasKeyword(IMP.WorkshopGuardObject)
		Actor OwnerRef=ResourceRef.GetActorRefOwner()
		if OwnerRef
			(ResourceRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(OwnerRef)
			SetGuard(OwnerRef)
			GuardCollection.EvaluateAll()
		endif
	endif
EndEvent


Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ResourceRef=akArgs[0] as ObjectReference
	if ResourceRef.HasKeyword(IMP.WorkshopGuardObject)
		(ResourceRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
		GuardCollection.EvaluateAll()
	endif
EndEvent



;======================
; FUNCTIONS USED BY COLLECTIONS
;======================

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	GuardCollection.AddArray(GetSettlementGuards(akWorkshopRef))

	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction

;---------

Function GuardOnUnload_PUBLIC(ObjectReference akGuardRef)
	WorkshopNPCScript GuardActorRef=akGuardRef as WorkshopNPCScript

	if !GuardActorRef.bIsGuard
		UnsetGuard(GuardActorRef)
	endif
EndFunction



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
			GuardCollection.AddArray(GetSettlementGuards(iWorkshopRef))
		endif
		i+=1
	endwhile
EndFunction


ObjectReference[] Function GetSettlementGuards(ObjectReference akWorkshopRef)
	if akWorkshopRef
		ObjectReference[] WorkshopActorRefs=IMP.WorkshopParent.GetWorkshopActors(akWorkshopRef as WorkshopScript)
		Int WorkshopActorCount=WorkshopActorRefs.length

		if  WorkshopActorCount > 0
			ObjectReference[] SettlementGuardRefs=new ObjectReference[0]
			Int i=0
			while i < WorkshopActorCount
				WorkshopNPCScript iActorRef=WorkshopActorRefs[i] as WorkshopNPCScript
				if iActorRef.bIsGuard
					SettlementGuardRefs.Add(iActorRef)
					SetGuard(iActorRef)
				endif
				i+=1
			endwhile

			if SettlementGuardRefs.length > 0
				GuardCollection.EvaluateAll()
				return SettlementGuardRefs
			endif
		endif
	endif
EndFunction


;===========
; SETTING GUARDS
;===========

Int DailyShiftCount=4

Function SetGuard(ObjectReference akSettlerRef)
	if akSettlerRef
	
		GuardCollection.AddRef(akSettlerRef)

		if akSettlerRef.HasKeyword(IMP.ActorTypeNPC)
		
			Float CurrentGametime=IMP.Gamehour.GetValue()
			if CurrentGametime >= akSettlerRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
				Float ShiftTimeStarting=Math.Ceiling(CurrentGametime) + (24.00/DailyShiftCount) + Utility.RandomInt(0, 12)
				if ShiftTimeStarting >= 24
					ShiftTimeStarting=ShiftTimeStarting-24
				endif
				
				Float ShiftTimeEnd=ShiftTimeStarting + 24.00/DailyShiftCount
				if ShiftTimeEnd >= 24
					ShiftTimeEnd=ShiftTimeEnd-24
				endif


				akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, ShiftTimeStarting)
				akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, ShiftTimeEnd)
				if ShiftTimeEnd > ShiftTimeStarting
					akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeMode, 1)
				else
					akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeMode, 2)
				endif
			endif

			
			if akSettlerRef.GetValue(IMP.IMP_GuardShiftTypeID) == 0
				Int GuardShiftTypeID
				Int GuardShiftRandom
				Int Roll=Utility.RandomInt(1, 3)
				if Roll == 3
					GuardShiftTypeID=Utility.RandomInt(1, 2)
					GuardShiftRandom=1
				else
					GuardShiftTypeID=Roll
					GuardShiftRandom=0
				endif
				
				akSettlerRef.SetValue(IMP.IMP_GuardShiftTypeID, GuardShiftTypeID)
				akSettlerRef.SetValue(IMP.IMP_GuardShiftRandom, GuardShiftRandom)
			endif
		
		endif
		
	endif
EndFunction


Function UnsetGuard(ObjectReference akSettlerRef)
	if akSettlerRef
		GuardCollection.RemoveRef(akSettlerRef)
		akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarker)
		akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarkerForced)
		
		akSettlerRef.SetValue(IMP.IMP_GuardShiftTypeID, 0)
		akSettlerRef.SetValue(IMP.IMP_GuardShiftRandom, 0)
		akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, 0)
		akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, 0)
		akSettlerRef.SetValue(IMP.IMP_GuardShiftTimeMode, 0)
		
		UnsetPowerarmorStuff(akSettlerRef)
	endif
EndFunction



;==============================
; FUNCTIONS USED BY WorkshopJobAssign Script
;==============================

Function AssignGuardToRelaxMarker_PUBLIC(ObjectReference akGuardRef, ObjectReference akMarkerRef)
	if akGuardRef && akMarkerRef	
		if \
		akGuardRef.HasKeyword(IMP.ActorTypeNPC) && \
		akGuardRef.HasKeyword(IMP.IMP_IsGuard) && \
		(akGuardRef as WorkshopNPCScript).bIsGuard
		
			ShowGuardShiftMainMenu(akGuardRef, akMarkerRef)

		else

			LocationNameAlias.ForceLocationTo(akGuardRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
			IMP_GuardManagerGuardUnvalidMESGn.Show()
			
		endif
	endif
EndFunction


;---------

Bool bIsGuardLinkedToRelaxMarker Conditional
Bool bHasGuardRelaxBeenSelected Conditional

Function ShowGuardShiftMainMenu_PUBLIC(ObjectReference akGuardRef, ObjectReference akMarkerRef=NONE)
	ShowGuardShiftMainMenu(akGuardRef, akMarkerRef)
EndFunction


Function ShowGuardShiftMainMenu(ObjectReference akGuardRef, ObjectReference akMarkerRef=NONE)
	if akGuardRef
		ActorNameAlias.ForceRefTo(akGuardRef)
		bIsGuardLinkedToRelaxMarker=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardMarkerForced) as Bool
		bHasGuardRelaxBeenSelected=akMarkerRef as Bool

		Float CurrentTimeStarting=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
		Float CurrentTimeEnd=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd)

		Message GuardManagerEntryMenuMESGb
		Int CurrentGuardShiftRandom=akGuardRef.GetValue(IMP.IMP_GuardShiftRandom) as Int
		if CurrentGuardShiftRandom == 0
			Int CurrentGuardShiftTypeID=akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID) as Int
			CurrentGuardShift01.ForceLocationTo(IMP.IMP_GuardShiftTypeList.GetAt(CurrentGuardShiftTypeID) as Location)
			if CurrentGuardShiftTypeID == 0
				GuardManagerEntryMenuMESGb=IMP_GuardManagerEntryMenu00MESGb
			else
				GuardManagerEntryMenuMESGb=IMP_GuardManagerEntryMenu01MESGb
			endif
		else
			Int CurrentGuardShiftTypeID=akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID) as Int
			CurrentGuardShift01.ForceLocationTo(IMP.IMP_GuardShiftTypeList.GetAt(3) as Location)
			if CurrentGuardShiftTypeID == 0
				GuardManagerEntryMenuMESGb=IMP_GuardManagerEntryMenu00MESGb
			else
				GuardManagerEntryMenuMESGb=IMP_GuardManagerEntryMenu01MESGb
			endif		
		endif


		Int iButton=GuardManagerEntryMenuMESGb.Show(CurrentTimeStarting, CurrentTimeEnd)
		if iButton == 1
			EditGuardShiftValues(akGuardRef)

		elseif iButton == 2
			;*** do this to reset IMP_LinkGuardMarkerForced package target ***
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarker)
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarkerForced)
			(akGuardRef  as Actor).EvaluatePackage()

			Utility.Wait(0.3)

			akGuardRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkGuardMarker)
			akGuardRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkGuardMarkerForced)
			(akGuardRef as Actor).EvaluatePackage()

		elseif iButton == 3
			akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarkerForced)
			(akGuardRef  as Actor).EvaluatePackage()

		endif
	endif
EndFunction


Function EditGuardShiftValues(ObjectReference akGuardRef)
	if akGuardRef
		Int CurrentGuardShiftTypeID=akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID) as Int

		CurrentGuardShift01.ForceLocationTo(IMP.IMP_GuardShiftTypeList.GetAt(CurrentGuardShiftTypeID) as Location)
		Int iButton=IMP_GuardManagerShiftTypeMenuMESGb.Show()
		if iButton == 3
			Int GuardShiftTypeID=Utility.RandomInt(1, 2)
			akGuardRef.SetValue(IMP.IMP_GuardShiftTypeID, GuardShiftTypeID)
			akGuardRef.SetValue(IMP.IMP_GuardShiftRandom, 1)
		else
			akGuardRef.SetValue(IMP.IMP_GuardShiftTypeID, iButton)
			akGuardRef.SetValue(IMP.IMP_GuardShiftRandom, 0)
		endif


		if akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID) > 0
			SetCustomTimeINIT(akGuardRef)
		endif
				
		(akGuardRef as Actor).EvaluatePackage()


		;*** handle followers ***
		ObjectReference LeaderRef
		Keyword LinkFollowerLeader
		if akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
			LeaderRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
			LeaderRef.SetValue(IMP.IMP_GuardShiftTypeID, akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID))
			LeaderRef.SetValue(IMP.IMP_GuardShiftRandom, akGuardRef.GetValue(IMP.IMP_GuardShiftRandom))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeMode, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeMode))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
			(LeaderRef as Actor).EvaluatePackage()
			
		elseif akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
			LeaderRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
			LeaderRef.SetValue(IMP.IMP_GuardShiftTypeID, akGuardRef.GetValue(IMP.IMP_GuardShiftTypeID))
			LeaderRef.SetValue(IMP.IMP_GuardShiftRandom, akGuardRef.GetValue(IMP.IMP_GuardShiftRandom))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeMode, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeMode))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
			LeaderRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd))
			(LeaderRef as Actor).EvaluatePackage()	
			
		elseif akGuardRef.CountRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderPatrol) > 0
			LinkFollowerLeader=IMP.IMP_LinkGuardFollowerLeaderPatrol
			LeaderRef=akGuardRef
			(LeaderRef as Actor).EvaluatePackage()		

		elseif akGuardRef.CountRefsLinkedToMe(IMP.IMP_LinkGuardFollowerLeaderScout) > 0
			LinkFollowerLeader=IMP.IMP_LinkGuardFollowerLeaderScout
			LeaderRef=akGuardRef
			(LeaderRef as Actor).EvaluatePackage()		

		endif


		if LinkFollowerLeader
			ObjectReference[] FollowerRefs=LeaderRef.GetRefsLinkedToMe(LinkFollowerLeader)
			FollowerRefs.Remove(FollowerRefs.Find(akGuardRef))
			Int FollowerCount=FollowerRefs.length
			Int i=0
			while i < FollowerCount
				ObjectReference iFollowerRef=FollowerRefs[i]
				iFollowerRef.SetValue(IMP.IMP_GuardShiftTimeMode, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeMode))
				iFollowerRef.SetValue(IMP.IMP_GuardShiftTimeStarting, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting))
				iFollowerRef.SetValue(IMP.IMP_GuardShiftTimeEnd, akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd))		
				(iFollowerRef as Actor).EvaluatePackage()
				i+=1
			endwhile

			IMP_GuardManagerShiftCustomTimeSquadMESGn.Show()
		else
			IMP_GuardManagerShiftCustomTimeGuardMESGn.Show()
		endif		

	endif
EndFunction

;---------

Int MenuCustomTime_cond Conditional
Float InitialTimeStarting
Float InitialTimeEnd
Float TempCustomTimeStarting
Float TempCustomTimeEnd

Message property IMP_GuardManagerShiftCustomTimeMenuMESGb auto const mandatory
Message property IMP_GuardManagerShiftCustomTimeSquadMESGn auto const mandatory

Function SetCustomTimeINIT(ObjectReference akGuardRef)
	MenuCustomTime_cond=0
	InitialTimeStarting=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeStarting)
	InitialTimeEnd=akGuardRef.GetValue(IMP.IMP_GuardShiftTimeEnd)
	TempCustomTimeStarting=InitialTimeStarting
	TempCustomTimeEnd=InitialTimeEnd
	SetCustomTime(akGuardRef)
EndFunction


Function SetCustomTime(ObjectReference akGuardRef)
	int iButton=IMP_GuardManagerShiftCustomTimeMenuMESGb.Show(InitialTimeStarting, InitialTimeEnd, TempCustomTimeStarting, TempCustomTimeEnd)
		
	if iButton == 0
		if MenuCustomTime_cond == 0
			TempCustomTimeStarting=TempCustomTimeStarting+1
			if TempCustomTimeStarting >= 24
				TempCustomTimeStarting=0
			endif
		else
			TempCustomTimeEnd=TempCustomTimeEnd+1
			if TempCustomTimeEnd >= 24
				TempCustomTimeEnd=0
			endif
		endif
		SetCustomTime(akGuardRef)
		
	elseif iButton == 1
		if MenuCustomTime_cond == 0
			TempCustomTimeStarting=TempCustomTimeStarting-1
			if TempCustomTimeStarting < 0
				TempCustomTimeStarting=23
			endif
		else
			TempCustomTimeEnd=TempCustomTimeEnd-1
			if TempCustomTimeEnd < 0
				TempCustomTimeEnd=23
			endif
		endif
		SetCustomTime(akGuardRef)

	elseif iButton == 2
		MenuCustomTime_cond=1
		SetCustomTime(akGuardRef)

	elseif iButton == 3
		MenuCustomTime_cond=0
		SetCustomTime(akGuardRef)

	elseif iButton == 4
		Int GuardShiftTimeMode
		if TempCustomTimeEnd > TempCustomTimeStarting
			GuardShiftTimeMode=1
		else
			GuardShiftTimeMode=2
		endif

		akGuardRef.SetValue(IMP.IMP_GuardShiftTimeMode, GuardShiftTimeMode)
		akGuardRef.SetValue(IMP.IMP_GuardShiftTimeStarting, TempCustomTimeStarting)
		akGuardRef.SetValue(IMP.IMP_GuardShiftTimeEnd, TempCustomTimeEnd)
		(akGuardRef as Actor).EvaluatePackage()		

	endif
EndFunction



;================================
; FUNCTIONS USED BY RELAX GUARD POSITIONER
;================================

Function GuardRelaxMarkerOnPlaced_PUBLIC(ObjectReference akWorkshopRef)
	if akWorkshopRef
		;*** increase marker count ***
		Int GuardMarkerCount=akWorkshopRef.GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
		akWorkshopRef.SetValue(IMP.IMP_WorkshopGuardRelaxCount, GuardMarkerCount+1)
		GuardCollection.EvaluateAll()
	endif
EndFunction


Function GuardRelaxMarkerOnDestroyed_PUBLIC(ObjectReference akWorkshopRef)
	if akWorkshopRef
		;*** decrease marker count ***
		Int GuardMarkerCount=akWorkshopRef.GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int
		akWorkshopRef.SetValue(IMP.IMP_WorkshopGuardRelaxCount, Math.Max(0,GuardMarkerCount-1))
		GuardCollection.EvaluateAll()
	endif
EndFunction
	


;====================
; FUNCTIONS USED BY PACKAGES
;====================

Function SetSandboxPackage_PUBLIC(Actor akActorRef)
	ObjectReference RelaxMarkerRef=akActorRef.GetLinkedRef(IMP.IMP_LinkGuardMarkerForced)

	if \
	RelaxMarkerRef == NONE || \
	RelaxMarkerRef.IsDisabled() || \
	RelaxMarkerRef.IsDeleted()
		RelaxMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_Guard_RelaxMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())
	endif

	akActorRef.SetLinkedRef(RelaxMarkerRef, IMP.IMP_LinkGuardMarker)
	GuardCollection.EvaluateAll()
EndFunction


Function UnsetSandboxPackage_PUBLIC(Actor akActorRef)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardMarker)
	
	;*** get random package ***
	if akActorRef.GetValue(IMP.IMP_GuardShiftRandom)==1
		Int GuardShiftTypeID=Utility.RandomInt(1, 2)
		akActorRef.SetValue(IMP.IMP_GuardShiftTypeID, GuardShiftTypeID)
	endif
	
	GuardCollection.EvaluateAll()
EndFunction



;====================================
; POWER ARMOR
;====================================

Message property IMP_GuardPowerarmorReplaceOwnerMESGb auto const mandatory
Message property IMP_GuardPowerarmorUnassignOwner00MESGb auto const mandatory
Message property IMP_GuardPowerarmorUnassignOwner01MESGb auto const mandatory

Function SetPowerArmorMarker(ObjectReference akGuardRef, ObjectReference akMarkerRef)
	if akGuardRef  &&  akMarkerRef
		akGuardRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkGuardPowerarmorMrk)
		akMarkerRef.SetActorRefOwner(akGuardRef as Actor)
		(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(akGuardRef as Actor)
	endif
EndFunction


Function UnsetPowerArmorMarker(ObjectReference akMarkerRef)
	if akMarkerRef
		Actor OwnerRef=akMarkerRef.GetActorRefOwner()
		OwnerRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPowerarmorMrk)
		akMarkerRef.SetActorRefOwner(NONE)
		(akMarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(NONE)
	endif
EndFunction

;=========

Function AssignGuardToPowerarmorMarker_PUBLIC(ObjectReference akGuardRef, ObjectReference akMarkerRef)
	if akGuardRef && akMarkerRef
		Actor OwnerRef=akMarkerRef.GetActorRefOwner()
		if OwnerRef == akGuardRef
			ShowPowerarmorMarkerMenu((akMarkerRef as IMPScriptMarker).GetPositionerRef())
		else
			ActorNameAlias.ForceRefTo(OwnerRef)
			Int iButton=IMP_GuardPowerarmorReplaceOwnerMESGb.Show()
			if iButton==1
				SetPowerArmorMarker(akGuardRef, akMarkerRef)
			endif
		endif
	endif
EndFunction

;---------

Function ShowPowerarmorMarkerMenu(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()

		Actor OwnerRef=MarkerRef.GetActorRefOwner()
		Message GuardPowerarmorUnassignOwner
		if OwnerRef
			ActorNameAlias.ForceRefTo(OwnerRef)
			GuardPowerarmorUnassignOwner=IMP_GuardPowerarmorUnassignOwner01MESGb
		else
			GuardPowerarmorUnassignOwner=IMP_GuardPowerarmorUnassignOwner00MESGb
		endif

		Int iButton=GuardPowerarmorUnassignOwner.Show()
		if iButton==1
			IMP.Pin.Pin_AddActorToCollection_PUBLIC(OwnerRef, akPositionerRef)
		elseif iButton==2
			UnsetPowerArmorMarker(MarkerRef)
		endif
	endif
EndFunction

Function ShowPowerarmorMarkerMenu_PUBLIC(ObjectReference akPositionerRef)
	ShowPowerarmorMarkerMenu(akPositionerRef)
EndFunction

;=========

Function PowerarmorMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		UnsetPowerArmorMarker(MarkerRef)
	endif
EndFunction

;=========

Float Function AddTimeValues(Float afValue1, Float afValue2)
	Float Result=afValue1+afValue2

	if Result >= 24
		Result=Result-24
	elseif Result < 0
		Result=24-Result
	endif

	return Result
EndFunction

;=========

Function GuardOnGetUp_PUBLIC(ObjectReference akGuardRef, ObjectReference akArmorRef)
	if akArmorRef.HasKeyword(IMP.FurnitureTypePowerArmor)
		akGuardRef.SetLinkedRef(akArmorRef, IMP.IMP_LinkGuardPowerarmor)
		akArmorRef.SetActorRefOwner(akGuardRef as Actor)
	endif
EndFunction

Function GuardOnSit_PUBLIC(ObjectReference akGuardRef, ObjectReference akArmorRef)
	if akArmorRef.HasKeyword(IMP.FurnitureTypePowerArmor)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPowerarmor)
		akArmorRef.SetActorRefOwner(NONE)
	endif
EndFunction

Function PlayerOnSit_PUBLIC(ObjectReference akArmorRef)
	if akArmorRef.HasKeyword(IMP.FurnitureTypePowerArmor)
		ObjectReference OwnerRef=akArmorRef.GetRefsLinkedToMe(IMP.IMP_LinkGuardPowerarmor)[0]
		if OwnerRef
			UnsetPowerarmorStuff(OwnerRef)
		endif
	endif
EndFunction

;=========

Function UnsetPowerarmorStuff(ObjectReference akGuardRef)
	if akGuardRef
		ObjectReference ArmorRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardPowerarmor)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPowerarmor)
		if ArmorRef
			ArmorRef.SetActorRefOwner(NONE)
		endif
		
		ObjectReference MarkerRef=akGuardRef.GetLinkedRef(IMP.IMP_LinkGuardPowerarmorMrk)
		akGuardRef.SetLinkedRef(NONE, IMP.IMP_LinkGuardPowerarmorMrk)
		MarkerRef.SetActorRefOwner(NONE)
		(MarkerRef as IMPScriptMarker).GetPositionerRef().SetActorRefOwner(NONE)
	endif
EndFunction