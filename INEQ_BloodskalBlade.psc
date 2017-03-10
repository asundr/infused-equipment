Scriptname INEQ_BloodskalBlade extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell Property DLC2BloodskalBladeSpellHoriz auto
Spell Property DLC2BloodskalBladeSpellVert auto

ReferenceAlias	Property	SharedChargesAlias	Auto
ReferenceAlias	Property	DistanceTravelledAlias	Auto
ReferenceAlias	Property	MagickaSiphonAlias	Auto

String  Property  WeaponSwing  = 	"weaponSwing"  	Autoreadonly			; weapon attack

;String	Property PWStanding1H	= 	"weaponSwing"	Autoreadonly	;"attackPowerStart_Sprint" ;"attackPowerStartInPlace"	;"PowerAttackStartInPlace"	
;String	Property PWRight1H		= 	"weaponSwing"	Autoreadonly	;"attackPowerStartRight"		;"PowerAttackStartRight"	
;String	Property PWLeft1H		= 	"weaponSwing"	Autoreadonly	;"attackPowerStartLeft"		;"PowerAttackStartLeft"		
;String	Property PWForward1H	= 	"weaponSwing"	Autoreadonly	;"attackPowerStartForward"	;"PowerAttackStartForward"	
;String	Property PWBackward1H	= 	"weaponSwing"	Autoreadonly	;"attackPowerStartBackward"	;"PowerAttackStartBackward"	

String	Property PWStanding2H	= 	"AttackPowerStanding_FXstart"	Autoreadonly
String	Property PWRight2H		= 	"AttackPowerRight_FXstart"		Autoreadonly
String	Property PWLeft2H		= 	"AttackPowerLeft_FXstart"		Autoreadonly
String	Property PWForward2H	= 	"AttackPowerForward_FXstart"	Autoreadonly
String	Property PWBackward2H	= 	"AttackPowerBackward_FXstart"	Autoreadonly

Int		Property	LocalCharge		Auto	Hidden

Int 	Property	MaxLocalCharge	=	4	Autoreadonly	Hidden
Int		Property	ChargeCost		=	2	Autoreadonly	Hidden

float	Property	ChargeDistance	=	100.0	Autoreadonly	Hidden		; 1000.0, should be high relative to ChargeMagickaSiphon
float	Property	ChargeMagickaMP = 50.0		Autoreadonly	Hidden
int		Property	ChargeMagickaPR = 50		Auto			Hidden

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

INEQ_SharedCharges SharedCharges
INEQ_DistanceTravelled DistanceTravelled
INEQ_MagickaSiphon MagickaSiphon
int chargePriority = 0	; 0=shared charges, 1=prioritize local, 2=only use local charges
bool bRegisteredDT = False
bool bRegisteredMS = False
bool bBalancedMode = True

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
	MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
	LocalCharge = 0
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	DistanceTravelled.UnregisterForEvent(Self)
	MagickaSiphon.UnregisterForEvent(self)
	unregisterForAnimationEvent(SelfRef, PWStanding2H)
	unregisterForAnimationEvent(SelfRef, PWRight2H)
	unregisterForAnimationEvent(SelfRef, PWLeft2H)
	unregisterForAnimationEvent(SelfRef, PWBackward2H)
	unregisterForAnimationEvent(SelfRef, PWForward2H)
	UnregisterForAnimationEvent(selfRef, WeaponSwing)
EndEvent

Event OnPlayerLoad()
	Maintenance()
EndEvent

Function Maintenance()
	if DistanceTravelled
		RegisterForDistanceTravelledEvent(ChargeDistance)
	else
		DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
		if DistanceTravelled
			RegisterForDistanceTravelledEvent(ChargeDistance)
		endif
	endif
	
	if MagickaSiphon
		RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
	else
		MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
		if MagickaSiphon
			RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
		endif
	endif
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
		Maintenance()
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
			if !bBalancedMode || hasCharge()
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
			if !bBalancedMode || hasCharge()
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
		if !bBalancedMode || hasCharge()
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
	if chargePriority == 0		;shared priority
		; Attempts to use both from shared first if available
		; else uses last from shared and a charge from local if available
		; else attempts to use both from local
		return SharedCharges.requestCharge(ChargeCost) || (LocalCharge > 0 && SharedCharges.requestCharge(1) && removeLocalCharge(1)) || removeLocalCharge(ChargeCost)
	elseif chargePriority == 1	;local priority
		return removeLocalCharge(ChargeCost) || SharedCharges.requestCharge(ChargeCost)
	elseif chargePriority == 2	;local only
		return removeLocalCharge(ChargeCost) 
	endif
	Debug.MessageBox("End of hasCharge")
endfunction
;___________________________________________________________________________________________________________________________

; Removes and returns the number of requested charges from the local charge
int function removeLocalCharge(int iRequest)
	if iRequest > 0 && LocalCharge >= iRequest
		LocalCharge -= iRequest
		Debug.Notification("Bloodskal Charges: " +LocalCharge)
		RegisterForDistanceTravelledEvent(ChargeDistance)
		RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
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
			RegisterForDistanceTravelledEvent(ChargeDistance)
			RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
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

function OnDistanceTravelledEvent()
	bRegisteredDT = False
	addLocalCharge()
endfunction

function RegisterForDistanceTravelledEvent(float akDistance)
	if !bRegisteredDT && LocalCharge < MaxLocalCharge
		bRegisteredDT = DistanceTravelled.RegisterForEvent(self, akDistance)
	endif
Endfunction

Function UnregisterForDistanceTravelledEvent()
	if bRegisteredDT
		bRegisteredDT	= False
		bRegisteredDT = DistanceTravelled.UnregisterForEvent(self)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

function OnMagickaSiphonEvent()
	bRegisteredMS = False
	addLocalCharge()
EndFunction

function RegisterForMagickaSiphonEvent(float akMagicka, int akPriority)
	if !bRegisteredMS && LocalCharge < MaxLocalCharge
		bRegisteredMS = MagickaSiphon.RegisterForEvent(self, akMagicka, akPriority)
	endif
endfunction

Function UnregisterForMagickaSiphonEvent()
	if bRegisteredMS
		bRegisteredMS = False
		MagickaSiphon.UnregisterForEvent(self)
	endif
endfunction
