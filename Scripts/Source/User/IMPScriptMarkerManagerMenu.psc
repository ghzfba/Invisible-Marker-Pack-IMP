Scriptname IMPScriptMarkerManagerMenu extends Quest Conditional

;= added in IMP v.3.11 ===
Message property IMP_SetSafetyValueMenuEntryMESGb auto
Message property IMP_SetSafetyValueMenuEntryNoneMESGb auto
;=========================

ReferenceAlias property OwnershipPublicAlias auto const mandatory
ReferenceAlias property MarkerNameAlias auto const mandatory
ReferenceAlias property MarkerOwnershipAlias auto const mandatory
LocationAlias property Slot01LocationAlias auto const mandatory
LocationAlias property Slot02LocationAlias auto const mandatory
LocationAlias property Slot03LocationAlias auto const mandatory
LocationAlias property Slot04LocationAlias auto const mandatory
LocationAlias property Slot05LocationAlias auto const mandatory

Formlist property IMP_MarkerSelectorList auto const mandatory
Formlist property IMP_MarkerManagerMenu_SettingButtons auto const mandatory
Int[] property SettingButtons_DirectXScanCode auto const mandatory

IMPScriptMain IMP
Actor PlayerRef

Int HasMarkerOwner Conditional
Bool bIsMarkerSandboxWork Conditional


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	PlayerRef=Game.GetPlayer()
	PinnedMarkerRefs=new Objectreference[0]
	SandboxMarkerRefs=new Objectreference[0]
EndEvent


;=========

Message property IMP_MarkerManagerMenu00MESGb auto const mandatory
Message property IMP_MarkerManagerMenu01MESGb auto const mandatory
Message property IMP_MarkerManagerMenuAvailable_MarkerMESGn auto const mandatory
Message property IMP_MarkerManagerMenuAvailable_SettlerMESGn auto const mandatory
Message property IMP_MarkerManagerMenuAvailable_SafetyMESGn auto const mandatory

Function HandleSelector_PUBLIC(ObjectReference akSelectorRef)
	if akSelectorRef
		ObjectReference ClosestPositionerRef=Game.FindClosestReferenceOfAnyTypeInList(IMP_MarkerSelectorList, akSelectorRef.GetPositionX(), akSelectorRef.GetPositionY(), akSelectorRef.GetPositionZ(), 64)
		Actor ClosestActorRef=Game.FindClosestActorFromRef(akSelectorRef, 64)

		if ClosestActorRef  &&  ClosestPositionerRef
			Int iButton=IMP_MarkerManagerMenu01MESGb.Show()
			if iButton == 1
				ShowMarkerManagerMenu(ClosestPositionerRef)
			elseif iButton == 2
				ShowSettlerMenu(ClosestActorRef)
			endif
		elseif ClosestPositionerRef
			ShowMarkerManagerMenu(ClosestPositionerRef)
		elseif ClosestActorRef
			ShowSettlerMenu(ClosestActorRef)
		endif

		akSelectorRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
		akSelectorRef.DisableNoWait(True)
		akSelectorRef.Delete()
	endif
EndFunction


Function HandleF4SEButton_PUBLIC(ObjectReference akSelectedObjectRef)
	if akSelectedObjectRef as Actor
		ShowSettlerMenu(akSelectedObjectRef)
	else	
		ShowMarkerManagerMenu(akSelectedObjectRef)
	endif
EndFunction


;=========

Function ShowMarkerManagerMenu(ObjectReference akPositionerRef)
	if akPositionerRef as IMPScriptPositioner
		IMP.Pin.Pin_ResetCollection()
		

		if akPositionerRef.HasKeyword(IMP.IMP_IsAssemblyPointPositioner)
			IMP.AssemblyPoint.ShowAssemblyPointMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsRestrictedSandboxPositioner)
			IMP.RestrictedSandbox.ShowRestrictedSandboxMarkerMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner)
			IMP.CreatureManager.ShowRestrictedSandboxCreatureMarkerMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsProvisionerPositioner)
			IMP.ProvisionerManager.ShowProvisionerMarkerMenu_PUBLIC(akPositionerRef, (akPositionerRef as IMPScriptPositioner).GetMarkerRef().GetLinkedRef(IMP.WorkshopItemKeyword))


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsPowerarmorPositioner)
			IMP.GuardManager.ShowPowerarmorMarkerMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardPatrolPositioner)
			IMP.GuardPatrol.ShowGuardPatrolMarkerMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardScoutPositioner)
			IMP.GuardScout.ShowMenu_SquadManager_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsCaravanLeaderPositioner)  ||  akPositionerRef.HasKeyword(IMP.IMP_IsCaravanGuardPositioner)  ||  akPositionerRef.HasKeyword(IMP.IMP_IsCaravanBrahminPositioner)
			IMP.CaravanManager.ShowCaravanSandboxActorMarkerMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardPositioner)
			ShowSafetyValueMenu(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsBattlePositionPositioner)
			IMP.AssemblyPoint.ShowBattlePositionMenu_PUBLIC(akPositionerRef)


		elseif akPositionerRef.HasKeyword(IMP.IMP_IsFXPositioner)
			SetMarkerPropsTimerINIT(akPositionerRef)


		else
			;*** Is marker sandbox work or relax type? ***
			Bool bIsMarkerSandboxRelax=akPositionerRef.HasKeyword(IMP.IMP_IsSandboxRelaxPositioner)			
			bIsMarkerSandboxWork=akPositionerRef.HasKeyword(IMP.IMP_IsSandboxWorkPositioner)
			Bool bIsMarkerSandboxMerchant=akPositionerRef.HasKeyword(IMP.IMP_IsSandboxMerchantPositioner)		
			Bool bIsMarkerCreature=akPositionerRef.HasKeyword(IMP.IMP_IsCreaturePositioner)		

			if bIsMarkerSandboxRelax  ||  bIsMarkerSandboxWork  ||  bIsMarkerSandboxMerchant  ||  bIsMarkerCreature

				;*** Has owner? ***
				ObjectReference OwnerRef
				if akPositionerRef.HasKeyword(IMP.WorkshopWorkObject)
					OwnerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef().GetActorRefOwner()
					if OwnerRef
						HasMarkerOwner=1
					else
						HasMarkerOwner=0
					endif
				else
					HasMarkerOwner=-1
				endif


				if bIsMarkerSandboxRelax  ||  bIsMarkerSandboxMerchant  ||  bIsMarkerCreature
					ShowOwnershipEntry(akPositionerRef, OwnerRef)
				else
					if HasMarkerOwner == -1  &&  bIsMarkerSandboxWork==False
						;Do nothing
					else
						MarkerNameAlias.ForceRefTo(akPositionerRef)

						Int iButton=IMP_MarkerManagerMenu00MESGb.Show()
						if iButton==1
							ShowOwnershipEntry(akPositionerRef, OwnerRef)

						elseif iButton==2
							ShowBonusItemMenuEntry(akPositionerRef)

						endif
					endif
				endif
			endif

		endif

	elseif akPositionerRef.HasKeyword(IMP.ActorTypeTurret)==False  &&  akPositionerRef.GetLinkedRef(IMP.WorkshopItemKeyword)  &&  akPositionerRef.GetValue(IMP.Safety)
		SetSafetyValueINIT(akPositionerRef)
		
	endif
