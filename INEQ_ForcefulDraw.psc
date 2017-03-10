Scriptname INEQ_ForcefulDraw extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	OptionsMenu	Auto

Spell	property	DrawSpell		Auto
Spell	property	DrawVisual		Auto
Spell	Property	RechargeVisual	Auto

Explosion	property	DLC1SC_LightningBoltImpactExplosion	Auto
Explosion	property	DLC1VampDetectLifeExplosion			Auto

bool	Property	bBalanced			Auto	Hidden
bool	Property	bUseCharges			Auto	Hidden
bool	Property	bUseTimer			Auto	Hidden

Float	Property	ChargeDistance		Auto	Hidden			; in feet
int		Property	ChargeTime			Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFChargeDistance	=	1000.0		Autoreadonly
int		Property	DEFChargeTime		=	300			Autoreadonly

String  Property	WeaponDrawn			=	"WeaponDraw"  	Autoreadonly		; Draw weapon

;===========================================  Variables  ============================================================================>
bool bRecharged

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterRecharge()
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced		= True
	bUseCharges		= True
	bUseTimer		= False
	bRecharged		= False
	ChargeDistance	= DEFChargeDistance
	ChargeTime		= DEFChargeTime
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	; Move to active state if alrady charged on equip
	Event OnBeginState()
		if(bRecharged)
			GoToState("Active")
		endif
	EndEvent
	
	; Override that additionally update's state
	Function OnDistanceTravelledEvent()
		CastRecharge()
		GoToState("Active")
	EndFunction

	; Override that additionally updates state
	Event OnUpdate()
		CastRecharge()
		GoToState("Active")
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Active

	Event OnBeginState()
		registerForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

	; If SelfRef is in combat and not sneaking, activate the ability then update state
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if selfRef.isInCombat() && !SelfRef.isSneaking()
			CastForcefulDraw()
			RegisterRecharge()
			GoToState("Equipped")
		else
			RechargeVisual.cast(SelfRef,SelfRef)
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Recharges ability for time-based recharge
Event OnUpdate()
	CastRecharge()
EndEvent
;___________________________________________________________________________________________________________________________

; Recharges ability for distance-based recharge
Function OnDistanceTravelledEvent()
	CastRecharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Toggles on the charge state, displays visuals and notifies the player
Function CastRecharge()
	RechargeVisual.cast(SelfRef,SelfRef)
	bRecharged = True
	Debug.Notification("Forceful Draw recharged!")
EndFunction
;___________________________________________________________________________________________________________________________

; Toggles charge state and plays the ability's visuals and force effect
Function CastForcefulDraw()
	selfRef.placeatme(DLC1SC_LightningBoltImpactExplosion)
	DrawVisual.cast(SelfRef,SelfRef)
	selfRef.placeatme(DLC1VampDetectLifeExplosion)
	DrawSpell.cast(selfRef)
	bRecharged = False
EndFunction
;___________________________________________________________________________________________________________________________

; Determins how to recharge the ability based on the settings
Function RegisterRecharge(bool bForced = False)
	if bUseCharges
		if bUseTimer
			RegisterForSingleUpdate(ChargeTime)
		else
			UnregisterForUpdate()
			RegisterForDistanceTravelledEvent(ChargeDistance, bForced)
		endif
	else
		RegisterForSingleUpdate(0.0)
	endif
EndFunction

;===============================================================================================================================
;====================================			Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		setButtonMain(Button)
		aiButton = OptionsMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9	; Cancel Menu
			MenuActive.SetValue(0)
		elseif aiButton == 1	; Turn on Balanced (Magicka Based)
			RestoreDefaultFields()
		elseif aiButton == 2	; Turn off Balanced (Cooldown Based)
			bBalanced = False
		elseif aiButton == 3	; Turn on charges
			bUseCharges = True
			bRecharged = True
		elseif aiButton == 4	; Turn off charges
			bUseCharges = False
			UnregisterForDistanceTravelledEvent()
		elseif aiButton == 5	; Turn on timer
			bUseTimer = True
			UnregisterForDistanceTravelledEvent()
		elseif aiButton == 6	; Turn off timer (use distance)
			bUseTimer = False
		elseif aiButton == 7	; Set Distance
			ChargeDistance = ListenerMenu.DistanceTravelledCost(ChargeDistance, DEFChargeDistance)
		elseif aiButton == 8	; Set time
			ChargeTime = ListenerMenu.ChargeTime(ChargeTime, DEFChargeTime)
		endif
	endwhile
	RegisterRecharge(True)
EndFunction

Function setButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		if bUseCharges
			Button.set(4)
			if bUseTimer
				Button.set(6)
				Button.set(8)
			else
				Button.set(5)
				Button.set(7)
			endif
		else
			Button.set(3)
		endif
	endif
	Button.set(9)
EndFunction
