Scriptname INEQ_MehrunesRazor extends INEQ_AddPerkOnEquip1H
{Probabilistically kills target if the target is not immune}

;===========================================  Properties  ===========================================================================>
Message			Property	MainMenu	Auto
GlobalVariable	Property	KillChance	Auto

;==========================================  Autoreadonly  ==========================================================================>
int		Property	DEFKillChance	=	2		Autoreadonly

;===========================================  Variables  ============================================================================>
bool bBalanced

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced = True
	KillChance.SetValueInt(DEFKillChance)
EndFunction

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9		; Cancel Menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Turn on Balanced
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Kill Chance
			KillChance.Value = (ListenerMenu.SetPercentage(KillChance.GetValue()/100.0, DEFKillChance / 100.0, "kill chance") * 100) as int
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		Button.set(3)
	endif
	Button.set(9)
EndFunction
