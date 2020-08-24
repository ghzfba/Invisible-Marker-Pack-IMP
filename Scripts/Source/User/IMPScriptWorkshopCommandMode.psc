Scriptname IMPScriptWorkshopCommandMode extends Quest

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
RefCollectionAlias property SettlerCollection auto const mandatory
RefCollectionAlias property ProvisionerCollectionEXT auto const mandatory
ReferenceAlias property MarkerNameAlias auto const mandatory
ReferenceAlias property OwnerNameAlias auto const mandatory
ReferenceAlias property SettlerAliasTemplateEXT auto const mandatory
LocationAlias property SettlementNameAlias auto const mandatory
Message property IMP_WorkshopCommandModeOwnershipSetMESGn auto const mandatory
Message property IMP_WorkshopCommandModeOwnershipReplacedMESGb auto const mandatory
Message property IMP_WorkshopCommandModeAssignSettlerOnlyMESGn auto const mandatory
Message property IMP_WorkshopCommandModeNPCSettlerOnlyMESGn auto const mandatory
Message property IMP_WorkshopCommandModeAssignPASettlerOnlyMESGn auto const mandatory
Message property IMP_WorkshopCommandModeAssignGuardOnlyMESGn auto const mandatory
Message property IMP_WorkshopCommandModeNPCMerchantOnlyMESGn auto const mandatory
Message property IMP_WorkshopCommandModeAssignCreatureOnlyMESGn auto const mandatory

IMPScriptMain IMP

;= added in IMP v.3.11 ===
Message property IMP_WorkshopCommandModeNPCRobotOnlyMESGn auto
;=========================

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	InitializeCollections()
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectBuilt")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	RegisterForCustomEvent(IMP.Followers, "CompanionChange")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectBuilt")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	UnregisterForCustomEvent(IMP.Followers, "CompanionChange")
	ShutdownSettlers()
EndEvent


;==================
; WORKSHOP NPC TRANSFER
;==================
; Do this because there is no default event to manage NPC transfers

ObjectReference RegisteredWorkshopRef
Int PopulationCount

Function RegisterForWorkshopMode_PUBLIC(ObjectReference akWorkshopRef)
	RegisterForMenuOpenCloseEvent("Workshop_CaravanMenu")
	RegisteredWorkshopRef=akWorkshopRef
	PopulationCount=akWorkshopRef.GetValue(IMP.WorkshopRatingPopulation) as Int
EndFunction

Function UnregisterForWorkshopMode_PUBLIC()
	UnregisterForMenuOpenCloseEvent("Workshop_CaravanMenu")
	RegisteredWorkshopRef=NONE
	PopulationCount=-1
EndFunction

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	if asMenuName== "Workshop_CaravanMenu"
		if abOpening == False
			WorkshopScript WorkshopRef=RegisteredWorkshopRef as WorkshopScript

			Int NewPopulationCount=WorkshopRef.GetValue(IMP.WorkshopRatingPopulation) as Int
			Float EndLoopTime=Utility.GetCurrentRealTime()+5
			while NewPopulationCount == PopulationCount  &&  EndLoopTime > Utility.GetCurrentRealTime()
				NewPopulationCount=WorkshopRef.GetValue(IMP.WorkshopRatingPopulation) as Int
			endwhile

			if PopulationCount != -1
				if NewPopulationCount > PopulationCount
					ObjectReference[] WorkshopActorRefs=IMP.WorkshopParent.GetWorkshopActors(WorkshopRef as WorkshopScript)
					SettlerCollection.AddArray(WorkshopActorRefs)
					InitializeSettlers(WorkshopActorRefs)
				endif

				PopulationCount=WorkshopRef.GetValue(IMP.WorkshopRatingPopulation) as Int
			endif
       	endif
	endif
endEvent

;---------

;Do this when a companion is dismissed
Event FollowersScript.CompanionChange(FollowersScript akSender, Var[] akArgs)
	ObjectReference ActorThatChangedRef=akArgs[0] as ObjectReference
	Bool bIsNowCompanion=akArgs[1] as Bool
	if ActorThatChangedRef
		if bIsNowCompanion == False
			InitializeSettler(ActorThatChangedRef)
		endif
	endif
endEvent


;=====================
; FUNCTION FOR INITIALIZATION
;=====================

RefCollectionAlias property WorkshopObjectCollection auto
RefCollectionAlias property WorkshopObjectBlockedCollection auto


