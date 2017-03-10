Scriptname INEQ_BloodskalBlade extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu			Auto
Message Property	ChargeOptionsMenu	Auto

Spell	Property	DLC2BloodskalBladeSpellHoriz	Auto
Spell	Property	DLC2BloodskalBladeSpellVert		Auto

ReferenceAlias	Property	SharedChargesAlias		Auto

bool	Property	bBalanced		=	True	Auto	Hidden
bool	Property	bUseCharges		=	True	Auto	Hidden

int		Property	ChargeMode		=	0		Auto	Hidden	; 0=shared charges, 1=prioritize local, 2=only use local charges
Int		Property	ChargeCost		=	2		Auto	Hidden
float	Property	ChargeDistance	=	100.0	Auto	Hidden	; 1000.0, should be high relative to ChargeMagickaSiphon
float	Property	ChargeMagickaMP =	50.0	Auto	Hidden
int		Property	ChargeMagickaPR =	50		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>

int		Property	DEFChargeMode		=	0		Autoreadonly
int		Property	DEFMaxLocalCharge	=	4		Autoreadonly
int		Property	DEFChargeCost		=	2		Autoreadonly
float	Property	DEFChargeDistance	=	5000.0	Autoreadonly
float	Property	DEFChargeMagickaMP	=	2000.0	Autoreadonly
int		Property	DEFChargeMagickaPR	=	50		Autoreadonly


String  Property WeaponSwing  = 	"weaponSwing"  					Autoreadonly	; weapon attack
String	Property PWStanding2H	= 	"AttackPowerStanding_FXstart"	Autoreadonly
String	Property PWRight2H		= 	"AttackPowerRight_FXstart"		Autoreadonly
String	Property PWLeft2H		= 	"AttackPowerLeft_FXstart"		Autoreadonly
String	Property PWForward2H	= 	"AttackPowerForward_FXstart"	Autoreadonly
String	Property PWBackward2H	= 	"AttackPowerBackward_FXstart"	Autoreadonly

;===========================================  Variables  ============================================================================>
;ObjectReference EquipRef

INEQ_SharedCharges SharedCharges

;===============================================================================================================================
;====================================		  Start/Finish		================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	RegisterAbilityToAlias()
	RestoreDefaultFields()
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForDistanceTravelledEvent()
	UnregisterForMagickaSiphonEvent()
	UnregisterAbilityToAlias()
	unregisterForAnimationEvent(SelfRef, PWStanding2H)
	unregisterForAnimationEvent(SelfRef, PWRight2H)
	unregisterForAnimationEvent(SelfRef, PWLeft2H)
	unregisterForAnimationEvent(SelfRef, PWBackward2H)
	unregisterForAnimationEvent(SelfRef, PWForward2H)
	UnregisterForAnimationEvent(selfRef, WeaponSwing)
EndEvent

Function RestoreDefaultFields()
	MaxLocalCharge	=	DEFMaxLocalCharge
	LocalCharge		=	0
EndFunction

Event OnPlayerLoad()
	Maintenance()
EndEvent

Function Maintenance()
	parent.Maintenance()
	;RegisterForDistanceTravelledEvent(ChargeDistance)
	;RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
	RegisterForRecharge()
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		int itemType = SelfRef.getEquippedItemType(1)
		if itemType == 5
			GoToState("Equipped2HGreatsword")
		elseif itemType == 6
			GoToState("Equipped2HOther")
		elseif itemType > 0 && itemType < 5
			GoToState("Equipped1H")
		endif
		;RegisterForDistanceTravelledEvent(ChargeDistance)
		;RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
		RegisterForRecharge()
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Equipped1H

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if !bUseCharges || hasCharge()
				if SelfRef.GetAnimationVariableFloat("Speed") == 0
					DLC2BloodskalBladeSpellVert.cast(selfRef)
				else
					float direction = selfRef.GetAnimationVariableFloat( "Direction" )
					if (direction == 0.25 || direction == 0.75)
						DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
					else
						DLC2BloodskalBladeSpellVert.cast(selfRef)
					endif
				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State Equipped2HOther

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if !bUseCharges || hasCharge()
				if SelfRef.GetAnimationVariableFloat("Speed") == 0
					DLC2BloodskalBladeSpellVert.cast(SelfRef)
				else
					float direction = selfRef.GetAnimationVariableFloat( "Direction" )
					if (direction == 0.00 || direction == 1.00)
						DLC2BloodskalBladeSpellVert.cast(selfRef)
					;elseif (direction == 0.25 || direction == 0.75 || direction == 0.5)
					else
						DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
					endif
				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Equipped2HGreatsword

	Event OnBeginState()
		registerForAnimationEvent(SelfRef, PWStanding2H)
		registerForAnimationEvent(SelfRef, PWRight2H)
		registerForAnimationEvent(SelfRef, PWLeft2H)
		registerForAnimationEvent(SelfRef, PWBackward2H)
		registerForAnimationEvent(SelfRef, PWForward2H)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if !bUseCharges || hasCharge()
			if EventName == PWStanding2H|| EventName == PWForward2H 
				DLC2BloodskalBladeSpellVert.cast(selfRef)
			;elseif EventName == PWBackward2H || EventName == PWRight2H || EventName == PWLeft2H
			else
				DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
			endif
		endif
	EndEvent
	
	Event OnEndState()
		unregisterForAnimationEvent(SelfRef, PWStanding2H)
		unregisterForAnimationEvent(SelfRef, PWRight2H)
		unregisterForAnimationEvent(SelfRef, PWLeft2H)
		unregisterForAnimationEvent(SelfRef, PWBackward2H)
		unregisterForAnimationEvent(SelfRef, PWForward2H)
	EndEvent
	
EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Returs whether the necessary charges were obtained
bool function hasCharge()
	Debug.Trace("BLOODSKAL: HASCHARGE() ACCESSED")
	if ChargeMode == 0		;shared priority
		; Attempts to use both from shared first if available
		; else uses last from shared and a charge from local if available
		; else attempts to use both from local
		return SharedCharges.requestCharge(ChargeCost) || (LocalCharge > 0 && SharedCharges.requestCharge(1) && removeLocalCharge(1)) || removeLocalCharge(ChargeCost)
	elseif ChargeMode == 1	;local priority
		return removeLocalCharge(ChargeCost) || SharedCharges.requestCharge(ChargeCost)
	elseif ChargeMode == 2	;local only
		return removeLocalCharge(ChargeCost) 
	endif
endfunction
;___________________________________________________________________________________________________________________________

; Removes and returns the number of requested charges from the local charge
int function removeLocalCharge(int iRequest)
	if iRequest > 0 && LocalCharge >= iRequest
		LocalCharge -= iRequest
		Debug.Notification("Bloodskal Charges: " +LocalCharge)
		;RegisterForDistanceTravelledEvent(ChargeDistance)
		;RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
		RegisterForRecharge()
		return iRequest
	else
		return 0
	endif
EndFunction

function addLocalCharge(int charge = 1)
	if LocalCharge != MaxLocalCharge
		LocalCharge += charge
		if LocalCharge < MaxLocalCharge
			Debug.Notification("Bloodskal Charges: " +LocalCharge)
			;RegisterForDistanceTravelledEvent(ChargeDistance)
			;RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
			RegisterForRecharge()
			return
		else
			LocalCharge = MaxLocalCharge
			Debug.Notification("Bloodskal Charges: " +LocalCharge)
		endif
	endif
	UnregisterForDistanceTravelledEvent()
	UnregisterForMagickaSiphonEvent()
endFunction
;___________________________________________________________________________________________________________________________

; 
function OnDistanceTravelledEvent()
	addLocalCharge()
endfunction
;___________________________________________________________________________________________________________________________

; 
function OnMagickaSiphonEvent()
	addLocalCharge()
EndFunction


Function RegisterForRecharge()
	RegisterForDistanceTravelledEvent(ChargeDistance)
	RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
EndFunction
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
			bUseCharges = True
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Turn On Charges
			bUseCharges = True
		elseif aiButton == 4		; Turn Off Charges
			bUseCharges = False
		elseif aiButton == 5		; Set ChargeMode
			ChargeMode = ListenerMenu.ChargeMode(ChargeMode, DEFChargeMode)
		elseif aiButton == 6		; Charge Options
			MenuChargeOptions(ListenerMenu)
		elseif aiButton == 7		; Set Priority
			ChargeMagickaPR = ListenerMenu.MagickaSiphonPriority(ChargeMagickaPR, DEFChargeMagickaPR)
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
		Button.set(7)
	else
		Button.set(1)
		if bUseCharges
			Button.set(4)
			Button.set(6)
		else
			Button.set(3)
		endif
	endif
	Button.set(5)
	Button.set(7)
EndFunction
;___________________________________________________________________________________________________________________________

Function MenuChargeOptions(INEQ_ListenerMenu ListenerMenu)
	bool abMenu = True
	int aiButton
	while abMenu
		aiButton = ChargeOptionsMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1	; Charge Cost DONT USE UNTIL HASCHARGE() GENARALIZED
			ChargeCost = ListenerMenu.ChargeCost(ChargeCost, DEFChargeCost)
			Debug.Notification("Option not available")
		elseif aiButton == 2	; Charge Storage
			MaxLocalCharge = ListenerMenu.ChargeStorage(MaxLocalCharge, DEFMaxLocalCharge)
			RegisterForRecharge()
		elseif aiButton == 3	; Recharge MP
			ChargeMagickaMP = ListenerMenu.MagickaSiphonCost(ChargeMagickaMP, DEFChargeMagickaMP)
		elseif aiButton == 4	; Recharge Distance
			ChargeDistance = ListenerMenu.DistanceTravelledCost(ChargeDistance, DEFChargeDistance)
		endif
	endwhile
EndFunction
