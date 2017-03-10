Scriptname INEQ_PassiveWard extends INEQ_AbilityBase  
{When equipped, provies a periodically recharging ward}

;	Low protection - quick recharge requires high magicka regen: can recharge soon after every hit but requires high MP to get high 
;	regen and cant use it since MP must be full to recharge shield
;	High protection - long recharge should be able to recharge a few times an in-game day, or if a mage, once between each battle
;	
;	RegisterForAnimationEvent(pPlayer, "RemoveCharacterControllerFromWorld")
;	RegisterForAnimationEvent(pPlayer, "GetUpEnd")

;===========================================  Properties  ===========================================================================>

Explosion Property crAtronachFrostExplosion auto

ImageSpaceModifier Property RechargeImod auto
Sound Property RechargeSoundFX auto

Quest Property SMART__EssentialPlayer auto

ReferenceAlias	Property	MagickaSiphonAlias	Auto


int 	Property	threshhold 	= 	5 		auto	Hidden
float 	Property	rangeMult 	= 	99.0	auto	Hidden
float	Property	RechargeMP	=	100.0	Auto	Hidden	;Derived from threshold and chargemult
int		Property	RechargePR	=	90		Auto	Hidden

bool	Property	bUseTimer	=	False	Auto	Hidden
int 	Property	ChargeTime	= 	4 		auto	Hidden

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

INEQ_MagickaSiphon MagickaSiphon

float previousHealth
int InstanceID




;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
	MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
	
;	Utility.wait(5.0)
;	float i = 1.0
;	while i <= 5.0
;		Debug.Trace("ln(" +i+ ") = " +ApproximateNaturalLog(i,0.001))
;		i += 0.1
;	endwhile
	
;	Debug.Trace("ln(10.0) = " +ApproximateNaturalLog(10,0.001))
;	Debug.Trace("ln(50) = " +ApproximateNaturalLog(50,0.001))
;	Debug.Trace("ln(100) = " +ApproximateNaturalLog(100,0.001))
;	Debug.Trace("ln(500) = " +ApproximateNaturalLog(500,0.001))
;	Debug.Trace("ln(1,000) = " +ApproximateNaturalLog(1000,0.001))
;	Debug.Trace("ln(10,000) = " +ApproximateNaturalLog(10000,0.001))
;	Debug.Trace("ln(100,000) = " +ApproximateNaturalLog(100000,0.001))
;	Debug.Trace("ln(1,000,000) = " +ApproximateNaturalLog(1000000,0.001))
;	Debug.Trace("ln(1,000,000,000) = " +ApproximateNaturalLog(1000000000,0.001))
	
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SMART__EssentialPlayer.stop()
	RechargeImod.remove()
	MagickaSiphon.UnregisterForEvent(self)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

Auto State Unequipped
	
	; Unregisters recahrge if armor is unequipped (not an overwrite)
	Event OnBeginState()
		MagickaSiphon.UnregisterForEvent(self)
	EndEvent
	
EndState
;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		if(instanceID)
			Sound.StopInstance(InstanceID)
		endif
		SelfRef.placeatme(crAtronachFrostExplosion)
		if bUseTimer
			RegisterForSingleUpdate(ChargeTime)
		else
			MagickaSiphon.RegisterForEvent(self, RechargeMP, RechargePR)
		endif
	EndEvent
	
	Function OnMagickaSiphonEvent()
		;Debug.Notification("Passive ward recharged!")
		InstanceID = RechargeSoundFX.play(selfRef)      	; play RechargeSoundFX sound from player
		Sound.SetInstanceVolume(instanceID,1.0) 			; Play full volume
		RechargeImod.apply(0.5)     			 			; Recharge ImageMod , 50%
		GoToState("Active")
	EndFunction
	
	Event OnUpdate()
		;Debug.Notification("Passive ward recharged!")
		InstanceID = RechargeSoundFX.play(selfRef)      	; play RechargeSoundFX sound from player
		Sound.SetInstanceVolume(instanceID,1.0) 			; Play full volume
		RechargeImod.apply(0.5)     			 			; Recharge ImageMod , 50%
		GoToState("Active")
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State Active
	
	Event OnBeginState()
		previousHealth = selfRef.getActorValue("health")
		SMART__EssentialPlayer.start()
		RegisterForSingleUpdate(0.5)
		RegisterForAnimationEvent(selfRef, "CastStop")	;To catch the end of concentration spells
		RegisterForAnimationEvent(selfRef, "JumpDown")
	EndEvent
	
	Event OnUpdate()
		RechargeImod.remove()
	EndEvent
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		processHit()
	endEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)	
		if EventName == "CastStop"
			previousHealth = selfRef.getActorValue("health")
		elseif EventName == "JumpDown"
			processHit()
		endif
	EndEvent

