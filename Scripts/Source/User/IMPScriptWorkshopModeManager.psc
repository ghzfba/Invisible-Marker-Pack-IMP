Scriptname IMPScriptWorkshopModeManager extends Quest Conditional

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
RefCollectionAlias property MarkerBehaviour01Collection auto const mandatory
RefCollectionAlias property MarkerCreature01Collection auto const mandatory
RefCollectionAlias property MarkerFX01Collection auto const mandatory
RefCollectionAlias property MarkerGuard01Collection auto const mandatory
RefCollectionAlias property MarkerGuard02Collection auto const mandatory
RefCollectionAlias property MarkerMisc01Collection auto const mandatory
RefCollectionAlias property MarkerPreex01Collection auto const mandatory
RefCollectionAlias property MarkerPreex02Collection auto const mandatory
RefCollectionAlias property MarkerPreex03Collection auto const mandatory
RefCollectionAlias property MarkerRelax01Collection auto const mandatory
RefCollectionAlias property MarkerRelax02Collection auto const mandatory
RefCollectionAlias property MarkerVendor01Collection auto const mandatory
RefCollectionAlias property MarkerWork01Collection auto const mandatory
RefCollectionAlias property RadiusCollection auto const mandatory

IMPScriptMain IMP


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	InitializeCollections()
EndEvent


Event OnQuestShutdown()
	DeleteCollection(MarkerBehaviour01Collection)
	DeleteCollection(MarkerCreature01Collection)
	DeleteCollection(MarkerFX01Collection)
	DeleteCollection(MarkerGuard01Collection)
	DeleteCollection(MarkerGuard02Collection)
	DeleteCollection(MarkerMisc01Collection)
	DeleteCollection(MarkerPreex01Collection)
	DeleteCollection(MarkerPreex02Collection)
	DeleteCollection(MarkerPreex03Collection)
	DeleteCollection(MarkerRelax01Collection)
	DeleteCollection(MarkerRelax01Collection)
	DeleteCollection(MarkerVendor01Collection)
	DeleteCollection(MarkerWork01Collection)
EndEvent



;=====================
; FUNCTION FOR INITIALIZATION
;=====================

Function InitializeCollections()
	;*** workshop collection ***
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction



;==========================
; FUNCTIONS USED BY EXTERNAL SCRIPTS
;==========================

Function WorkshopOnLoad_PUBLIC()
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction

;---------

Function WorkshopOnWorkshopModeTrue_PUBLIC()
	IMP.IMP_IsInWorkshopMode.SetValue(1)


	if IMP.IMP_PositionerFilter_ShowBehaviourPositioner.Getvalue() == 1
		MarkerBehaviour01Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowCreaturePositioner.Getvalue() == 1
		MarkerCreature01Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowFXPositioner.Getvalue() == 1
		MarkerFX01Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowGuardPositioner.Getvalue() == 1
		MarkerGuard01Collection.EnableAll()
		MarkerGuard02Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowMiscPositioner.Getvalue() == 1
		MarkerMisc01Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowPreexPositioner.Getvalue() == 1
		MarkerPreex01Collection.EnableAll()
		MarkerPreex02Collection.EnableAll()
		MarkerPreex03Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowRelaxationPositioner.Getvalue() == 1
		MarkerRelax01Collection.EnableAll()
		MarkerRelax02Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowVendorPositioner.Getvalue() == 1
		MarkerVendor01Collection.EnableAll()
	endif

	if IMP.IMP_PositionerFilter_ShowWorkPositioner.Getvalue() == 1
		MarkerWork01Collection.EnableAll()
	endif
EndFunction

Function WorkshopOnWorkshopModeFalse_PUBLIC()
	IMP.IMP_IsInWorkshopMode.SetValue(0)

	MarkerBehaviour01Collection.DisableAll()
	MarkerCreature01Collection.DisableAll()
	MarkerFX01Collection.DisableAll()
	MarkerGuard01Collection.DisableAll()
	MarkerGuard02Collection.DisableAll()
	MarkerMisc01Collection.DisableAll()
	MarkerPreex01Collection.DisableAll()
	MarkerPreex02Collection.DisableAll()
	MarkerPreex03Collection.DisableAll()
	MarkerRelax01Collection.DisableAll()
	MarkerRelax02Collection.DisableAll()
	MarkerVendor01Collection.DisableAll()
	MarkerWork01Collection.DisableAll()
	RadiusCollection.DisableAll()