EndFunction


Function CanMarkerManagerMenuBeShown_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		if IMP.IMP_MarkerManagerMenu_ShowNotification.GetValue() == 1
			Bool bShowMenu
			ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
			Message MarkerManagerMenuAvailable

			if MarkerRef 
				if akPositionerRef.HasKeyword(IMP.IMP_IsRestrictedSandboxPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsProvisionerPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsPowerarmorPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardPatrolPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardScoutPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsCaravanLeaderPositioner)  ||  akPositionerRef.HasKeyword(IMP.IMP_IsCaravanGuardPositioner)  ||  akPositionerRef.HasKeyword(IMP.IMP_IsCaravanBrahminPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsAssemblyPointPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsBattlePositionPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsFXPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxRelaxPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxWorkPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxMerchantPositioner)
					bShowMenu=True
				elseif akPositionerRef.HasKeyword(IMP.IMP_IsCreaturePositioner)
					bShowMenu=True
				endif

				MarkerManagerMenuAvailable=IMP_MarkerManagerMenuAvailable_MarkerMESGn

			elseif akPositionerRef.HasKeyword(IMP.ActorTypeTurret)==False  &&  akPositionerRef.GetLinkedRef(IMP.WorkshopItemKeyword)  &&  akPositionerRef.GetValue(IMP.Safety)
				bShowMenu=True
				MarkerManagerMenuAvailable=IMP_MarkerManagerMenuAvailable_SafetyMESGn
			endif

			if bShowMenu
				Int CurrentDirectXScanCode=IMP.IMP_KeyScanCodeF4SE.GetValue() as Int
				Int Index=SettingButtons_DirectXScanCode.Find(CurrentDirectXScanCode)
				if Index >= 0
					Slot01LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_SettingButtons.GetAt(Index) as Location)
					MarkerManagerMenuAvailable.Show()
				endif
			endif
		endif
	endif
EndFunction


Function CanSettlerManagerMenuBeShown_PUBLIC(ObjectReference akSettlerRef)
	if akSettlerRef && IMP.IMP_MarkerManagerMenu_ShowNotification.GetValue() == 1
		if akSettlerRef.HasKeyword(IMP.ActorTypeTurret)==False  &&  (akSettlerRef as Actor).IsPlayerTeammate()==False
			Int CurrentDirectXScanCode=IMP.IMP_KeyScanCodeF4SE.GetValue() as Int
			Int Index=SettingButtons_DirectXScanCode.Find(CurrentDirectXScanCode)
			if Index >= 0
				Slot01LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_SettingButtons.GetAt(Index) as Location)
				IMP_MarkerManagerMenuAvailable_SettlerMESGn.Show()
			endif
		endif
	endif
EndFunction


;=========

Message property IMP_MarkerManagerMenu_Ownership_00MESGb auto const mandatory

