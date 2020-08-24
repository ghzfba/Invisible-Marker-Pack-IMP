Scriptname IMPScriptRestrictedSandbox extends Quest Conditional

RefCollectionAlias property SandboxingActorCollection auto const mandatory
ReferenceAlias property SettlerNameAlias auto const mandatory
LocationAlias property SettlementNameAlias auto const mandatory
LocationAlias property SizeNameAlias auto const mandatory
Message property IMP_RestrictedSandboxUnassignMESGb auto const mandatory
Message property IMP_RestrictedSandboxNewAssignMESGb auto const mandatory
Message property IMP_RestrictedSandboxSelectRadiusMESGb auto const mandatory
Message property IMP_RestrictedSanboxAssigningSuccededMESGn auto const mandatory
Message property IMP_RestrictedSanboxUnassigningSuccededMESGn auto const mandatory
Message property IMP_RestrictedSanboxAssigningAborted01MESGn auto const mandatory
Message property IMP_RestrictedSanboxAssigningAborted02MESGn auto const mandatory
Formlist property IMP_RestrictedSandboxRadiusList auto const mandatory

Bool bIsPlacingMarker Conditional
Int SandboxerRadiusID_cond Conditional

IMPScriptMain IMP


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent



;===========
; MAIN FUNCTION
;===========

Function SetSandboxer(ObjectReference akSettlerRef, ObjectReference akMarkerRef)
	if akSettlerRef && akMarkerRef
		SandboxingActorCollection.AddRef(akSettlerRef)
		akSettlerRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		(akSettlerRef as Actor).EvaluatePackage()
	endif
EndFunction


Function UnsetSandboxer(ObjectReference akSettlerRef)
	if akSettlerRef
		SandboxingActorCollection.RemoveRef(akSettlerRef)
		akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		(akSettlerRef as Actor).EvaluatePackage()
	endif
EndFunction



;===============================
; MENUS
;===============================


