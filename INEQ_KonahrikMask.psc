Scriptname INEQ_KonahrikMask extends INEQ_AbilityBase  

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu		Auto

float	property	HPthreshold		=	0.10	Auto	Hidden
float	property	EffectChance	= 	0.10	Auto	Hidden
float	property	RareEffectChance	= 0.02	Auto	Hidden

Explosion property fakeForceBall1024 auto

Spell property flameCloak auto
Spell property GrandHealing auto
Spell property rareSpell  auto

MagicEffect property DragonPriestMaskFireCloakFFSelf Auto
MagicEffect property rareEffect auto

bool	Property	bBalanced	=	True	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
Float	Property	DEFHPThreshold		=	0.10	Autoreadonly	; vanilla 0.20
Float	Property	DEFEffectChance		=	0.10	Autoreadonly	; vanilla 0.25
Float	Property	DEFRareEffectChance	=	0.02	Autoreadonly	; vanilla 0.05

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterAbilityToAlias()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	UnregisterAbilityToAlias()
EndEvent

Function RestoreDefaultFields()
	bBalanced = True
	HPthreshold = DEFHPThreshold
	EffectChance = DEFEffectChance
	RareEffectChance = DEFRareEffectChance
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if (selfRef.getActorValuePercentage("Health") < HPthreshold) && !SelfRef.HasMagicEffect(DragonPriestMaskFireCloakFFSelf) && !SelfRef.isDead()
			float rand = utility.RandomFloat(0,1)
			if rand <= effectChance
				;selfRef.placeAtMe(fakeForceBall1024)
				selfRef.knockAreaEffect(1,1024)
				GrandHealing.cast(selfRef,selfRef)
				flameCloak.cast(selfRef,selfRef)		
			endif
			if rand <= rareEffectChance && !(selfRef.hasMagicEffect(rareEffect))
				rareSpell.cast(selfRef,selfRef)
			endif
		endif
	endEvent
	
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
			bBalanced = True
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Set HP Threshhold
			HPthreshold = ListenerMenu.SetPercentage(HPthreshold, DEFHPthreshold, "HP Threshold")
		elseif aiButton == 4		; Set Effect Threshhold
			EffectChance = ListenerMenu.SetPercentage(EffectChance, DEFEffectChance, "Effect")
		elseif aiButton == 5		; Set Rare Effect Threshhold
			RareEffectChance = ListenerMenu.SetPercentage(RareEffectChance, DEFRareEffectChance, "Rare Effect")
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
		Button.set(4)
		Button.set(5)
	endif
EndFunction