Function ShowOwnershipEntry(ObjectReference akPositionerRef, ObjectReference akOwnerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
		if MarkerRef
			MarkerNameAlias.ForceRefTo(akPositionerRef)
			HasMarkerOwner=((akOwnerRef as Bool) as Int)
			if HasMarkerOwner == 0
				MarkerOwnershipAlias.ForceRefTo(OwnershipPublicAlias.GetReference())
			endif
			MarkerOwnershipAlias.ForceRefTo(akOwnerRef)

			Int iButton=IMP_MarkerManagerMenu_Ownership_00MESGb.Show()
			if iButton == 1
				IMP.Pin.Pin_AddActorToCollection_PUBLIC(akOwnerRef, akPositionerRef)
			elseif iButton == 2
				akPositionerRef.SetActorRefOwner(NONE)
				MarkerRef.SetActorRefOwner(NONE)
				(MarkerRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
				
				IMP.Pin.Pin_RemoveActorFromCollection_PUBLIC(akOwnerRef)
			endif
		endif
	endif
EndFunction


;=========

Message property IMP_MarkerManagerMenu_BonusItem_00MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_BonusItem_01MacroCatMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_BonusItem_02CategoriesMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_BonusItem_03ComponentsMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_BonusItem_04PlantsAMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_BonusItem_05PlantsBMESGb auto const mandatory

Int BonusItemID Conditional

Function ShowBonusItemMenuEntry(ObjectReference akPositionerRef)
	IMPScriptMarkerSandboxWorkType MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef() as IMPScriptMarkerSandboxWorkType 
	if MarkerRef
		BonusItemID=MarkerRef.GetBonusItemID_PUBLIC()
		Slot01LocationAlias.ForceLocationTo(IMP.IMP_BonusItemNameList.GetAt(BonusItemID) as Location)

		Int iButton=IMP_MarkerManagerMenu_BonusItem_00MESGb.Show()
		if iButton > 0
			ShowBonusItemMenuSub(akPositionerRef, iButton)
		endif
	endif
EndFunction

Function ShowBonusItemMenuEntry_PUBLIC(ObjectReference akPositionerRef)
	ShowBonusItemMenuEntry(akPositionerRef)
EndFunction


Function ShowBonusItemMenuSub(ObjectReference akPositionerRef, Int BonusItemMenuID)
	IMPScriptMarkerSandboxWorkType MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef() as IMPScriptMarkerSandboxWorkType 
	if MarkerRef
		Message IMP_MarkerManagerMenu_BonusItemMESGb
		Int OffsetValue
		Int NoneButton
		if BonusItemMenuID == 1
			IMP_MarkerManagerMenu_BonusItemMESGb=IMP_MarkerManagerMenu_BonusItem_01MacroCatMESGb
			OffsetValue=0
			NoneButton=4
		elseif BonusItemMenuID == 2
			IMP_MarkerManagerMenu_BonusItemMESGb=IMP_MarkerManagerMenu_BonusItem_02CategoriesMESGb
			OffsetValue=3
			NoneButton=8
		elseif BonusItemMenuID == 3
			IMP_MarkerManagerMenu_BonusItemMESGb=IMP_MarkerManagerMenu_BonusItem_03ComponentsMESGb
			OffsetValue=10
			NoneButton=10
		elseif BonusItemMenuID == 4
			IMP_MarkerManagerMenu_BonusItemMESGb=IMP_MarkerManagerMenu_BonusItem_04PlantsAMESGb
			OffsetValue=19
			NoneButton=18
		elseif BonusItemMenuID == 5
			IMP_MarkerManagerMenu_BonusItemMESGb=IMP_MarkerManagerMenu_BonusItem_05PlantsBMESGb
			OffsetValue=36
			NoneButton=14
		endif

		Int iButton=IMP_MarkerManagerMenu_BonusItemMESGb.Show()
		if iButton == 0
			ShowBonusItemMenuEntry(akPositionerRef)
		elseif iButton == NoneButton
			MarkerRef.SetBonusItemID_PUBLIC(0)
		elseif iButton > 0
			MarkerRef.SetBonusItemID_PUBLIC(iButton+OffsetValue)
		endif			
	endif
EndFunction



;=========

Message property IMP_SetSafetyValueMenuAMESGb auto const mandatory
Message property IMP_SetSafetyValueMenuBMESGb auto const mandatory
Bool bSafetyValueEdited Conditional
Int NewSafetyValue
Int BaseSafetyValue

Function ShowSafetyValueMenu(ObjectReference akObjectRef)
	IMPScriptPositioner PositionerRef=akObjectRef as IMPScriptPositioner
	if PositionerRef
		if IMP.IMP_SafetyObjectExclusions.Find(akObjectRef.GetBaseObject()) == -1

			Message SetSafetyValueMenuEntry
			Actor OwnerRef=akObjectRef.GetActorRefOwner()
			if OwnerRef
				SetSafetyValueMenuEntry=IMP_SetSafetyValueMenuEntryMESGb
				MarkerNameAlias.ForceRefTo(PositionerRef)
				MarkerOwnershipAlias.ForceRefTo(OwnerRef)
			else
				SetSafetyValueMenuEntry=IMP_SetSafetyValueMenuEntryNoneMESGb
				MarkerNameAlias.ForceRefTo(PositionerRef)
			endif		
		
		
			Int iButton=SetSafetyValueMenuEntry.Show()
			if iButton==1
				SetSafetyValueINIT(PositionerRef.GetMarkerRef())
			elseif iButton==2
				IMP.Pin.Pin_AddActorToCollection_PUBLIC(OwnerRef, PositionerRef)			
			endif
		endif
	else
		SetSafetyValueINIT(akObjectRef)
	endif
EndFunction

Function SetSafetyValueINIT(ObjectReference akObjectRef)
	if akObjectRef
		Int StartingSafetyValue=akObjectRef.GetValue(IMP.Safety) as Int
		akObjectRef.SetValue(IMP.Safety, 0)
		BaseSafetyValue=akObjectRef.GetValue(IMP.Safety) as Int
		akObjectRef.SetValue(IMP.Safety, StartingSafetyValue - BaseSafetyValue)

		NewSafetyValue=StartingSafetyValue
		SetSafetyValue(akObjectRef)
	endif
EndFunction

Function SetSafetyValue(ObjectReference akObjectRef)
	if akObjectRef
		Int CurrentSafetyValue=akObjectRef.GetValue(IMP.Safety) as Int

		Bool bOpenMenu
		
		Message SafetyValueMenu
		ObjectReference PositionerRef=(akObjectRef as IMPScriptMarker).GetPositionerRef()
		if PositionerRef
			MarkerNameAlias.ForceRefTo(PositionerRef)
			SafetyValueMenu=IMP_SetSafetyValueMenuAMESGb
		else
			MarkerNameAlias.ForceRefTo(akObjectRef)
			SafetyValueMenu=IMP_SetSafetyValueMenuBMESGb
		endif


		Int iButton=SafetyValueMenu.Show(CurrentSafetyValue, NewSafetyValue)
		if iButton == 0
			NewSafetyValue+=1
			if NewSafetyValue > 6
				NewSafetyValue=1
			endif
			bOpenMenu=True

		elseif iButton == 1
			NewSafetyValue-=1
			if NewSafetyValue < 1
				NewSafetyValue=6
			endif
			bOpenMenu=True
			
		elseif iButton == 2
			akObjectRef.SetValue(IMP.Safety, NewSafetyValue - BaseSafetyValue)
			PositionerRef.SetValue(IMP.Safety, NewSafetyValue - BaseSafetyValue)
			(akObjectRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript).RecalculateWorkshopResources()
			BaseSafetyValue=0
			NewSafetyValue=0
			bSafetyValueEdited=False
			
		elseif iButton == 3
			BaseSafetyValue=0
			NewSafetyValue=0
			bSafetyValueEdited=False

		endif


		if bOpenMenu
			if CurrentSafetyValue != NewSafetyValue
				bSafetyValueEdited=True
			else
				bSafetyValueEdited=False
			endif

			SetSafetyValue(akObjectRef)
		endif
	endif
EndFunction


;=========


Message property IMP_MarkerPropsTimerMESGb auto const mandatory
Int MarkerPropsTimerMesgStage Conditional
Bool bMarkerPropsTimerValueEdited Conditional
Int CurrentStartTime
Int CurrentEndTime
Int NewStartTime
Int NewEndTime

Function SetMarkerPropsTimerINIT(ObjectReference akPositionerRef)
	if akPositionerRef
		IMPScriptMarkerProps MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef() as IMPScriptMarkerProps
		if MarkerRef
			MarkerPropsTimerMesgStage=0
			bMarkerPropsTimerValueEdited=False

			MarkerNameAlias.ForceRefTo(akPositionerRef)
			CurrentStartTime=MarkerRef.GetValue(IMP.IMP_MarkerPropsTimerStart) as Int
			CurrentEndTime=MarkerRef.GetValue(IMP.IMP_MarkerPropsTimerEnd) as Int
			NewStartTime=CurrentStartTime
			NewEndTime=CurrentEndTime

			SetMarkerPropsTimer(MarkerRef)
		endif
	endif
EndFunction


Function SetMarkerPropsTimer(IMPScriptMarkerProps akMarkerRef)
	if akMarkerRef
		Bool bOpenMenu=True


		if CurrentStartTime!=NewStartTime  ||  CurrentEndTime!=NewEndTime
			bMarkerPropsTimerValueEdited=True
		else
			bMarkerPropsTimerValueEdited=False
		endif


		Int iButton=IMP_MarkerPropsTimerMESGb.Show(CurrentStartTime, CurrentEndTime, NewStartTime, NewEndTime)
		if iButton == 0
			if MarkerPropsTimerMesgStage==0
				NewStartTime+=1
				if NewStartTime > 23
					NewStartTime=0
				endif
			elseif MarkerPropsTimerMesgStage==1
				NewEndTime+=1
				if NewEndTime > 23
					NewEndTime=0
				endif
			endif		
		

		elseif iButton == 1
			if MarkerPropsTimerMesgStage==0
				NewStartTime-=1
				if NewStartTime < 0
					NewStartTime=23
				endif
			elseif MarkerPropsTimerMesgStage==1
				NewEndTime-=1
				if NewEndTime < 0
					NewEndTime=23
				endif
			endif
			

		elseif iButton == 2
			MarkerPropsTimerMesgStage=1


		elseif iButton == 3
			MarkerPropsTimerMesgStage=0


		elseif iButton == 4
			bOpenMenu=False

			akMarkerRef.SetValue(IMP.IMP_MarkerPropsTimerStart, NewStartTime)
			akMarkerRef.SetValue(IMP.IMP_MarkerPropsTimerEnd, NewEndTime)

			if NewStartTime == NewEndTime
				akMarkerRef.SetPropsConstant_PUBLIC()
			else
				akMarkerRef.SetPropsTimed_PUBLIC()
			endif


		elseif iButton == 5
			bOpenMenu=False


		endif


		if bOpenMenu
			SetMarkerPropsTimer(akMarkerRef)
		endif

	endif
EndFunction



;=========
; SETTLER MENU
;=========
Message property IMP_MarkerManagerMenu_Settler_00MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_01MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_01FMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_01GMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_02MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_03MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_03GMESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_04MESGb auto const mandatory
Message property IMP_MarkerManagerMenu_Settler_05MESGb auto const mandatory

Bool bIsWorker_cond Conditional
Bool bIsGuard_cond Conditional
Bool bIsLinkedToProvisionerMarker_cond Conditional
Bool bIsLinkedToPowerArmor_cond Conditional
Bool bIsLinkedToRestrictedSandbox_cond Conditional
Bool bIsReservist_cond Conditional
Bool bCanGuardRelax_cond Conditional
Bool bIsChild_cond Conditional
Bool bCantBeReservist_cond Conditional
Bool bShowSeparator_cond Conditional
Int IsLinkedToAssemblyPoint_cond Conditional
Int HasWorkshopSafehouse_cond Conditional
Int HasWorkshopGuardrelax_cond Conditional
Int SettlerMenuSandboxMarkerCount_cond Conditional
Int SettlerMenuOwnedPositionerCount_cond Conditional
Int IsGuardPatrolman_cond Conditional
	;1=waypoint
	;2=free-roam
Int ActorType_cond Conditional
	;1=Settler
	;2=Provisioner
	;3=Settlement animal
	;4=Other actor
Int CaravanActorType_cond Conditional
	;1=Leader
	;2=Guard
	;3=Brahmin
	
ObjectReference MenuSettlerRef
ObjectReference WorkObjectRef
ObjectReference SafehouseRef
ObjectReference ProvisionerMarkerRef
ObjectReference RestrictedSandboxMarkerRef
ObjectReference GuardMarkerRef
ObjectReference BedRef
ObjectReference CaravanLeaderMarkerRef
ObjectReference CaravanGuardMarkerRef
ObjectReference CaravanBrahminMarkerRef
ObjectReference[] SandboxMarkerRefs
ObjectReference[] PinnedMarkerRefs
ObjectReference WorkshopRef
Location Home
Location Destination

Int Level
Int StrengthAV
Int PerceptionAV
Int EnduranceAV
Int CharismaAV
Int IntelligenceAV
Int AgilityAV
Int LuckAV

Message MarkerManagerMenuSettler

Formlist property IMP_MarkerManagerMenu_Options auto const mandatory
Formlist property IMP_MarkerManagerMenu_Reservists auto const mandatory


Function ShowSettlerMenu(ObjectReference akSettlerRef)
	if akSettlerRef
		if akSettlerRef.HasKeyword(IMP.ActorTypeTurret)==False  &&  (akSettlerRef as Actor).IsPlayerTeammate()==False
	
			IMP.Pin.Pin_ResetCollection()
		
			MenuSettlerRef=akSettlerRef

			(akSettlerRef as Actor).SetCanDoCommand(False)

			WorkshopRef=akSettlerRef.GetLinkedRef(IMP.WorkshopItemKeyword)
			bCantBeReservist_cond=False



			;*** Get actor type ***
			if WorkshopRef
				Home=WorkshopRef.GetCurrentLocation()
				Destination=akSettlerRef.GetLinkedRef(IMP.WorkshopLinkCaravanEnd).GetCurrentLocation()
				if (akSettlerRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
					;*** is companion ***
					ActorType_cond=1
				elseif Destination
					;*** is provisioner ***
					ActorType_cond=2
				elseif akSettlerRef.HasKeyword(IMP.ActorTypeNPC) == False  &&  akSettlerRef.HasKeyword(IMP.ActorTypeRobot) == False
					;*** is animal ***
					ActorType_cond=3
				else
					;*** is settler ***
					ActorType_cond=1
				endif
			elseif (akSettlerRef as Actor).IsInFaction(IMP.CaravanFaction) == True
				;*** is caravan actor ***
				WorkshopRef=IMP.WorkshopParent.GetWorkshopFromLocation(akSettlerRef.GetCurrentLocation())
				ActorType_cond=5		
			else
				;*** is other actor ***
				ActorType_cond=4
			endif
			
			
			;*** Is child? ***
			bIsChild_cond=(akSettlerRef as Actor).IsChild()


			;*** get owned markers ***
			if ActorType_cond != 4
				GetOwnedMarkers(akSettlerRef)
			endif
			

			;*** Has workshop a guard relax marker? ***
			HasWorkshopGuardrelax_cond=WorkshopRef.GetValue(IMP.IMP_WorkshopGuardRelaxCount) as Int

			ObjectReference GuardRelaxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
			if GuardRelaxMarkerRef == NONE
				GuardRelaxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardMarkerForced)
			endif
			if GuardRelaxMarkerRef
				PinnedMarkerRefs.Add(GuardRelaxMarkerRef)
			endif
			
			
			
			;*** Has workshop a safehouse? ***
			HasWorkshopSafehouse_cond=WorkshopRef.GetValue(IMP.IMP_WorkshopSafehouseCount) as Int

			SafehouseRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarker)
			if SafehouseRef == NONE
				SafehouseRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
			endif
			if SafehouseRef as IMPScriptMarker
				PinnedMarkerRefs.Add(SafehouseRef)
			endif

			if SafehouseRef.HasKeyword(IMP.IMP_IsBattlePositionMarker)
				IsLinkedToAssemblyPoint_cond=2
			elseif SafehouseRef
				IsLinkedToAssemblyPoint_cond=1
			else
				IsLinkedToAssemblyPoint_cond=0
			endif
			


			;*** Is linked to a provisioner marker? ***
			ProvisionerMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker)
			bIsLinkedToProvisionerMarker_cond=ProvisionerMarkerRef as Bool
			if ProvisionerMarkerRef as IMPScriptMarker
				PinnedMarkerRefs.Add(ProvisionerMarkerRef)
			endif		
			
			
			
			;*** Is linked to a power armor? ***
			bIsLinkedToPowerArmor_cond=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardPowerarmorMrk) as Bool



			;*** Is reservist? ***
			bIsReservist_cond=akSettlerRef.HasKeyword(IMP.IMP_IsReservist)



			;*** Is settlement worker? ***
			bIsWorker_cond=(akSettlerRef as WorkshopNPCScript).bIsWorker
			if bIsWorker_cond == False
				;*** if is provisioner then is worker ***
				if ActorType_cond == 2
					bIsWorker_cond=True
				endif
			endif



			;*** Is settlement farmer? ***
			Bool bIsFarmer
			if (WorkObjectRef.GetBaseObject() as Flora) &&  WorkObjectRef.GetValue(IMP.Food) > 0
				bIsFarmer=True
			else
				bIsFarmer=False
			endif
			


			;*** Is settlement guard? ***
			bIsGuard_cond=(akSettlerRef as WorkshopNPCScript).bIsGuard
			
			
			
			;*** Can guard relax? ***
			bCanGuardRelax_cond=akSettlerRef.HasKeyword(IMP.ActorTypeNPC)



			;*** which patrolman? ***
			ObjectReference PatrolmanRef
			Bool bIsGuardFollower
			
			if akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
				PatrolmanRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderPatrol)
				bIsGuardFollower=True		
			elseif akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
				PatrolmanRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardFollowerLeaderScout)
				bIsGuardFollower=True		
			else
				PatrolmanRef=akSettlerRef
				bIsGuardFollower=False		
			endif
							
			if PatrolmanRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolController)	
				GuardMarkerRef=PatrolmanRef.GetLinkedRef(IMP.IMP_LinkGuardPatrolController)	
				IsGuardPatrolman_cond=1
			elseif PatrolmanRef.GetLinkedRef(IMP.IMP_LinkScoutMarker)
				GuardMarkerRef=PatrolmanRef.GetLinkedRef(IMP.IMP_LinkScoutMarker)
				IsGuardPatrolman_cond=2
			else
				GuardMarkerRef=NONE
				IsGuardPatrolman_cond=0
			endif



			;*** Is linked to a restricted sanbox? ***
			RestrictedSandboxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			bIsLinkedToRestrictedSandbox_cond =	(RestrictedSandboxMarkerRef as Bool)  && \
												(akSettlerRef as Actor).IsInFaction(IMP.WorkshopVendorFactionBar)==False && \
												(akSettlerRef as Actor).IsInFaction(IMP.WorkshopCaravanFaction)==False && \
												bIsGuard_cond==False
			if RestrictedSandboxMarkerRef as IMPScriptMarker
				PinnedMarkerRefs.Add(RestrictedSandboxMarkerRef)
			endif
			
			
			
			;*** which caravan actor? ***
			if ActorType_cond == 5
				if akSettlerRef.HasKeyword(IMP.IMP_IsCaravanLeader)  &&  CaravanLeaderMarkerRef
					CaravanActorType_cond=1
				elseif akSettlerRef.HasKeyword(IMP.IMP_IsCaravanGuard)  &&  CaravanGuardMarkerRef
					CaravanActorType_cond=2
				elseif akSettlerRef.HasKeyword(IMP.IMP_IsCaravanBrahmin)  && CaravanBrahminMarkerRef
					CaravanActorType_cond=3
				else
					CaravanActorType_cond=0
				endif
			else			
				CaravanActorType_cond=0
			endif



			;*** get stats ***
			Level=(akSettlerRef as Actor).GetLevel()
			StrengthAV=akSettlerRef.GetValue(Game.GetStrengthAV()) as Int
			PerceptionAV=akSettlerRef.GetValue(Game.GetPerceptionAV()) as Int
			EnduranceAV=akSettlerRef.GetValue(Game.GetEnduranceAV()) as Int
			CharismaAV=akSettlerRef.GetValue(Game.GetCharismaAV()) as Int
			IntelligenceAV=akSettlerRef.GetValue(Game.GetIntelligenceAV()) as Int
			AgilityAV=akSettlerRef.GetValue(Game.GetAgilityAV()) as Int
			LuckAV=akSettlerRef.GetValue(Game.GetLuckAV()) as Int



			;*** set aliases ***
			MarkerOwnershipAlias.ForceRefTo(akSettlerRef)

			Slot01LocationAlias.ForceLocationTo(Home)

			if BedRef == NONE
				Slot02LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Options.GetAt(0) as Location)
			else
				Slot02LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Options.GetAt(1) as Location)
			endif

			if WorkObjectRef
				MarkerNameAlias.ForceRefTo(WorkObjectRef)
			else
				MarkerNameAlias.ForceRefTo(NONE)
			endif

			if IsLinkedToAssemblyPoint_cond == 2
				Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(1) as Location)
			elseif bIsGuard_cond
				bCantBeReservist_cond=True
				Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(2) as Location)
			elseif bIsReservist_cond
				Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(3) as Location)
			elseif (akSettlerRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				bCantBeReservist_cond=True
				Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(4) as Location)
			elseif WorkshopRef
				if HasWorkshopSafehouse_cond > 0
					Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(0) as Location)
				else
					Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(4) as Location)
				endif
			else
				bCantBeReservist_cond=True
				Slot03LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_Reservists.GetAt(4) as Location)
			endif

			if ActorType_cond == 2
				Slot04LocationAlias.ForceLocationTo(Home)
				Slot05LocationAlias.ForceLocationTo(Destination)
			endif



			;*** show separator? ***
			bShowSeparator_cond=False
			if SettlerMenuOwnedPositionerCount_cond > 0 ;= "Pin owned markers"
				bShowSeparator_cond=True
			elseif SettlerMenuSandboxMarkerCount_cond > 0 ;= "Show sandbox markers"
				bShowSeparator_cond=True
			elseif HasWorkshopSafehouse_cond > 0  &&  IsLinkedToAssemblyPoint_cond==1  &&  bIsGuard_cond==False  &&  bCantBeReservist_cond==False ;= "Safehouse settings"
				bShowSeparator_cond=True
			elseif IsLinkedToAssemblyPoint_cond==2 ;= "Battle position settings"
				bShowSeparator_cond=True
			elseif bIsLinkedToRestrictedSandbox_cond ;= "Restricted sandbox marker"
				bShowSeparator_cond=True			
			elseif bIsLinkedToProvisionerMarker_cond==1 ;= "Provisioner settings"
				bShowSeparator_cond=True
			elseif HasWorkshopGuardrelax_cond > 0  &&  bIsGuard_cond==True ;= "Rest time settings"
				bShowSeparator_cond=True
			elseif bIsLinkedToPowerArmor_cond  &&  bIsGuard_cond==True ;= "Powerarmor settings"
				bShowSeparator_cond=True
			elseif bIsWorker_cond  &&  IsGuardPatrolman_cond>0
				bShowSeparator_cond=True
			elseif ActorType_cond==3  &&  bIsGuardFollower  &&  IsGuardPatrolman_cond>0
				bShowSeparator_cond=True
			endif



			;*** chose menu ***
			if ActorType_cond == 1
				if bIsWorker_cond == False
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_00MESGb
				elseif bIsFarmer
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_01FMESGb
				elseif bIsGuard_cond
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_01GMESGb
				else
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_01MESGb
				endif
			elseif ActorType_cond == 2
				MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_02MESGb
			elseif ActorType_cond == 3
				if bIsGuardFollower == False
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_03MESGb
				else
					MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_03GMESGb
				endif
			elseif ActorType_cond == 4
				MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_04MESGb
			elseif ActorType_cond == 5
				MarkerManagerMenuSettler=IMP_MarkerManagerMenu_Settler_05MESGb
			endif



			Int iButton=MarkerManagerMenuSettler.Show(Level, StrengthAV, PerceptionAV, EnduranceAV, CharismaAV, IntelligenceAV, AgilityAV, LuckAV)
			if iButton == 1
				(akSettlerRef as Actor).OpenInventory(True)

			elseif iButton == 2
				;*** set as reservist ***
				akSettlerRef.AddKeyword(IMP.IMP_IsReservist)
				akSettlerRef.SetValue(IMP.IMP_AssemblyPointReached, 0)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarker)
				akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerAssemblypointMarkerForced)	
			
			elseif iButton == 3
				;*** unset as reservist ***
				akSettlerRef.RemoveKeyword(IMP.IMP_IsReservist)

			elseif iButton == 4
				if akSettlerRef.HasKeyword(IMP.IMP_IsWorkshopCreature)==False
					IMP.WorkshopParent.UnassignActor(akSettlerRef as WorkshopNPCScript)
				elseif IsGuardPatrolman_cond == 1
					IMP.GuardPatrol.RemoveFollowerCreature(akSettlerRef)
				elseif IsGuardPatrolman_cond == 2
					IMP.GuardScout.RemoveFollowerCreature(akSettlerRef)
				endif

			elseif iButton == 5
				;Do nothing

			elseif iButton == 6
				IMP.Pin.Pin_AddMarkerArrayToCollection_PUBLIC(PinnedMarkerRefs, akSettlerRef)

			elseif iButton == 7
				ShowSingleMarkerMenu(0)

			elseif iButton == 8
				IMP.AssemblyPoint.AssignSettlerToAssemblyPointMarker_PUBLIC(akSettlerRef , SafehouseRef)

			elseif iButton == 9
				IMP.AssemblyPoint.ShowBattlePositionMenu_PUBLIC((SafehouseRef as IMPScriptMarker).GetPositionerRef())

			elseif iButton == 10
				IMP.RestrictedSandbox.AssignSandboxerToMarker_PUBLIC(akSettlerRef, RestrictedSandboxMarkerRef)

			elseif iButton == 11
				IMP.ProvisionerManager.AssignProvisionerToMarker_PUBLIC(akSettlerRef, ProvisionerMarkerRef)

			elseif iButton == 12
				IMP.GuardManager.ShowGuardShiftMainMenu_PUBLIC(akSettlerRef)

			elseif iButton == 13
				IMP.GuardManager.ShowPowerarmorMarkerMenu_PUBLIC(ProvisionerMarkerRef)

			elseif iButton == 14
				if IsGuardPatrolman_cond == 1
					if bIsGuardFollower==False		
						IMP.GuardPatrol.ShowMenu_SquadManager(GuardMarkerRef)
					else
						IMP.GuardPatrol.ShowMenu_UnitManager(akSettlerRef, GuardMarkerRef)
					endif
				elseif IsGuardPatrolman_cond == 2
					if bIsGuardFollower==False		
						IMP.GuardScout.ShowMenu_SquadManager(GuardMarkerRef)
					else
						IMP.GuardScout.ShowMenu_UnitManager(akSettlerRef, GuardMarkerRef)
					endif
				endif
				
			elseif iButton == 15
				IMP.CaravanManager.ShowCaravanSandboxActorMarkerMenu_PUBLIC((CaravanLeaderMarkerRef as IMPScriptMarker).GetPositionerRef())
			
			elseif iButton == 16
				IMP.CaravanManager.ShowCaravanSandboxActorMarkerMenu_PUBLIC((CaravanGuardMarkerRef as IMPScriptMarker).GetPositionerRef())
			
			elseif iButton == 17
				IMP.CaravanManager.ShowCaravanSandboxActorMarkerMenu_PUBLIC((CaravanBrahminMarkerRef as IMPScriptMarker).GetPositionerRef())

			endif
			
		endif
	endif
