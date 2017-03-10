Scriptname INEQ_AbilityAliasProperties extends ReferenceAlias  

Actor Property PlayerRef Auto

ReferenceAlias  Property  AbilityToPlayer  Auto

; only fill one of these
Armor[]		Property	LearningArmor	Auto
Weapon[]	Property	LearningWeapon	Auto
Spell[]		Property	LearningSpell	Auto
WordOfPower[] Property 	LearningWord	Auto
Enchantment[] Property	LearningEnch	Auto

GlobalVariable Property CheatMode Auto

String Property Name Auto

bool  Property  IsUnlocked  =  False  Auto  Hidden
bool  Property  IsActive  	=  False  Auto  Hidden

bool Function isActivated()
	return IsActive
EndFunction

bool Function isUnlocked()
	return IsUnlocked
EndFunction

String Function getName()
	return Name
endfunction

; If active, will force the reference to the passed item
Function AssignToEquipment(ObjectReference akEquipment)
	if IsActive
		ForceRefTo( akEquipment )
	endif
Endfunction

;returns true if changed to true, returns false if already true
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

Function LockAbility()
	IsUnlocked = False
EndFunction

; activates and adds ability to player if unlocked or cheatmode activated
Function ActivateAbility()
	if  IsUnlocked || Cheatmode.value == 1
		if  ! IsActive
			AbilityToPlayer.ForceRefTo(PlayerRef)
			IsActive = True
		endif
	Endif
EndFunction

Function DeactivateAbility()
	Clear()
	AbilityToPlayer.Clear()
	IsActive = False
EndFunction


Function FullReset()
	DeactivateAbility()
	LockAbility()
EndFunction

