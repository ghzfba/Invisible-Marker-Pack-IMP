Scriptname IMPScriptRS_SandboxerCollection extends RefCollectionAlias

Event OnWorkshopNPCTransfer(ObjectReference akSender, Location akNewWorkshop, Keyword akActionKW)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.RestrictedSandbox.SettlerOnWorkshopNPCTransfer_PUBLIC(akSender)
EndEvent

Event OnDeath(ObjectReference akSender, Actor akKiller)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.RestrictedSandbox.SettlerOnDeath_PUBLIC(akSender)
EndEvent