Scriptname INEQ_BoundPickaxe extends INEQ_AbilityBase  
{Adds hidden pickaxe to inventory and mineing formlists}

;===========================================  Properties  ===========================================================================>
Weapon property INEQ_Hands_BoundPickaxe_zPick Auto

FormList Property mineOreToolsList Auto
Formlist Property DLC2StalhrimMineOreToolsList Auto

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	mineOreToolsList.RemoveAddedForm(INEQ_Hands_BoundPickaxe_zPick)
	DLC2StalhrimMineOreToolsList.RemoveAddedForm(INEQ_Hands_BoundPickaxe_zPick)
	SelfRef.RemoveItem(INEQ_Hands_BoundPickaxe_zPick, SelfRef.GetItemCount(INEQ_Hands_BoundPickaxe_zPick), true)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Ready
	
	Event OnBeginState()
		mineOreToolsList.AddForm(INEQ_Hands_BoundPickaxe_zPick)
		DLC2StalhrimMineOreToolsList.AddForm(INEQ_Hands_BoundPickaxe_zPick)
		SelfRef.Additem(INEQ_Hands_BoundPickaxe_zPick, 1, true)
	EndEvent
	
	Event OnEndState()
		mineOreToolsList.RemoveAddedForm(INEQ_Hands_BoundPickaxe_zPick)
		DLC2StalhrimMineOreToolsList.RemoveAddedForm(INEQ_Hands_BoundPickaxe_zPick)
		SelfRef.RemoveItem(INEQ_Hands_BoundPickaxe_zPick, SelfRef.GetItemCount(INEQ_Hands_BoundPickaxe_zPick), true)
	EndEvent

EndState
