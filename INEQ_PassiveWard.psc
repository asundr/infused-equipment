Scriptname INEQ_PassiveWard extends INEQ_AbilityBase  
{When equipped, provies a periodically recharging ward}

;===========================================  Properties  ===========================================================================>

Explosion Property crAtronachFrostExplosion auto

ImageSpaceModifier Property RechargeImod auto
Sound Property RechargeSoundFX auto

Quest Property SMART__EssentialPlayer auto

int 	Property threshhold 	= 	25 		auto	
int 	Property rechargeSeconds = 	4 		auto
float 	Property rangeMult 		= 	19.0	auto

;===========================================  Variables  ============================================================================>


ObjectReference EquipRef

float previousHealth
int InstanceID

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

;Event OnEffectStart (Actor akTarget, Actor akCaster)
;	selfRef = akCaster
;	GoToState( "Unequipped")
;EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SMART__EssentialPlayer.stop()
	RechargeImod.remove()
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		if(instanceID)
			Sound.StopInstance(InstanceID)
		endif
		SelfRef.placeatme(crAtronachFrostExplosion)
		RegisterForSingleUpdate(rechargeSeconds)
	EndEvent
	
	Event OnUpdate()
;		Debug.Notification("Passive ward recharged!")
		InstanceID = RechargeSoundFX.play(selfRef)      	; play RechargeSoundFX sound from player
		Sound.SetInstanceVolume(instanceID,1.0) 			; Play full volume
		RechargeImod.apply(0.5)     			 			; Recharge ImageMod , 50%
		GoToState("Active")
	EndEvent
	
EndState

; power series : https://en.wikipedia.org/wiki/Logarithm#Power_series			NOTE: might only work (0,2]
Float Function ApproximateNaturalLog(float x, float precision = 0.01, float divisor = 1.0)
	if x <= 0.0
		return -1.0
	endif
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
	return 2.0 * result
EndFunction
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
