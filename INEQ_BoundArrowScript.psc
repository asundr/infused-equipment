Scriptname INEQ_BoundArrowScript extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Ammo Property boundArrow  Auto  

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		   Start/Finish		================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.removeitem(boundArrow,SelfRef.getItemCount(boundArrow),TRUE)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Ready
	
	Event OnBeginState()
		SelfRef.additem(boundArrow,100,TRUE)
		SelfRef.equipItem(boundArrow, TRUE, TRUE)	
	EndEvent

	Event OnEndState()
		SelfREf.removeitem(boundArrow,SelfRef.getItemCount(boundArrow),TRUE)
	EndEvent
	
EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

;Event onLoad()
;	if !(SelfRef.hasMagicEffect(GetBaseObject()))
; 		;debug.trace("Bound Bow - Cell Attached, script active, but effect not found on "+SelfRef)
;		dispel()
;	endif
;EndEvent
