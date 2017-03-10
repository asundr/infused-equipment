Scriptname INEQ_AbilityAliasProperties extends ReferenceAlias  
{Object that handles unlocking and activating abilities}

;===========================================  Properties  ===========================================================================>
Armor[]		Property	LearningArmor	Auto
Weapon[]	Property	LearningWeapon	Auto
Spell[]		Property	LearningSpell	Auto
WordOfPower[] Property 	LearningWord	Auto
Enchantment[] Property	LearningEnch	Auto

Actor			Property	PlayerRef		Auto
ReferenceAlias	Property	AbilityToPlayer	Auto
GlobalVariable	Property	CheatMode		Auto

String Property Name Auto

bool  Property  bIsUnlocked	=  False  Auto  Hidden
bool  Property  bIsActive	=  False  Auto  Hidden

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>
INEQ_AbilityBase Ability
ObjectReference EquipRef

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

; If ability active and has menu, restore it to default fields
Function RestoreDefaultFields()
	if Ability
		Ability.RestoreDefaultFields()
	endif
EndFunction

; Deactivate and Lock ability
Function FullReset(bool bLock = false)
	RestoreDefaultFields()
	DeactivateAbility()
	EquipRef = None
	if bLock
		LockAbility()
	endif
EndFunction

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

bool Function isActivated()
	return bIsActive
EndFunction
;___________________________________________________________________________________________________________________________

bool Function isUnlocked()
	return bIsUnlocked
EndFunction
;___________________________________________________________________________________________________________________________

String Function getName()
	return Name
endfunction
;___________________________________________________________________________________________________________________________

bool Function hasMenu()
	return Ability && Ability.bHasMenu
EndFunction
;___________________________________________________________________________________________________________________________
;					Behavior related to letting Listeners register themselves for Menu access

Function RegisterAbility(INEQ_AbilityBase akAbility)
	Ability = akAbility
EndFunction

Function UnregisterAbility()
	Ability = none
EndFunction

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	if Ability
		Ability.AbilityMenu(Button, ListenerMenu, MenuActive)
	else
		Debug.Trace("[INEQ] Attempted to access menu but ability " +Name+ " was not registered on " +self)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; If active, will force the reference to the passed item
Function AssignToEquipment(ObjectReference akEquipment)
	if akEquipment
		EquipRef = akEquipment
		if  bIsActive
			if Ability
				Ability.EquipRef = None
			else
				Debug.Trace("[INEQ] Failed to register ability " +Name+ " on " +self)
			endif
			ForceRefTo(akEquipment)
		endif
	endif
Endfunction
;___________________________________________________________________________________________________________________________

; activates and adds ability to player if unlocked or cheatmode activated
Function ActivateAbility()
	if  bIsUnlocked || Cheatmode.value == 1
		if !bIsActive
			AbilityToPlayer.ForceRefTo(PlayerRef)
			if EquipRef
				ForceRefTo(EquipRef)
			endif
			bIsActive = True
		endif
	Endif
EndFunction
;___________________________________________________________________________________________________________________________

; Turns off the ability and clears the Aliases
Function DeactivateAbility()
	Clear()
	AbilityToPlayer.Clear()
	bIsActive = False
EndFunction
;___________________________________________________________________________________________________________________________

; Returns true if changed to true, returns false if already true
bool Function UnlockAbility()
	int index
	if bIsUnlocked
		return false
	endif
	
	if LearningSpell
		index = LearningSpell.length
		while index
			index -= 1
			if PlayerRef.hasSpell(LearningSpell[index])
				bIsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	if  LearningArmor
		index = LearningArmor.length
		while index
			index -= 1
			if PlayerRef.GetItemCount(LearningArmor[index])
				bIsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	if	LearningWeapon
		index = LearningWeapon.length
		while index
			index -= 1
			if PlayerRef.GetItemCount(LearningWeapon[index])
				bIsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	if LearningWord
		index = LearningWord.length
		while index
			index -= 1
			if Game.IsWordUnlocked(LearningWord[index])
				bIsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	if LearningEnch
		index = LearningEnch.length
		while index
			index -= 1
			if LearningEnch[index].PlayerKnows()
				bIsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	return bIsUnlocked
EndFunction
;___________________________________________________________________________________________________________________________

Function LockAbility()
	bIsUnlocked = False
EndFunction
