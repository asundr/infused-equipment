Scriptname INEQ_PassiveWard extends INEQ_AbilityBase  
{When equipped, provies a periodically recharging ward}

;	Low protection - quick recharge requires high magicka regen: can recharge soon after every hit but requires high MP to get high 
;	regen and cant use it since MP must be full to recharge shield
;	High protection - long recharge should be able to recharge a few times an in-game day, or if a mage, once between each battle
;	
;	RegisterForAnimationEvent(pPlayer, "RemoveCharacterControllerFromWorld")
;	RegisterForAnimationEvent(pPlayer, "GetUpEnd")

;===========================================  Properties  ===========================================================================>
GlobalVariable	Property	TimeScale	Auto

Explosion Property crAtronachFrostExplosion auto
ImageSpaceModifier Property RechargeImod auto
Sound Property RechargeSoundFX auto

Quest Property SMART__EssentialPlayer auto

ReferenceAlias	Property	MagickaSiphonAlias	Auto

Message	Property	OptionsMenu			Auto
Message Property	TimeOptions			Auto
Message	Property	ThreshholdOptions	Auto
Message	Property	RangeOptions		Auto
Message	Property	PriorityOptions		Auto

bool	Property	bBalanced	=	True	Auto	Hidden

int 	Property	Threshhold 	= 	5 		Auto	Hidden
int 	Property	Range 		= 	30		Auto	Hidden
float	Property	RechargeMP				Auto	Hidden	;Derived from threshold and chargemult
int		Property	RechargePR	=	90		Auto	Hidden
int 	Property	ChargeTime	= 	120 	auto	Hidden

int		Property	DEFThreshhold	=	5	Autoreadonly
int		Property	DEFRange		=	30	Autoreadonly
int		Property	DEFRechargePR	=	90	Autoreadonly
int		Property	DEFChargeTime	=	120	Autoreadonly

float	Property	SecondsInDay	=	86400.0	Autoreadonly	Hidden
String	Property	CastStop	=	"CastStop"	Autoreadonly	Hidden
String	Property	JumpDown	=	"JumpDown"	Autoreadonly	Hidden

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

INEQ_MagickaSiphon MagickaSiphon

float previousHealth
float maximumHealth
float rateHealth
float previousTime

int InstanceID

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
	GetMagickaCost()
	MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
	RegisterAbilityToAlias()
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SMART__EssentialPlayer.stop()
	RechargeImod.remove()
	MagickaSiphon.UnregisterForEvent(self)
	UnregisterAbilityToAlias()
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
		if bBalanced
			MagickaSiphon.RegisterForEvent(self, RechargeMP, RechargePR)
		else
			RegisterForSingleUpdate(ChargeTime)
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
		UpdateFields()
		SMART__EssentialPlayer.start()
		RechargeImod.remove()
		RegisterForAnimationEvent(selfRef, CastStop)	; To catch the end of concentration spells
		RegisterForAnimationEvent(selfRef, JumpDown)	; To handle fall damage
	EndEvent
	
	Event OnUpdate()
		UpdateFields()
	EndEvent
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		processHit()
	endEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)	
		if EventName == CastStop
			UpdateFields()
		elseif EventName == JumpDown
			processHit()
		endif
	EndEvent

;	==== Various checks for health updates	====

	;Rather than check conditionally for healing spells/potions  just update fields on every spell type
	Event OnSpellCast(Form akSpell)
		UpdateFields()
	EndEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		UpdateFields()
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UpdateFields()
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		SMART__EssentialPlayer.Stop()
		RechargeImod.remove()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(SelfRef, CastStop)
		UnregisterForAnimationEvent(SelfRef, JumpDown)
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Returns the sum of previousHealth and health regenerated since the last UpdateFields()
float Function getRegenHealth()
	float timedif = ((Utility.GetCurrentGameTime() - previousTime) / TimeScale.Value) * SecondsInDay
	float regenHealth = previousHealth + TimeDif * rateHealth
	if regenHealth < maximumHealth
		return  regenHealth
	else
		return maximumHealth
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Updates the previous values for health and health regeneration rate
Function UpdateFields()
	UnregisterForUpdate()
	previousHealth = SelfRef.GetActorValue("Health")
	if previousHealth
		maximumHealth = previousHealth / SelfRef.GetActorValuePercentage("Health")
	else
		SelfRef.RestoreActorValue("Health", 1.0)
		maximumHealth = previousHealth / SelfRef.GetActorValuePercentage("Health")
		SelfRef.DamageActorValue("Health", 1.0)
	endif
	rateHealth = maximumHealth * SelfRef.GetActorValue("HealRate") * SelfRef.GetActorValue("HealRateMult") / 10000.0
	if SelfRef.isInCombat()
		rateHealth *= 0.7
		RegisterForSingleUpdate(10.0) ; Ensures rateHealth is returned to normal outside of combat
	endif
	previousTime = Utility.GetCurrentGameTime()
EndFunction
;___________________________________________________________________________________________________________________________

