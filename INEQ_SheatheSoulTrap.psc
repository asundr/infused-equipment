Scriptname INEQ_SheatheSoulTrap extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell property SheathSpell auto

String  Property  WeaponSheathe  = 	"WeaponSheathe"  	Autoreadonly		; weapon sheathed

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(selfRef, WeaponSheathe)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(selfRef, WeaponSheathe)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		SheathSpell.cast(selfRef, selfRef)
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponSheathe)
	EndEvent

EndState