Function InitializeCollections()
	;*** workshop collection ***
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)

	;*** settler collection ***
	Int i=0
	while i<WorkshopCollectionEXT.GetCount()
		ObjectReference iWorkshopRef=WorkshopCollectionEXT.GetAt(i)
		if iWorkshopRef.Is3DLoaded()
			InitializeWorkshop(iWorkshopRef)
		endif
		i+=1
	endwhile

	;*** provisioner collection ***
	i=0
	while i<ProvisionerCollectionEXT.GetCount()
		SettlerAliasTemplateEXT.ApplyToRef(ProvisionerCollectionEXT.GetAt(i))
		i+=1
	endwhile
EndFunction


Function InitializeWorkshop(ObjectReference akWorkshopRef)
	if akWorkshopRef
		ObjectReference[] WorkshopResourceRefs=akWorkshopRef.GetWorkshopResourceObjects()
		Int WorkshopResourceCount=WorkshopResourceRefs.length

		if WorkshopResourceCount > 0
			Int j=0
			while j < WorkshopResourceCount
				ObjectReference jResourceRef=WorkshopResourceRefs[j]

				if jResourceRef as Actor
					InitializeSettler(jResourceRef)
				endif

				;*** find workshop objects can't be assigned to children in workshop mode ***
				FindWorkshopObjectsUnusableByChildren(jResourceRef)

				j+=1
			endwhile
		endif


		Int IncludedNPCSCount=IMP.IMP_IncludedNPCS.GetSize()
		Int k=0
		while k < IncludedNPCSCount
			Actor kNPCRef=(IMP.IMP_IncludedNPCS.GetAt(k) as ActorBase).GetUniqueActor()
			if kNPCRef.GetLinkedRef(IMP.WorkshopItemKeyword) == akWorkshopRef
				InitializeSettler(kNPCRef)
			endif
			k+=1
		endwhile
	endif
EndFunction


Function InitializeSettler(ObjectReference akSettlerRef)
	if akSettlerRef
		if IMP.IMP_ExcludedNPCS.Find((akSettlerRef as Actor).GetActorBase()) < 0
			if akSettlerRef.HasKeyword(IMP.ActorTypeNPC)  ||  akSettlerRef.HasKeyword(IMP.ActorTypeRobot)
				SettlerCollection.AddRef(akSettlerRef)
				SettlerAliasTemplateEXT.ApplyToRef(akSettlerRef)

				if akSettlerRef.HasKeyword(IMP.WorkshopAllowCommand)==False
					akSettlerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 1)
					akSettlerRef.AddKeyword(IMP.WorkshopAllowCommand)
				endif

			elseif (akSettlerRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)
				if akSettlerRef.HasKeyword(IMP.ActorTypeNPC)  ||  akSettlerRef.HasKeyword(IMP.ActorTypeRobot)  ||  akSettlerRef.HasKeyword(IMP.ActorTypeSupermutant)
					SettlerCollection.AddRef(akSettlerRef)
					SettlerAliasTemplateEXT.ApplyToRef(akSettlerRef)

					if akSettlerRef.HasKeyword(IMP.WorkshopAllowCommand)==False
						akSettlerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 1)
						akSettlerRef.AddKeyword(IMP.WorkshopAllowCommand)
					endif
				else
					IMP.CreatureManager.SetCreature_PUBLIC(akSettlerRef)
				endif

			endif
		endif
	endif
EndFunction

Function InitializeSettlers(ObjectReference[] akSettlerRefs)
	Int i=0
	while i < akSettlerRefs.length
		InitializeSettler(akSettlerRefs[i])
		i+=1
	endwhile
EndFunction


Function ShutdownSettlers()
	int SettlerCount=SettlerCollection.GetCount()
	int i=0
	while i < SettlerCount
		ObjectReference iSettlerRef=SettlerCollection.GetAt(i)

		SettlerCollection.RemoveRef(iSettlerRef)
		SettlerAliasTemplateEXT.RemoveFromRef(iSettlerRef)

		if iSettlerRef.GetValue(IMP.IMP_HasCreatureCommandKeyword) == 1
			iSettlerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 0)
			iSettlerRef.RemoveKeyword(IMP.WorkshopAllowCommand)
		endif		

		i+=1
	endwhile

	int ProvisionerCount=ProvisionerCollectionEXT.GetCount()
	i=0
	while i < ProvisionerCount
		ObjectReference iProvisionerRef=ProvisionerCollectionEXT.GetAt(i)

		SettlerAliasTemplateEXT.RemoveFromRef(iProvisionerRef)

		if iProvisionerRef.GetValue(IMP.IMP_HasCreatureCommandKeyword) == 1
			iProvisionerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 0)
			iProvisionerRef.RemoveKeyword(IMP.WorkshopAllowCommand)
		endif		

		i+=1
	endwhile