; Determine's the damage of the hit then uses the ward if within threshhold conditions are met
Function processHit()
	float currentHealth = selfRef.getActorValue("health")
	if (currentHealth > 0 )
		float difference = getRegenHealth() - currentHealth
		if (difference > Threshhold)
			if difference  < Threshhold + Range
				Debug.Notification("Player hit within (" +Threshhold+ ", " +((Threshhold + Range) as int)+ "): " +(difference as int)+ "!")
				SelfRef.RestoreActorValue("health", difference)
				GoToState("Equipped")
			else
				UpdateFields()
			endif
		else
			if difference > 1
				Debug.Notification((difference as int) + " damage")
			endif
			UpdateFields()
		endif
	else
		if SelfRef.GetAnimationVariableBool("IsBleedingOut")
			float healthLost = maximumHealth - getRegenHealth()
			SelfRef.ResetHealthAndLimbs()
			SelfRef.DamageActorValue("Health", healthlost)
		else
			Game.ForceThirdPerson()
		endif
		GoToState("Equipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Calculates the cost in magicka 
float function GetMagickaCost()
	float num = Threshhold + Math.Pow(Range, 3.0)
	RechargeMP =  20.0 * NaturalLog(num)
	return RechargeMP
endFunction
;___________________________________________________________________________________________________________________________

; Finds the natural log of a number to the specified precision.
; Takes advantage of ln(n) = ln(xy) = ln(x) + ln(y), where y = ln(10^a) = a*ln(10)
Float Function NaturalLog(float x, float precision = 0.01, float divisor = 1.0)
	float y = 0
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
		y *= 2.30258509299	; ln(10) pre-evaluated
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

;===============================================================================================================================
;====================================			Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button = none)
	bool abMenu = True
	int aiButton
	while abMenu
		setButton(Button)
		aiButton = OptionsMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1	; Turn on Balanced (Magicka Based)
			bBalanced = True
		elseif aiButton == 2	; Turn off Balanced (Cooldown Based)
			bBalanced = False
		elseif aiButton == 3	; Set Cooldown length
			MenuTime()
		elseif aiButton == 4	; Set Threshhold
			MenuThreshhold()
		elseif aiButton == 5	; Set range
			MenuRange()
		elseif aiButton == 6	; Set Priority
			MenuPriority()
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButton(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
		Button.set(6)
	else
		Button.set(1)
		Button.set(3)
	endif
	Button.set(4)
	Button.set(5)
EndFunction

; Allows player to set time for cooldown
Function MenuTime()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent cooldown timer: " +ChargeTime)
		aiButton = TimeOptions.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			ChargeTime -= 1000
		elseif aiButton == 2
			ChargeTime -= 100
		elseif aiButton == 3
			ChargeTime -= 10
		elseif aiButton == 4
			ChargeTime -= 1
		elseif aiButton == 5
			ChargeTime += 1
		elseif aiButton == 6
			ChargeTime += 10
		elseif aiButton == 7
			ChargeTime += 100
		elseif aiButton == 8
			ChargeTime += 1000
		elseif aiButton == 9
			ChargeTime = DEFChargeTime
		endif
		if ChargeTime < 1
			ChargeTime = 1
		endif
	endwhile
endFunction

; Allows player to set minimum damage threshhold for protection from ward
Function MenuThreshhold()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent minimum damage threshhold: " +Threshhold)
		aiButton = ThreshholdOptions.Show()
		if aiButton == 0
			GetMagickaCost()
			Debug.MessageBox("Magicka cost: " +RechargeMP)
			return
		elseif aiButton == 1
			Threshhold -= 1000
		elseif aiButton == 2
			Threshhold -= 100
		elseif aiButton == 3
			Threshhold -= 10
		elseif aiButton == 4
			Threshhold -= 1
		elseif aiButton == 5
			Threshhold += 1
		elseif aiButton == 6
			Threshhold += 10
		elseif aiButton == 7
			Threshhold += 100
		elseif aiButton == 8
			Threshhold += 1000
		elseif aiButton == 9
			Threshhold = DEFThreshhold
		endif
		if Threshhold < 1
			Threshhold = 1
		endif
	endwhile
EndFunction

; Allows player to set range of damage protection from ward
Function MenuRange()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent protection range: " +Range)
		aiButton = RangeOptions.Show()
		if aiButton == 0
			GetMagickaCost()
			Debug.MessageBox("Magicka cost: " +RechargeMP)
			return
		elseif aiButton == 1
			Range -= 1000
		elseif aiButton == 2
			Range -= 100
		elseif aiButton == 3
			Range -= 10
		elseif aiButton == 4
			Range -= 1
		elseif aiButton == 5
			Range += 1
		elseif aiButton == 6
			Range += 10
		elseif aiButton == 7
			Range += 100
		elseif aiButton == 8
			Range += 1000
		elseif aiButton == 9
			Range = DEFRange
		endif
		if Range < 1
			Range = 1
		endif
	endwhile
EndFunction

; Allows player to set priority for magicka siphon, migher means sooner
Function MenuPriority()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent priority: " +RechargePR)
		aiButton = PriorityOptions.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			RechargePR -= 50
		elseif aiButton == 2
			RechargePR -= 10
		elseif aiButton == 3
			RechargePR -= 5
		elseif aiButton == 4
			RechargePR -= 1
		elseif aiButton == 5
			RechargePR += 1
		elseif aiButton == 6
			RechargePR += 5
		elseif aiButton == 7
			RechargePR += 10
		elseif aiButton == 8
			RechargePR += 50
		elseif aiButton == 9
			RechargePR = DEFRechargePR
		endif
	endwhile
EndFunction
