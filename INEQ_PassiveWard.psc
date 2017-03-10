Scriptname INEQ_PassiveWard extends ActiveMagicEffect  
{When equipped, provies a periodically recharging ward}

;Import ARUNLib

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto

Explosion Property crAtronachFrostExplosion auto
Explosion Property SMART_ArmorPassiveWardBreak auto

ImageSpaceModifier Property RechargeImod auto
Sound Property RechargeSoundFX auto

FormList Property SMART__HealingSourcesKW auto
FormList Property SMART__CosmeticExplosions auto

Quest Property SMART__EssentialPlayer auto

int Property threshhold = 5 		auto
int Property rechargeSeconds = 10 	auto
int Property rangeMult = 2			auto

;===========================================  Variables  ============================================================================>

Actor selfRef
ObjectReference EquipRef

float currentHealth
float previousHealth
float difference
int InstanceID

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	selfRef = akCaster
	GoToState( "Unequipped")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

EndState
;___________________________________________________________________________________________________________________________

State Unequipped
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		EquipCheckKW(akReference)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Charging
	
	Event OnBeginState()
		RechargeImod.remove()
		if(instanceID)
			Sound.StopInstance(InstanceID)
		endif
		selfref.placeatme(crAtronachFrostExplosion)
		selfRef.RestoreActorValue("health", difference)
		SMART__EssentialPlayer.stop()
		RegisterForSingleUpdate(rechargeSeconds)
	EndEvent
	
	Event OnUpdate()
;		Debug.Notification("Passive ward recharged!")
		InstanceID = RechargeSoundFX.play(selfRef)      	; play TrapSoundFX sound from player
		Sound.SetInstanceVolume(instanceID,1.0) 			; Play full volume
		RechargeImod.apply(0.5)     			 			; Recharge ImageMod
		GoToState("Active")
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Active
	
	Event OnBeginState()
		previousHealth = selfRef.getActorValue("health")
		SMART__EssentialPlayer.start()
		RegisterForSingleUpdate(0.5)
		RegisterForAnimationEvent(selfRef, "CastStop")
	EndEvent
	
	Event OnUpdate()
		RechargeImod.remove()
	EndEvent
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		currentHealth = selfRef.getActorValue("health")
		difference = currentHealth - previousHealth
;		Debug.Notification(previousHealth+ " + " +difference+ " = " +currentHealth)
		
		if (akAggressor != selfRef)
			if !SMART__CosmeticExplosions.HasForm(akSource)
				if (currentHealth < 1)
					Debug.Notification("Saved From Death: " +akSource.getformID()+ " from: " +akAggressor.getFormID())
					if (akAggressor== None)
						Debug.Notification("Null Aggressor")
					endif
					GoToState("Charging")
				elseif (-difference > threshhold)
					Debug.Notification("Player hit above threshhold: " +((-difference) as int)+ "!")
					GoToState("Charging")
				endif
			else
;				Debug.Notification("Cosmetic explosion ignored")
			endif
		else
;			Debug.Notification("Hit self")
		endif
		previousHealth = selfRef.getActorValue("health")
	endEvent

	;Rather than check conditionally for healing spells/potions  just update health on every spell type
	Event OnSpellCast(Form akSpell)
;		Debug.Notification("Used healing Item/Potion")
		previousHealth = selfRef.getActorValue("health")
	EndEvent
	
	;To catch the end of concentration spells
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
;		Debug.Notification("Concentration event")
		if (akSource == selfRef) && (EventName == "CastStop")
;			Debug.Notification("End concentration cast")
			previousHealth = selfRef.getActorValue("health")
		endif
	EndEvent
	
	;Onequip : MagicEnchFortifyHealth, MagicEnchFortifyHealRate
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("Equip event...")
		previousHealth = selfRef.getActorValue("health")
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		previousHealth = selfRef.getActorValue("health")
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		RechargeImod.remove()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(selfRef, "CastStop")
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )
	if akReference.HasKeyword(KW_EnbaleAbility)
;		Debug.Notification("KW found: Ability effect active")
		EquipRef = akReference
		GoToState("Charging")
;	else
;		Debug.Notification("Missing KW: Effect not activated")
	endif
EndFunction

;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
;		Debug.Notification("Unequip event...")
		if (akReference == EquipRef)
;			Debug.Notification("Unequipped, effect disabled")
			EquipRef = none
			GoToState("Unequipped")
;		else
;			Debug.Notification("(" +akReference.getFormID()+ ") Not the equipped ref")
		endif
EndFunction

;===============================================================================================================================
;====================================		   Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SMART__EssentialPlayer.stop()
	RechargeImod.remove()
EndEvent


