Scriptname INEQ_AbilityBase1H extends INEQ_AbilityBase Hidden
{Override of AbilityBase to account for how game handles un/equip events for 1H weapons}

Function EquipCheckKW(ObjectReference akReference)
	if akReference && akReference.HasKeyword(KW_EnbaleAbility)
		EquipRef = akReference
		GoToState("Equipped")
	elseif SelfRef.GetEquippedWeapon(0) && EquipRef && SelfRef.GetEquippedWeapon(0) == (EquipRef.GetBaseObject() as Weapon) || SelfRef.GetEquippedWeapon(1) && SelfRef.GetEquippedWeapon(1) == (EquipRef.GetBaseObject() as Weapon)
		GoToState("Equipped")
	endif
EndFunction

Function UnequipCheck(ObjectReference akReference)
		if (akReference == EquipRef)
			;EquipRef = none
			GoToState("Unequipped")
		endif
EndFunction
