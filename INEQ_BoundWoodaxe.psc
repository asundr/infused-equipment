Scriptname INEQ_BoundWoodaxe extends INEQ_AbilityBase  
{Adds hidden axe to inventory and woodcutting formlist}

;===========================================  Properties  ===========================================================================>
Weapon property INEQ_Hands_BoundWoodaxe_zAxe Auto

FormList Property woodChoppingAxes Auto

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	woodChoppingAxes.RemoveAddedForm(INEQ_Hands_BoundWoodaxe_zAxe)
	SelfRef.RemoveItem(INEQ_Hands_BoundWoodaxe_zAxe, SelfRef.GetItemCount(INEQ_Hands_BoundWoodaxe_zAxe), true)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		woodChoppingAxes.AddForm(INEQ_Hands_BoundWoodaxe_zAxe)
		SelfRef.Additem(INEQ_Hands_BoundWoodaxe_zAxe, 1, true)
	EndEvent
	
	Event OnEndState()
		woodChoppingAxes.RemoveAddedForm(INEQ_Hands_BoundWoodaxe_zAxe)
		SelfRef.RemoveItem(INEQ_Hands_BoundWoodaxe_zAxe, SelfRef.GetItemCount(INEQ_Hands_BoundWoodaxe_zAxe), true)
	EndEvent

EndState
