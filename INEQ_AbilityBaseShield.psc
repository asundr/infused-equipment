Scriptname INEQ_AbilityBaseShield extends INEQ_AbilityBase Hidden
{Override of AbilityBase to account for how game handles un/equip events for shields}

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Goes to Equipped state if equipped item has keyword, ora currently equipped item is the same base object
; in case the item is reequipped auotmatically through an object on the other hand
Function EquipCheckKW(ObjectReference akReference)
	if akReference && akReference.HasKeyword(KW_EnbaleAbility)
		EquipRef = akReference
		GoToState("Equipped")
	elseif SelfRef.GetEquippedShield() && EquipRef && SelfRef.GetEquippedShield() == (EquipRef.GetBaseObject() as Armor)
		GoToState("Equipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Changes state of script but keeps equipref in case this is auto equipped through the other hand
Function UnequipCheck(ObjectReference akReference)
	if (akReference == EquipRef)
		GoToState("Unequipped")
	endif
EndFunction
