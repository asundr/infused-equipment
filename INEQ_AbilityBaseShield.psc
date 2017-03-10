Scriptname INEQ_AbilityBaseShield extends INEQ_AbilityBase Hidden
{Override of AbilityBase to account for how game handles un/equip events for shields}

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

Function EquipCheckKW(ObjectReference akReference)
	if akReference && akReference.HasKeyword(KW_EnbaleAbility)
		EquipRef = akReference
		GoToState("Equipped")
	elseif SelfRef.GetEquippedShield() && EquipRef && SelfRef.GetEquippedShield() == (EquipRef.GetBaseObject() as Armor)
		GoToState("Equipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
		if (akReference == EquipRef)
			;EquipRef = none
			GoToState("Unequipped")
		endif
EndFunction
