Scriptname INEQ_AbilityBaseShield extends INEQ_AbilityBase Hidden

ObjectReference EquipRef

Function EquipCheckKW(ObjectReference akReference)
	if akReference && akReference.HasKeyword(KW_EnbaleAbility)
		EquipRef = akReference
		GoToState("Ready")
	elseif SelfRef.GetEquippedShield() && EquipRef && SelfRef.GetEquippedShield() == (EquipRef.GetBaseObject() as Armor)
		GoToState("Ready")
	endif
EndFunction

Function UnequipCheck(ObjectReference akReference)
		if (akReference == EquipRef)
			;EquipRef = none
			GoToState("Unequipped")
		endif
EndFunction
