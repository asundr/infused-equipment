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

bool  Property  IsUnlocked  =  False  Auto  Hidden
bool  Property  IsActive  	=  False  Auto  Hidden

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>
INEQ_AbilityBase Ability
ObjectReference EquipRef

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

; Deactivate and Lock ability
Function FullReset(bool bLock = false)
	DeactivateAbility()
	EquipRef = None
	if bLock
		LockAbility()
	endif
EndFunction

; If ability active and has menu, restore it to default fields
Function RestoreDefaultFields()
	if Ability
		Ability.RestoreDefaultFields()
	endif
EndFunction

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

bool Function isActivated()
	return IsActive
EndFunction
;___________________________________________________________________________________________________________________________

bool Function isUnlocked()
	return IsUnlocked
EndFunction
;___________________________________________________________________________________________________________________________

String Function getName()
	return Name
endfunction
;___________________________________________________________________________________________________________________________

bool Function hasMenu()
	return Ability
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
		Debug.Trace(self+ " attempted to access menu but no ability was registered")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; If active, will force the reference to the passed item
Function AssignToEquipment(ObjectReference akEquipment)
	EquipRef = akEquipment
	if akEquipment && IsActive
		ForceRefTo( akEquipment )
	endif
Endfunction
;___________________________________________________________________________________________________________________________

; activates and adds ability to player if unlocked or cheatmode activated
Function ActivateAbility()
	if  IsUnlocked || Cheatmode.value == 1
		if  ! IsActive
			AbilityToPlayer.ForceRefTo(PlayerRef)
			if EquipRef
				ForceRefTo(EquipRef)
			endif
			IsActive = True
		endif
	Endif
EndFunction
;___________________________________________________________________________________________________________________________

; Turns off the ability
Function DeactivateAbility()
	Clear()
	AbilityToPlayer.Clear()
	IsActive = False
EndFunction
;___________________________________________________________________________________________________________________________

; Returns true if changed to true, returns false if already true
bool Function UnlockAbility()
	int index
	if IsUnlocked
		return false
	endif
	
	if LearningSpell
		index = LearningSpell.length
		while index
			index -= 1
			if PlayerRef.hasSpell(LearningSpell[index])
				IsUnlocked = True
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
				IsUnlocked = True
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
				IsUnlocked = True
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
				IsUnlocked = True
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
				IsUnlocked = True
				Debug.Notification("Unlocked: " +getName())
				return true
			endif
		endwhile
	endif
	
	return IsUnlocked
EndFunction
;___________________________________________________________________________________________________________________________

Function LockAbility()
	IsUnlocked = False
EndFunction