EndFunction



;===================================
; FUNCTIONS USED BY EVENTS FROM EXTERNAL SCRIPTS
;===================================

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	InitializeWorkshop(akWorkshopRef)

	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction

;---------

Function SettlerOnUnload_PUBLIC(ObjectReference akSettlerRef)
	SettlerCollection.RemoveRef(akSettlerRef)

	if akSettlerRef.GetValue(IMP.IMP_HasCreatureCommandKeyword) == 1
		akSettlerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 0)
		akSettlerRef.RemoveKeyword(IMP.WorkshopAllowCommand)
	endif
EndFunction

Function SettlerOnDeath_PUBLIC(ObjectReference akSettlerRef)
	SettlerCollection.RemoveRef(akSettlerRef)

	if akSettlerRef.GetValue(IMP.IMP_HasCreatureCommandKeyword) == 1
		akSettlerRef.SetValue(IMP.IMP_HasCreatureCommandKeyword, 0)
		akSettlerRef.RemoveKeyword(IMP.WorkshopAllowCommand)
	endif
EndFunction

Function SettlerOnNPCTransfer_PUBLIC(ObjectReference akSettlerRef)
	SettlerCollection.RemoveRef(akSettlerRef)
EndFunction

;---------

Function SettlerCommandModeGiveCommand_PUBLIC(ObjectReference akSettlerRef, int aeCommandType, ObjectReference akTarget)
	if akTarget
		if akTarget.HasKeyword(IMP.WorkshopWorkObject)

			if akTarget as IMPScriptPositioner
				ObjectReference MarkerRef=(akTarget as IMPScriptPositioner).GetMarkerRef()


				if akTarget.HasKeyword(IMP.IMP_IsWorkPositioner)
					;*** assign settler to job ***
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						IMP.JobAssigning.AssignActorToObject(akSettlerRef as WorkshopNPCScript, MarkerRef as WorkshopObjectScript)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsSandboxWorkPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** set ownership for this marker so it can be used during settlers' sandbox packages ***
					if akSettlerRef.HasKeyword(IMP.ActorTypeNPC) == False
						IMP_WorkshopCommandModeNPCSettlerOnlyMESGn.Show()						
					elseif SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						HandleSandboxMarkerOwnership(akSettlerRef=akSettlerRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)
					endif
			

				elseif akTarget.HasKeyword(IMP.IMP_IsSandboxRelaxPositionerRobot)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** set ownership for this marker so it can be used during settlers' sandbox packages ***
					if akSettlerRef.HasKeyword(IMP.ActorTypeRobot) == False
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeNPCRobotOnlyMESGn.Show()						
					else
						HandleSandboxMarkerOwnership(akSettlerRef=akSettlerRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsSandboxRelaxPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** set ownership for this marker so it can be used during settlers' sandbox packages ***
					if akSettlerRef.HasKeyword(IMP.ActorTypeNPC) == False
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeNPCSettlerOnlyMESGn.Show()						
					else
						HandleSandboxMarkerOwnership(akSettlerRef=akSettlerRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsCreaturePositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if akSettlerRef.HasKeyword(IMP.ActorTypeNPC) == True  ||  akSettlerRef.HasKeyword(IMP.ActorTypeRobot) == True
						;*** show error message because this type of markers can't be used by non-creature-type actors ***
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignCreatureOnlyMESGn.Show()
					elseif (akSettlerRef as Actor).IsInFaction(IMP.HasBeenCompanionFaction)			
						HandleSandboxMarkerOwnership(akSettlerRef=akSettlerRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsSandboxMerchantPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** set ownership for this marker so it can be used during merchants' sandbox packages ***
					if akSettlerRef.HasKeyword(IMP.IMP_IsCaravanLeader) == False
						IMP_WorkshopCommandModeNPCMerchantOnlyMESGn.Show()						
					else
						HandleSandboxMarkerOwnership(akSettlerRef=akSettlerRef, akPositionerRef=akTarget, akMarkerRef=MarkerRef)
					endif
					

				;== EXTERNAL CALLS =============================================

				elseif akTarget.HasKeyword(IMP.IMP_IsGuardPatrolPositioner)
					if SettlerCollection.Find(akSettlerRef) < 0
						(akSettlerRef as Actor).SetCanDoCommand(False)
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						;*** assign actor to guard patrol marker ***
						IMP.GuardPatrol.AssignGuardToPatrolmarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsGuardScoutPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						;*** assign actor to guard scout  marker ***
						IMP.GuardScout.AssignGuardToScoutmarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsGuardRelaxPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					elseif (akSettlerRef as WorkshopNPCScript).bIsGuard == False
						IMP_WorkshopCommandModeAssignGuardOnlyMESGn.Show()
					else
						;*** assign actor to guard relax marker ***
						IMP.GuardManager.AssignGuardToRelaxMarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsPowerarmorPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					elseif (akSettlerRef as WorkshopNPCScript).bIsGuard == False
						IMP_WorkshopCommandModeAssignGuardOnlyMESGn.Show()
					elseif (akSettlerRef as Actor).IsInPowerArmor() == False
						IMP_WorkshopCommandModeAssignPASettlerOnlyMESGn.Show()
					else
						;*** assign actor to power armor marker ***
						IMP.GuardManager.AssignGuardToPowerarmorMarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsAssemblyPointPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						;*** assign actor to assembly point ***
						IMP.AssemblyPoint.AssignSettlerToAssemblyPointMarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsBattlePositionPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						;*** assign actor to assembly point ***
						IMP.AssemblyPoint.AssignSettlerToBattlePositionMarker_PUBLIC(akSettlerRef, MarkerRef)
					endif


				elseif akTarget.HasKeyword(IMP.IMP_IsRestrictedSandboxPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					if SettlerCollection.Find(akSettlerRef) < 0
						SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
						IMP_WorkshopCommandModeAssignSettlerOnlyMESGn.Show()
					else
						;*** assign actor to restricted sandbox marker ***
						IMP.RestrictedSandbox.AssignSandboxerToMarker_PUBLIC(akSettlerRef, MarkerRef)
					endif
					

				elseif akTarget.HasKeyword(IMP.IMP_IsRestrictedSandboxCreaturePositioner)
					SettlementNameAlias.ForceLocationTo(MarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
					IMP_WorkshopCommandModeAssignCreatureOnlyMESGn.Show()


				elseif akTarget.HasKeyword(IMP.IMP_IsProvisionerPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** assign provisioner to provisione marker ***
					IMP.ProvisionerManager.AssignProvisionerToMarker_PUBLIC(akSettlerRef, MarkerRef)


				elseif akTarget.HasKeyword(IMP.IMP_IsProvisionerBrahminPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** assign provisioner to provisione marker ***
					IMP.ProvisionerManager.AssignProvisionerBrahminToMarker_PUBLIC(akSettlerRef, MarkerRef)

					
				elseif akTarget.HasKeyword(IMP.IMP_IsCaravanLeaderPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** assign caravan leader to marker ***
					IMP.CaravanManager.AssignCaravanleaderToMarker_PUBLIC(akSettlerRef, MarkerRef)


				elseif akTarget.HasKeyword(IMP.IMP_IsCaravanGuardPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** assign caravan guard to marker ***
					IMP.CaravanManager.AssignCaravanguardToMarker_PUBLIC(akSettlerRef, MarkerRef)


				elseif akTarget.HasKeyword(IMP.IMP_IsCaravanBrahminPositioner)
					(akSettlerRef as Actor).SetCanDoCommand(False)
					;*** assign caravan brahmin to marker ***
					IMP.CaravanManager.AssignCaravanbrahminToMarker_PUBLIC(akSettlerRef, MarkerRef)


				endif



			endif

		endif
	endif
EndFunction


;=========


Function HandleSandboxMarkerOwnership(ObjectReference akSettlerRef, ObjectReference akPositionerRef, ObjectReference akMarkerRef)
	if akMarkerRef
		ObjectReference MarkerOwnerRef=akMarkerRef.GetActorRefOwner()
		if MarkerOwnerRef==NONE
			akPositionerRef.SetActorRefOwner(akSettlerRef as Actor)
			akMarkerRef.SetActorRefOwner(akSettlerRef as Actor)
			if (akMarkerRef as IMPScriptMarkerProps)
				(akMarkerRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(akSettlerRef as Actor)
			endif
			(akSettlerRef as Actor).EvaluatePackage()
			IMP_WorkshopCommandModeOwnershipSetMESGn.Show()

		elseif MarkerOwnerRef==akSettlerRef
			;*** set public ownership if you select the marker when the owner is in command mode ***
			IMP.MarkerManagerMenu.ShowOwnershipEntry(akPositionerRef, MarkerOwnerRef)

		elseif MarkerOwnerRef!=akSettlerRef
			;*** set new ownership / public if you select the marker when a settler, which is not the owner, is command mode ***
			MarkerNameAlias.ForceRefTo(akPositionerRef)
			OwnerNameAlias.ForceRefTo(MarkerOwnerRef)
			Int iButton=IMP_WorkshopCommandModeOwnershipReplacedMESGb.Show()
			if iButton==1
				akPositionerRef.SetActorRefOwner(akSettlerRef as Actor)
				akMarkerRef.SetActorRefOwner(akSettlerRef as Actor)
				(akMarkerRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(akSettlerRef as Actor)
				(akSettlerRef as Actor).EvaluatePackage()
				IMP_WorkshopCommandModeOwnershipSetMESGn.Show()
			elseif iButton==2
				akPositionerRef.SetActorRefOwner(NONE)
				akMarkerRef.SetActorRefOwner(NONE)
				(akMarkerRef as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
				IMP_WorkshopCommandModeOwnershipSetMESGn.Show()
			endif
		endif
	endif
EndFunction

Function HandleSandboxMarkerOwnership_PUBLIC(ObjectReference akSettlerRef, ObjectReference akPositionerRef, ObjectReference akMarkerRef)
	HandleSandboxMarkerOwnership(akSettlerRef, akPositionerRef, akMarkerRef)
EndFunction


;=========


Function ChildOnCommandModeEnter_PUBLIC(ObjectReference akChildRef)
	if akChildRef
		if (akChildRef as Actor).IsChild()
			WorkshopObjectBlockedCollection.AddRefCollection(WorkshopObjectCollection)
		endif
	endif
EndFunction


Function ChildOnCommandModeExit_PUBLIC(ObjectReference akChildRef)
	if akChildRef
		if (akChildRef as Actor).IsChild()
			WorkshopObjectBlockedCollection.RemoveAll()
		endif
	endif
EndFunction


Function WorkshopObjectOnUnload_PUBLIC(ObjectReference akObjectRef)
	if akObjectRef
		WorkshopObjectCollection.RemoveRef(akObjectRef)
		WorkshopObjectBlockedCollection.RemoveRef(akObjectRef)
	endif
EndFunction


;---------


Function FindWorkshopObjectsUnusableByChildren(ObjectReference akObjectRef)
	if akObjectRef

		ObjectReference ObjectRef=akObjectRef
		if ObjectRef as IMPScriptMarker
			ObjectRef=(ObjectRef as IMPScriptMarker).GetPositionerRef()
		endif


		if ObjectRef.HasKeyword(IMP.WorkshopWorkObject)
			if ObjectRef.HasKeyword(IMP.WorkshopGuardObject) || ObjectRef.GetValue(IMP.Safety) > 0
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.HasKeyword(IMP.IMP_IsGuardPatrolPositioner)
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.HasKeyword(IMP.IMP_IsGuardScoutPositioner)
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.HasKeyword(IMP.IMP_IsBattlePositionPositioner)
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.HasKeyword(IMP.IMP_IsGuardRelaxPositioner)
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.HasKeyword(IMP.IMP_IsPowerarmorPositioner)
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef as IMPScriptPositioner && \
			ObjectRef.HasKeyword(IMP.IMP_IsVendorPositioner)  &&  \
			IMP.IMP_PositionersUsedByChildren.Find(ObjectRef.GetBaseObject()) < 0
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef as IMPScriptPositioner && \
			IMP.IMP_PositionersUsedByChildren.Find(ObjectRef.GetBaseObject()) < 0
				WorkshopObjectCollection.AddRef(ObjectRef)

			elseif ObjectRef.GetValue(IMP.Food) == 0 && \
			ObjectRef.GetValue(IMP.WorkshopRatingScavengeGeneral) == 0 && \
			(ObjectRef as WorkshopObjectScript).VendorType < 0 && \
				WorkshopObjectCollection.AddRef(ObjectRef)

			endif
		endif 
	endif
EndFunction


Event WorkshopParentScript.WorkshopObjectBuilt(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ResourceRef=akArgs[0] as ObjectReference
	if ResourceRef
		FindWorkshopObjectsUnusableByChildren(ResourceRef)
	endif 
EndEvent


Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ResourceRef=akArgs[0] as ObjectReference
	if ResourceRef
		FindWorkshopObjectsUnusableByChildren(ResourceRef)
	endif 
EndEvent


Function IsObjectUsableByChildren_PUBLIC(ObjectReference akObjectRef)
	if akObjectRef
		FindWorkshopObjectsUnusableByChildren(akObjectRef)
	endif
EndFunction