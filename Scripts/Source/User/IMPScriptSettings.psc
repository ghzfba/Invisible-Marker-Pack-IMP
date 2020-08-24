Scriptname IMPScriptSettings extends Quest

IMPScriptMain IMP

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent



;==============================
; TURN ON/OFF POSITIONERS IN BUILD MODE
;==============================
Formlist property IMP_BuildMenu_SubmenuDisplayConditions auto const mandatory

Function EditDisplayCondition(Int aiIndex)
	GlobalVariable DisplayCondition=IMP_BuildMenu_SubmenuDisplayConditions.GetAt(aiIndex) as GlobalVariable
	if DisplayCondition.GetValue() == 0
		DisplayCondition.SetValue(1)
	else
		DisplayCondition.SetValue(0)
	endif
EndFunction



;=============
; MISC SETTINGS
;=============
Formlist property IMP_MarkerManagerMenu_SettingButtons auto const mandatory
Int[] property SettingButtons_DirectXScanCode auto const mandatory
LocationAlias property Slot01LocationAlias auto const mandatory
Message property IMP_Settings_MarkerManagerMenuButtonMESGn auto const mandatory

Function ShowMarkerManagerMenuNotification()
	if IMP.IMP_MarkerManagerMenu_ShowNotification.GetValue()==0
		IMP.IMP_MarkerManagerMenu_ShowNotification.SetValue(1)
	else
		IMP.IMP_MarkerManagerMenu_ShowNotification.SetValue(0)
	endif
EndFunction

Function ShowAllOpenInventoryButtons()
	if IMP.IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons.GetValue()==0
		IMP.IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons.SetValue(1)
	else
		IMP.IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons.SetValue(0)
	endif
EndFunction

Function SetMarkerManagerMenuButtonScancode()
	Int CurrentDirectXScanCode=IMP.IMP_KeyScanCodeF4SE.GetValue() as Int
	Int Index=SettingButtons_DirectXScanCode.Find(CurrentDirectXScanCode)
	if Index >= 0
		Index+=1
		if Index >= SettingButtons_DirectXScanCode.length
			Index=0
		endif

		Int NewScanCode=SettingButtons_DirectXScanCode[Index]
		IMP.IMP_KeyScanCodeF4SE.SetValue(NewScanCode)

		Slot01LocationAlias.ForceLocationTo(IMP_MarkerManagerMenu_SettingButtons.GetAt(Index) as Location)
		IMP_Settings_MarkerManagerMenuButtonMESGn.Show()
	endif
EndFunction

Function ShowHolotapeRecipe()
	if IMP.IMP_ChemMenu_ShowHolotapeRecipe.GetValue()==0
		IMP.IMP_ChemMenu_ShowHolotapeRecipe.SetValue(1)
	else
		IMP.IMP_ChemMenu_ShowHolotapeRecipe.SetValue(0)
	endif
EndFunction

Function ShowQubeRecipe()
	if IMP.IMP_ChemMenu_ShowQubeRecipe.GetValue()==0
		IMP.IMP_ChemMenu_ShowQubeRecipe.SetValue(1)
	else
		IMP.IMP_ChemMenu_ShowQubeRecipe.SetValue(0)
	endif
EndFunction



;=============
; HOLOTAPE LABELS
;=============
Formlist property IMP_Settings_Holotapes auto const mandatory

Function GetSettingHolotape(Int aiHolotapeID, ObjectReference akTerminalRef=NONE)
	ObjectReference TerminalRef=akTerminalRef
	if TerminalRef == NONE
		TerminalRef=Game.GetPlayer()
	endif

	TerminalRef.RemoveItem(IMP_Settings_Holotapes, aiCount=-1, abSilent=True)
	TerminalRef.AddItem(IMP_Settings_Holotapes.GetAt(aiHolotapeID) as Holotape)
EndFunction



;====================
; Mod reset/uninstall
;====================
Message property IMP_ModInstalledMESGn auto const mandatory
Message property IMP_ModResetMESGn auto const mandatory
Message property IMP_ModUninstalledMESGn auto const mandatory

Function UninstallMod()
	IMP.AssemblyPoint.Stop()
	IMP.CaravanManager.Stop()
	IMP.GuardManager.Stop()
	IMP.MarkerManagerMenu.Stop()
	IMP.PreexMarkerIngame.Stop()
	IMP.PreexMarkerEditor.StopPreexMarkerEditorQuest()
	IMP.ProvisionerManager.Stop()
	IMP.RestrictedSandbox.Stop()
	IMP.CommandMode.Stop()
	IMP.WorkshopMode.Stop()

	IMP_ModUninstalledMESGn.Show()
EndFunction


Function InstallMod()
	IMP.AssemblyPoint.Start()
	IMP.CaravanManager.Start()
	IMP.GuardManager.Start()
	IMP.MarkerManagerMenu.Start()
	IMP.PreexMarkerIngame.Start()
	IMP.PreexMarkerEditor.Start()
	IMP.ProvisionerManager.Start()
	IMP.RestrictedSandbox.Start()
	IMP.CommandMode.Start()
	IMP.WorkshopMode.Start()

	IMP_ModInstalledMESGn.Show(IMP.IMP_ModVersion.GetValue())
EndFunction


Function ResetMod()
	UninstallMod()
	Utility.Wait(2)
	InstallMod()
	IMP_ModResetMESGn.Show()
EndFunction