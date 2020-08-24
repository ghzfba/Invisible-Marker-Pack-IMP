Scriptname IMPScriptMarkerProvisioner extends ObjectReference

Bool bInitialized

Event OnLoad()
	if bInitialized
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.ProvisionerManager.ProvisionerMarkerOnLoad_PUBLIC(Self)
	endif
EndEvent

Event OnCellDetach()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.ProvisionerMarkerOnUnload_PUBLIC(Self)
	bInitialized=True
EndEvent