EndFunction


Bool bMarkerManagerMenu_HasMarkerOwner_cond Conditional
Message property IMP_MarkerManagerMenu_MarkerListMESGb auto const mandatory

Function ShowSingleMarkerMenu(Int aiIndex)
	IMPScriptMarker MarkerRef=SandboxMarkerRefs[aiIndex] as IMPScriptMarker

	;*** fill menu aliases ***
	ObjectReference PositionerRef=MarkerRef.GetPositionerRef()
	if PositionerRef
		MarkerNameAlias.ForceRefTo(PositionerRef)
	else
		MarkerNameAlias.ForceRefTo(NONE)
	endif

	Actor OwnerRef=MarkerRef.GetActorRefOwner()
	bMarkerManagerMenu_HasMarkerOwner_cond=OwnerRef as Bool
	if bMarkerManagerMenu_HasMarkerOwner_cond
		MarkerOwnershipAlias.ForceRefTo(OwnerRef)
	else
		MarkerOwnershipAlias.ForceRefTo(OwnershipPublicAlias.GetReference())
	endif


	;*** show menu ***
	Int iButton=IMP_MarkerManagerMenu_MarkerListMESGb.Show(aiIndex+1, SettlerMenuSandboxMarkerCount_cond)
	if iButton==0
		;*** next ***
		Int NextIndex=aiIndex+1
		if NextIndex > (SettlerMenuSandboxMarkerCount_cond-1)
			NextIndex=0
		endif
		ShowSingleMarkerMenu(NextIndex)

	elseif  iButton==1
		;*** previous ***
		Int PrevIndex=aiIndex-1
		if PrevIndex < 0
			PrevIndex=SettlerMenuSandboxMarkerCount_cond-1
		endif
		ShowSingleMarkerMenu(PrevIndex)

	elseif  iButton==2
		;*** pin marker ***
		IMP.Pin.Pin_AddMarkerToCollection_PUBLIC(MarkerRef, OwnerRef)

	elseif  iButton==3
		;*** set settler ownership ***
		if bMarkerManagerMenu_HasMarkerOwner_cond == False
			((MarkerRef as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(MenuSettlerRef as Actor)
			MarkerRef.SetActorRefOwner(MenuSettlerRef as Actor)
			(MarkerRef.GetPositionerRef()).SetActorRefOwner(MenuSettlerRef as Actor)
			ShowSingleMarkerMenu(aiIndex)
		endif

	elseif  iButton==4
		;*** set public ownership ***
		if bMarkerManagerMenu_HasMarkerOwner_cond == True
			((MarkerRef as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
			MarkerRef.SetActorRefOwner(NONE)
			(MarkerRef.GetPositionerRef()).SetActorRefOwner(NONE)
			ShowSingleMarkerMenu(aiIndex)
		endif

	endif
EndFunction


Function GetOwnedMarkers(ObjectReference akSettlerRef)
	PinnedMarkerRefs.Clear()
	SandboxMarkerRefs.Clear()
	SettlerMenuSandboxMarkerCount_cond=0
	SettlerMenuOwnedPositionerCount_cond=0
	WorkObjectRef=NONE
	BedRef=NONE


	ObjectReference[] SettlerObjectsRefs=WorkshopRef.GetWorkshopOwnedObjects(akSettlerRef as Actor)
	Int SettlerObjectsCount=SettlerObjectsRefs.length
	if SettlerObjectsCount > 0
		Int i=0
		while i < SettlerObjectsCount
			ObjectReference iObjectRef=SettlerObjectsRefs[i]
			if iObjectRef as WorkshopObjectScript
				if iObjectRef.HasKeyword(IMP.WorkshopWorkObject)  &&  iObjectRef.GetValue(IMP.WorkshopResourceObject) > 0
					if (iObjectRef as WorkshopObjectScript).IsBed()
						if BedRef==NONE
							BedRef=iObjectRef
						endif
					else
						if WorkObjectRef==NONE
							WorkObjectRef=iObjectRef
						endif
					endif
				endif

			elseif iObjectRef.HasKeyword(IMP.IMP_IsSandboxRelaxMarker)  ||   iObjectRef.HasKeyword(IMP.IMP_IsSandboxWorkMarker)  ||  iObjectRef.HasKeyword(IMP.IMP_IsCreatureMarker)  ||  iObjectRef.HasKeyword(IMP.IMP_IsSandboxMerchantMarker)
				SandboxMarkerRefs.Add(iObjectRef)

			endif
			
			
			if iObjectRef as IMPScriptMarker
				PinnedMarkerRefs.Add(iObjectRef)
			endif
			
			
			i+=1
		endwhile
	endif


	ObjectReference MyProvisionerMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker)
	if MyProvisionerMarkerRef
		PinnedMarkerRefs.Add(MyProvisionerMarkerRef)
	endif


	ObjectReference MyGuardRelaxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardMarker)
	if MyGuardRelaxMarkerRef
		PinnedMarkerRefs.Add(MyGuardRelaxMarkerRef)
	else
		MyGuardRelaxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkGuardMarkerForced)
		if MyGuardRelaxMarkerRef
			PinnedMarkerRefs.Add(MyGuardRelaxMarkerRef)
		endif
	endif		


	ObjectReference MySafehouseRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarker)
	if MySafehouseRef
		PinnedMarkerRefs.Add(MySafehouseRef)
	else
		MySafehouseRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerAssemblypointMarkerForced)
		if MySafehouseRef
			PinnedMarkerRefs.Add(MySafehouseRef)
		endif
	endif	


	ObjectReference MyRestrictedSandboxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
	if MyRestrictedSandboxMarkerRef
		PinnedMarkerRefs.Add(MyRestrictedSandboxMarkerRef)
	endif


	CaravanLeaderMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkCaravanleaderMarker)
	if CaravanLeaderMarkerRef
		PinnedMarkerRefs.Add(CaravanLeaderMarkerRef)
	endif

	CaravanGuardMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkCaravanguardMarker)
	if CaravanGuardMarkerRef
		PinnedMarkerRefs.Add(CaravanGuardMarkerRef)
	endif
	
	CaravanBrahminMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkCaravanbrahminMarker)
	if CaravanBrahminMarkerRef
		PinnedMarkerRefs.Add(CaravanBrahminMarkerRef)
	endif	
	

	SettlerMenuSandboxMarkerCount_cond=SandboxMarkerRefs.length
	SettlerMenuOwnedPositionerCount_cond=PinnedMarkerRefs.length
EndFunction