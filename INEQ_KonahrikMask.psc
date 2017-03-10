Scriptname INEQ_KonahrikMask extends INEQ_AbilityBase  
{Procs an effect and rare effect if hit under a HP threshold}

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu		Auto

Spell	Property	flameCloak		Auto
Spell	Property	GrandHealing	Auto
Spell	Property	rareSpell		Auto

MagicEffect	Property	DragonPriestMaskFireCloakFFSelf	Auto
MagicEffect	Property	rareEffect						Auto

float	Property	HPthreshold			=	0.10	Auto	Hidden
float	Property	EffectChance		= 	0.10	Auto	Hidden
float	Property	RareEffectChance	=	0.02	Auto	Hidden
float	Property	CooldownTime		=	60.0	Auto	Hidden

bool	Property	bBalanced	=	True	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
Float	Property	DEFHPThreshold		=	0.10	Autoreadonly	; vanilla 0.20
Float	Property	DEFEffectChance		=	0.10	Autoreadonly	; vanilla 0.25
Float	Property	DEFRareEffectChance	=	0.02	Autoreadonly	; vanilla 0.05

Float	Property	DEFCooldownTime		=	60.0	Autoreadonly	; flamecloak 60s long

;===========================================  Variables  ============================================================================>
bool bCharged = True

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
EndEvent

Function RestoreDefaultFields()
	bBalanced		= True
	HPthreshold		= DEFHPThreshold
	EffectChance	= DEFEffectChance
	RareEffectChance= DEFRareEffectChance
	CooldownTime	= DEFCooldownTime
	bCharged		= False
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		if !bCharged
			GoToState("Cooldown")
		endif
	EndEvent

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if (SelfRef.getActorValuePercentage("Health") < HPthreshold) && !SelfRef.HasMagicEffect(DragonPriestMaskFireCloakFFSelf) && !SelfRef.isDead()
			float rand = Utility.RandomFloat(0,1)
			if rand < effectChance
				SelfRef.knockAreaEffect(1,1024)
				GrandHealing.cast(SelfRef,SelfRef)
				flameCloak.cast(SelfRef,SelfRef)	
				GoToState("Cooldown")
			endif
			if rand < rareEffectChance && !(SelfRef.hasMagicEffect(rareEffect))
				rareSpell.cast(SelfRef,SelfRef)
			endif

		endif
	endEvent
	
EndState

State Cooldown
	
	Event OnBeginState()
		RegisterForSingleUpdate(CooldownTime)
	EndEvent
	
	Event OnUpdate()
		GoToState("Equipped")
	EndEvent

EndState

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
	Button.set(9)
EndFunction
