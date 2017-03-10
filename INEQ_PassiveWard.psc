Scriptname INEQ_PassiveWard extends INEQ_AbilityBase  
{When equipped, provies a periodically recharging ward}

;	Low protection - quick recharge requires high magicka regen: can recharge soon after every hit but requires high MP to get high 
;	regen and cant use it since MP must be full to recharge shield
;	High protection - long recharge should be able to recharge a few times an in-game day, or if a mage, once between each battle
;	
;	RegisterForAnimationEvent(pPlayer, "RemoveCharacterControllerFromWorld")
;	RegisterForAnimationEvent(pPlayer, "GetUpEnd")

;===========================================  Properties  ===========================================================================>
Message	Property	OptionsMenu			Auto
Message	Property	ThresholdOptions	Auto
Message	Property	RangeOptions		Auto

Quest	Property	SMART__EssentialPlayer	Auto
GlobalVariable		Property	TimeScale	Auto

Sound				Property	RechargeSoundFX	Auto
ImageSpaceModifier	Property	RechargeImod	Auto
Explosion			Property	crAtronachFrostExplosion	Auto

bool	Property	bBalanced		Auto	Hidden

int 	Property	ChargeTime		Auto	Hidden
int 	Property	Threshold 		Auto	Hidden
int 	Property	Range 			Auto	Hidden
int		Property	RechargePR		Auto	Hidden
float	Property	RechargeMP		Auto	Hidden	;Derived from threshold and chargemult
;==========================================  Autoreadonly  ==========================================================================>
int		Property	DEFChargeTime	=	120	Autoreadonly
int		Property	DEFThreshold	=	5	Autoreadonly
int		Property	DEFRange		=	30	Autoreadonly
int		Property	DEFRechargePR	=	90	Autoreadonly

float	Property	SecondsInDay	=	86400.0		Autoreadonly

String	Property	CastStop		=	"CastStop"	Autoreadonly
String	Property	JumpDown		=	"JumpDown"	Autoreadonly
;===========================================  Variables  ============================================================================>
float previousHealth
float maximumHealth
float rateHealth
float previousTime

int InstanceID
;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SMART__EssentialPlayer.stop()
	RechargeImod.remove()
	parent.EffectFinish(akTarget, akCaster)
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced	= True
	Threshold	= DEFThreshold
	Range		= DEFRange
	RechargePR	= DEFRechargePR
	ChargeTime	= DEFChargeTime
	GetMagickaCost()
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

Auto State Unequipped
	
	; Unregisters recahrge if armor is unequipped (not an overwrite)
	Event OnBeginState()
		UnregisterForMagickaSiphonEvent()
	EndEvent
	
EndState
;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		if(instanceID)
			Sound.StopInstance(InstanceID)
			InstanceID = 0
		endif
		SelfRef.placeatme(crAtronachFrostExplosion)
		RegisterRecharge()
	EndEvent
	
	Function OnMagickaSiphonEvent()
		ActivateWard()
	EndFunction
	
	Event OnUpdate()
		ActivateWard()
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

; Registers for a recharege depending on the settings
Function RegisterRecharge(bool bForced = False)
	if GetState() == "Equipped"
		if bBalanced
			RegisterForMagickaSiphonEvent(RechargeMP, RechargePR, bForced)
		else
			RegisterForSingleUpdate(ChargeTime)
		endif
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Puts ward into active state and plays associated visuals
Function ActivateWard()
	;Debug.Notification("Passive ward recharged!")
	InstanceID = RechargeSoundFX.play(selfRef)      	; play RechargeSoundFX sound from player
	Sound.SetInstanceVolume(instanceID,1.0) 			; Play full volume
	RechargeImod.apply(0.5)     			 			; Recharge ImageMod , 50%
	GoToState("Active")
EndFunction
;___________________________________________________________________________________________________________________________

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

; Determine's the damage of the hit then uses the ward if within Threshold conditions are met
Function processHit()
	float currentHealth = selfRef.getActorValue("health")
	if (currentHealth > 0 )
		float difference = getRegenHealth() - currentHealth
		if (difference > Threshold)
			if difference  < Threshold + Range
				Debug.Notification("Player hit within (" +Threshold+ ", " +((Threshold + Range) as int)+ "): " +(difference as int)+ "!")
				SelfRef.RestoreActorValue("health", difference)
				GoToState("Equipped")
			else
				UpdateFields()
			endif
		else
			if difference > 1
				;Debug.Notification((difference as int) + " damage")
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
	RechargeMP = Math.Pow(Threshold, 2)/150.0 + 250.0*NaturalLog(Range) + 0.25*Range
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

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		setButton(Button)
		aiButton = OptionsMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9
			MenuActive.SetValue(0)
		elseif aiButton == 1	; Turn on Balanced (Magicka Based)
			RestoreDefaultFields()
		elseif aiButton == 2	; Turn off Balanced (Cooldown Based)
			bBalanced = False
		elseif aiButton == 3	; Set Cooldown length
			ChargeTime = ListenerMenu.ChargeTime(ChargeTime, DEFChargeTime)
		elseif aiButton == 4	; Set Threshold
			MenuThreshold()
		elseif aiButton == 5	; Set range
			MenuRange()
		elseif aiButton == 6	; Set Priority
			RechargePR = ListenerMenu.MagickaSiphonPriority(RechargePR, DEFRechargePR)
		endif
	endwhile
	RegisterRecharge(True)
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
	Button.set(9)
EndFunction
;___________________________________________________________________________________________________________________________

; Allows player to set minimum damage Threshold for protection from ward
Function MenuThreshold()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent minimum damage Threshold: " +Threshold+ " damage")
		aiButton = ThresholdOptions.Show()
		if aiButton == 0
			GetMagickaCost()
			Debug.MessageBox("Magicka cost: " +RechargeMP)
			return
		elseif aiButton == 1
			Threshold -= 50
		elseif aiButton == 2
			Threshold -= 10
		elseif aiButton == 3
			Threshold -= 5
		elseif aiButton == 4
			Threshold -= 1
		elseif aiButton == 5
			Threshold += 1
		elseif aiButton == 6
			Threshold += 5
		elseif aiButton == 7
			Threshold += 10
		elseif aiButton == 8
			Threshold += 50
		elseif aiButton == 9
			Threshold = DEFThreshold
		endif
		if Threshold < 1
			Threshold = 1
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Allows player to set range of damage protection from ward
Function MenuRange()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent protection range: " +Range+ " damage")
		aiButton = RangeOptions.Show()
		if aiButton == 0
			GetMagickaCost()
			Debug.MessageBox("Magicka cost: " +RechargeMP)
			return
		elseif aiButton == 1
			Range -= 50
		elseif aiButton == 2
			Range -= 10
		elseif aiButton == 3
			Range -= 5
		elseif aiButton == 4
			Range -= 1
		elseif aiButton == 5
			Range += 1
		elseif aiButton == 6
			Range += 5
		elseif aiButton == 7
			Range += 10
		elseif aiButton == 8
			Range += 50
		elseif aiButton == 9
			Range = DEFRange
		endif
		if Range < 1
			Range = 1
		endif
	endwhile
EndFunction
