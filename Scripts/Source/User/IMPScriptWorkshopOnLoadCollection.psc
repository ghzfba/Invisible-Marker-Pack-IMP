Scriptname IMPScriptWorkshopOnLoadCollection extends RefCollectionAlias

IMPScriptGuardManager property GuardManager auto const
IMPScriptMarkerManagerOwnership property MarkerManagerOwnership auto const
IMPScriptPreexMarkerManagerEDITOR property PreexMarkerEditor auto const
IMPScriptPreexMarkerManagerINGAME property PreexMarkerIngame auto const
IMPScriptWorkshopCommandMode property CommandMode auto const

Event OnLoad(ObjectReference akSender)
	if GuardManager
		GuardManager.WorkshopOnLoad_PUBLIC(akSender)

	elseif MarkerManagerOwnership
		MarkerManagerOwnership.WorkshopOnLoad_PUBLIC(akSender)

	elseif PreexMarkerEditor
		PreexMarkerEditor.WorkshopOnLoad_PUBLIC(akSender)

	elseif PreexMarkerIngame
		PreexMarkerIngame.WorkshopOnLoad_PUBLIC(akSender)

	elseif CommandMode
		CommandMode.WorkshopOnLoad_PUBLIC(akSender)
	endif
EndEvent

