Scriptname INEQ_BloodskalBlade extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell Property DLC2BloodskalBladeSpellHoriz auto
Spell Property DLC2BloodskalBladeSpellVert auto

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


;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	unregisterForAnimationEvent(SelfRef, PWStanding2H)
	unregisterForAnimationEvent(SelfRef, PWRight2H)
	unregisterForAnimationEvent(SelfRef, PWLeft2H)
	unregisterForAnimationEvent(SelfRef, PWBackward2H)
	unregisterForAnimationEvent(SelfRef, PWForward2H)
	UnregisterForAnimationEvent(selfRef, WeaponSwing)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Ready
	
	Event OnBeginState()
		int itemType = SelfRef.getEquippedItemType(1)
		if itemType == 5
			GoToState("Ready2HGreatsword")
		elseif itemType == 6
			GoToState("Ready2HOther")
		elseif itemType > 0 && itemType < 5
			GoToState("Ready1H")
		endif
	EndEvent

EndState

State Ready1H

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if SelfRef.GetAnimationVariableFloat("Speed") == 0
				DLC2BloodskalBladeSpellVert.cast(selfRef)
			else
				float direction = selfRef.GetAnimationVariableFloat( "Direction" )
				if (direction == 0.25 || direction == 0.75)
					DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
;				elseif (direction == 0.00 || direction == 1.00 || direction == 0.5)
				else
					DLC2BloodskalBladeSpellVert.cast(selfRef)
				endif
;				if (   (( selfRef.GetAnimationVariableFloat( "Direction" ) * 4) as int) % 2 == 0)
;					DLC2BloodskalBladeSpellVert.cast(akSource)
;				else
;					DLC2BloodskalBladeSpellHoriz.cast(akSource)
;				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent
	
EndState

State Ready2HOther

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if SelfRef.GetAnimationVariableFloat("Speed") == 0
				DLC2BloodskalBladeSpellVert.cast(SelfRef)
			else
				float direction = selfRef.GetAnimationVariableFloat( "Direction" )
				if (direction == 0.00 || direction == 1.00)
					DLC2BloodskalBladeSpellVert.cast(selfRef)
;				elseif (direction == 0.25 || direction == 0.75 || direction == 0.5)
				else
					DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

EndState


State Ready2HGreatsword

	Event OnBeginState()
		registerForAnimationEvent(SelfRef, PWStanding2H)
		registerForAnimationEvent(SelfRef, PWRight2H)
		registerForAnimationEvent(SelfRef, PWLeft2H)
		registerForAnimationEvent(SelfRef, PWBackward2H)
		registerForAnimationEvent(SelfRef, PWForward2H)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if EventName == PWStanding2H|| EventName == PWForward2H
			DLC2BloodskalBladeSpellVert.cast(selfRef)
;		elseif EventName == PWBackward2H || EventName == PWRight2H || EventName == PWLeft2H
		else
			DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
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