Function AssignSandboxerToMarker_PUBLIC(ObjectReference akSettlerRef, ObjectReference akMarkerRef)
	if akSettlerRef && akMarkerRef
		Actor SettlerActorRef=akSettlerRef as Actor

		if \
		SettlerActorRef.IsInFaction(IMP.WorkshopVendorFactionBar) || \
		SettlerActorRef.IsInFaction(IMP.WorkshopCaravanFaction) || \
		(SettlerActorRef as WorkshopNPCScript).bIsGuard
			SettlerNameAlias.ForceRefTo(akSettlerRef)
			IMP_RestrictedSanboxAssigningAborted01MESGn.Show()

		elseif akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker) == False
			SetSandboxer(akSettlerRef, akMarkerRef)
			SettlerNameAlias.ForceRefTo(akSettlerRef)
			IMP_RestrictedSanboxAssigningSuccededMESGn.Show()

		elseif akMarkerRef == akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			SettlerNameAlias.ForceRefTo(akSettlerRef)
			Int iButton=IMP_RestrictedSandboxUnassignMESGb.Show()
			if iButton==1
				IMP.Pin.Pin_AddActorToCollection_PUBLIC(SettlerActorRef, (akMarkerRef as IMPScriptMarker).GetPositionerRef())
			elseif iButton==2
				UnsetSandboxer(akSettlerRef)
				IMP_RestrictedSanboxUnassigningSuccededMESGn.Show()
			endif

		elseif akMarkerRef != akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			SettlerNameAlias.ForceRefTo(akSettlerRef)
			akSettlerRef.SetLinkedRef(NONE, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			(akSettlerRef as Actor).EvaluatePackage()
			Utility.Wait(0.5)
			akSettlerRef.SetLinkedRef(akMarkerRef, IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			(akSettlerRef as Actor).EvaluatePackage()
			IMP_RestrictedSanboxAssigningSuccededMESGn.Show()
			
		endif

	endif
EndFunction

;=========

Message property IMP_RestrictedSandboxEntryMenuMESGb auto const mandatory
Int SettlerLinkedToSandboxMarkerCount_cond Conditional
ObjectReference[] SettlerLinkedToSandboxMarkerRefs

Function ShowRestrictedSandboxMarkerMenu_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	
		SettlerLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		SettlerLinkedToSandboxMarkerCount_cond=SettlerLinkedToSandboxMarkerRefs.length
		
		Int iButton=IMP_RestrictedSandboxEntryMenuMESGb.Show(SettlerLinkedToSandboxMarkerCount_cond)
		if iButton==1
			IMP.Pin.Pin_AddActorArrayToCollection_PUBLIC(SettlerLinkedToSandboxMarkerRefs, akPositionerRef)
		elseif iButton==2
			ShowRestrictedSandboxRadiusMenu(akPositionerRef)
			SandboxingActorCollection.EvaluateAll()
		endif
	endif
EndFunction

;=========

Function ShowRestrictedSandboxRadiusMenu(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()

		bIsPlacingMarker=False
		SandboxerRadiusID_cond=MarkerRef.GetValue(IMP.IMP_SandboxerRadius) as Int
		SizeNameAlias.ForceLocationTo(IMP_RestrictedSandboxRadiusList.GetAt(SandboxerRadiusID_cond) as Location)

		Int iButton=IMP_RestrictedSandboxSelectRadiusMESGb.Show()
		if iButton == 1
			MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
			(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(256)
		elseif iButton == 2
			MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
			(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(512)
		elseif iButton == 3
			MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
			(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(768)
		endif
	endif
EndFunction


Function ShowRestrictedSandboxRadiusMenu_PUBLIC(ObjectReference akPositionerRef)
	ShowRestrictedSandboxRadiusMenu(akPositionerRef)
EndFunction


;=================================
; FUNCTIONS USED BY RESTRICTED SANDBOX MARKER
;=================================

Function RestrictedSandboxMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef
	Float EndLoopTime=Utility.GetCurrentRealTime()+5
	while MarkerRef == NONE && EndLoopTime > Utility.GetCurrentRealTime()
		MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	endwhile

	bIsPlacingMarker=True
	SandboxerRadiusID_cond=MarkerRef.GetValue(IMP.IMP_SandboxerRadius) as Int
	SizeNameAlias.ForceLocationTo(IMP_RestrictedSandboxRadiusList.GetAt(SandboxerRadiusID_cond) as Location)
	
	Int iButton=IMP_RestrictedSandboxSelectRadiusMESGb.Show()
	if iButton == 1
		MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
		(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(256, bEnableRadiusPositioner=True)
	elseif iButton == 2
		MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
		(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(512, bEnableRadiusPositioner=True)
	elseif iButton == 3
		MarkerRef.SetValue(IMP.IMP_SandboxerRadius, iButton)
		(akPositionerRef as IMPScriptPositionerRadius).RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(768, bEnableRadiusPositioner=True)
	endif
EndFunction


Function RestrictedSandboxMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		ObjectReference[] SettlerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		Int SettlerRefCount=SettlerRefs.length
		if SettlerRefCount > 0
			Int i=0
			while i < SettlerRefCount
				ObjectReference iSettlerRef=SettlerRefs[i]
				UnsetSandboxer(iSettlerRef)
				i+=1
			endwhile
		endif
	endif
EndFunction



;====================================
; FUNCTIONS USED BY SCRIPTS ATTACHED TO THIS QUEST
;====================================

Function IsCurrentJobIncompatible(ObjectReference akSettlerRef)
	if akSettlerRef
		if akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
			WorkshopNPCScript SettlerActorRef=(akSettlerRef as Actor) as WorkshopNPCScript
			if \
			SettlerActorRef.IsInFaction(IMP.WorkshopVendorFactionBar) || \
			SettlerActorRef.IsInFaction(IMP.WorkshopCaravanFaction) || \
			SettlerActorRef.bIsGuard
				UnsetSandboxer(akSettlerRef)
				SettlerNameAlias.ForceRefTo(akSettlerRef)
				IMP_RestrictedSanboxAssigningAborted02MESGn.Show()
			endif
		endif
	endif
EndFunction

Function IsCurrentJobIncompatible_PUBLIC(ObjectReference akSettlerRef)
	IsCurrentJobIncompatible(akSettlerRef)
EndFunction

;---------

Function SettlerOnWorkshopNPCTransfer_PUBLIC(ObjectReference akSettlerRef)
	if akSettlerRef
		ObjectReference RestrictedSandboxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		if RestrictedSandboxMarkerRef
			UnsetSandboxer(akSettlerRef)
		endif
	endif
EndFunction

Function SettlerOnDeath_PUBLIC(ObjectReference akSettlerRef)
	if akSettlerRef
		ObjectReference RestrictedSandboxMarkerRef=akSettlerRef.GetLinkedRef(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		if RestrictedSandboxMarkerRef
			UnsetSandboxer(akSettlerRef)
		endif
	endif
EndFunction