;	==== Various checks for health updates	====

	Event OnSpellCast(Form akSpell)
;		Debug.Notification("Used healing Item/Potion")	;Rather than check conditionally for healing spells/potions  just update health on every spell type
		previousHealth = selfRef.getActorValue("health")
	EndEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)		;Onequip : MagicEnchFortifyHealth, MagicEnchFortifyHealRate
		previousHealth = selfRef.getActorValue("health")
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		previousHealth = selfRef.getActorValue("health")
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		SMART__EssentialPlayer.Stop()
		RechargeImod.remove()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(SelfRef, "CastStop")
		UnregisterForAnimationEvent(SelfRef, "JumpDown")
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

Function processHit()
	float currentHealth = selfRef.getActorValue("health")
	if (currentHealth > 0 )
		float difference = currentHealth - previousHealth
		if (-difference > threshhold)  && (-difference  < threshhold * (1+rangeMult) )
			Debug.Notification("Player hit within (" +threshhold+ ", " +(threshhold*(1+rangeMult) as int)+ "): " +((-difference) as int)+ "!")
			SelfRef.RestoreActorValue("health", difference)
			GoToState("Equipped")
		else
			Debug.Notification(((-difference) as int) + " damage")
		endif
	else
		if SelfRef.GetAnimationVariableBool("IsBleedingOut")
			float healthlost = currentHealth / SelfRef.getActorValuePercentage("Health")- previousHealth
			SelfRef.ResetHealthAndLimbs()
			SelfRef.DamageActorValue("Health", healthlost)
		else
			Game.ForceThirdPerson()
		endif
		GoToState("Equipped")
	endif
	previousHealth = selfRef.getActorValue("health")
EndFunction
;___________________________________________________________________________________________________________________________

; Finds the natural log of a number to the specified precision.
; Takes advantage of ln(n) = ln(xy) = ln(x) + ln(y), where y = ln(10^a) = a*ln(10)
Float Function ApproximateNaturalLog(float x, float precision = 0.01, float divisor = 1.0)
	float y = 0
	;float b = 10.0
	if x == 0.0
		return -1.0
	endif
	
	if x > 10.0
		; more efficient than looping for every order of magnitude
		if x > 100000000.0
			x /= 100000000.0
			y += 8
		endif
		if x > 10000.0
			x /= 10000.0
			y += 4
		endif
		if x > 100.0
			x/= 100.0
			y += 2
		endif
		if x > 10.0
			x/= 10.0
			y += 1
		endif
		y *= 2.30258509299	; ln(10) pre-evaluated	;ApproximateNaturalLog(b)
	endif
	
	; Power series (accurate for small numbers) : https://en.wikipedia.org/wiki/Logarithm#Power_series
	precision *= 2 ; since we double the result at the end	
	float term = (x - 1) / (x + 1) 	
	float result = term
	float step = term * term
	float delta = precision	
	while delta >= precision	
		term *= step	
		divisor += 2	
		delta = term / divisor	
		result += delta	
	endWhile	
	return 2.0 * result + y
EndFunction