EndFunction


;=========


Function AddPositioner_PUBLIC(ObjectReference akPositionerRef)
	if akPositionerRef.HasKeyword(IMP.IMP_IsBehaviourPositioner)
		MarkerBehaviour01Collection.AddRef(akPositionerRef)
		
	elseif akPositionerRef.HasKeyword(IMP.IMP_IsCreaturePositioner)
		MarkerCreature01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsFXPositioner)
		MarkerFX01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsGuardPositioner)
		if MarkerGuard01Collection.GetCount() < 128
			MarkerGuard01Collection.AddRef(akPositionerRef)
		else
			MarkerGuard02Collection.AddRef(akPositionerRef)
		endif

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsMiscPositioner)
		MarkerMisc01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsPreexPositioner)
		if MarkerPreex01Collection.GetCount() < 128
			MarkerPreex01Collection.AddRef(akPositionerRef)
		elseif MarkerPreex02Collection.GetCount() < 128
			MarkerPreex02Collection.AddRef(akPositionerRef)
		else
			MarkerPreex03Collection.AddRef(akPositionerRef)
		endif

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxRelaxPositioner)
		if MarkerRelax01Collection.GetCount() < 128
			MarkerRelax01Collection.AddRef(akPositionerRef)
		else
			MarkerRelax02Collection.AddRef(akPositionerRef)
		endif

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsVendorPositioner)
		MarkerVendor01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxMerchantPositioner)
		MarkerVendor01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsSandboxWorkPositioner)
		MarkerWork01Collection.AddRef(akPositionerRef)

	elseif akPositionerRef.HasKeyword(IMP.IMP_IsRadiusPositioner)
		RadiusCollection.AddRef(akPositionerRef)

	endif
EndFunction

Function RemovePositioner_PUBLIC(ObjectReference akPositionerRef)
	MarkerBehaviour01Collection.RemoveRef(akPositionerRef)
	MarkerCreature01Collection.RemoveRef(akPositionerRef)
	MarkerFX01Collection.RemoveRef(akPositionerRef)
	MarkerGuard01Collection.RemoveRef(akPositionerRef)
	MarkerGuard02Collection.RemoveRef(akPositionerRef)
	MarkerMisc01Collection.RemoveRef(akPositionerRef)
	MarkerPreex01Collection.RemoveRef(akPositionerRef)
	MarkerPreex02Collection.RemoveRef(akPositionerRef)
	MarkerPreex03Collection.RemoveRef(akPositionerRef)
	MarkerRelax01Collection.RemoveRef(akPositionerRef)
	MarkerRelax02Collection.RemoveRef(akPositionerRef)
	MarkerVendor01Collection.RemoveRef(akPositionerRef)
	MarkerWork01Collection.RemoveRef(akPositionerRef)
	RadiusCollection.RemoveRef(akPositionerRef)
EndFunction



;==========================
; TURN ON/OFF FILTERS
;==========================

Function ShowBehaviourPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowBehaviourPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowCreaturePositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowCreaturePositioner.SetValue(bFlag as Float)
EndFunction

Function ShowFXPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowFXPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowGuardPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowGuardPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowMiscPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowMiscPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowPreexPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowPreexPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowRelaxationPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowRelaxationPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowVendorPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowVendorPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowWorkPositioner(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowWorkPositioner.SetValue(bFlag as Float)
EndFunction

Function ShowRadius(Bool bFlag)
	IMP.IMP_PositionerFilter_ShowRadius.SetValue(bFlag as Float)
EndFunction



;==========================
; DELETE MARKER ON UNINSTALL
;==========================

Function DeleteCollection(RefCollectionAlias akCollection)
	Int i=akCollection.GetCount()-1
	while i >= 0
		IMPScriptPositioner PositionerRef=akCollection.GetAt(i) as IMPScriptPositioner
		if PositionerRef
			ObjectReference MarkerRef=PositionerRef.GetMarkerRef()
			(MarkerRef as IMPScriptMarker).DeleteMarker()
			PositionerRef.DeletePositioner()
		endif
		i-=1
	endwhile
EndFunction


;==========================
; DELETE PREEXEDITOR
;==========================

Function DeletePreexMarkersEditor_PUBLIC()
	DeleteCollection(MarkerPreex01Collection)
	DeleteCollection(MarkerPreex02Collection)
	DeleteCollection(MarkerPreex03Collection)
EndFunction