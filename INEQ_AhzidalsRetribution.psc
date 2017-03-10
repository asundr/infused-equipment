Scriptname INEQ_AhzidalsRetribution extends INEQ_AbilityBase
{Adds Ahzidal's Retribution's random paralysis on hit effect}

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu	Auto

Keyword	property	WeapTypeBow						Auto
Spell	property	DLC2dunKolbjornArmorParalyze	Auto
Sound	property	MAGParalysisEnchantment			Auto

bool	Property	bBalanced		=	True	Auto	Hidden
float	Property	EffectChance	=	0.05	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFEffectChance	=	0.05	Autoreadonly

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
	RegisterAbilityToAlias()
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterAbilityToAlias()
EndEvent

Function RestoreDefaultFields()
	bBalanced = True
	EffectChance = DEFEffectChance
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if ((akSource as Weapon) != None && !akSource.HasKeyword(WeapTypeBow) && (akAggressor as Actor) != None)
			float rand = Utility.RandomFloat(0,1)
			if (rand < EffectChance)
				MAGParalysisEnchantment.Play(akAggressor)
				DLC2dunKolbjornArmorParalyze.Cast(akAggressor)
			EndIf
		EndIf
	EndEvent

EndState

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu)
	bool abMenu = True
	int aiButton
	while abMenu
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1		; Turn on Balanced
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Set HP Threshhold
			EffectChance = ListenerMenu.SetPercentage(EffectChance, DEFEffectChance, "Efect Chance")
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
EndFunction