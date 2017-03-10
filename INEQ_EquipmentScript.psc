Scriptname INEQ_EquipmentScript extends ReferenceAlias  
{Takes a list of Quests that contain aliases to available abilities and reassigns the abilities}

;===========================================  Properties  ===========================================================================>
FormList  						Property	AbilityQuestList	Auto	;contians base abilities at 0, plugin abilities after
INEQ_AbilityAliasProperties[]	Property	AbilityAliasArray	Auto

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	makeAbilityFormlist()
endEvent

Function maintenance()
	makeAbilityFormlist()
EndFunction

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Adds new quests to ability quest formlist
function addAbilityQuestAsFormlist(FormList newList)
	int index = newList.GetSize()
	while index > 0
		index -= 1
		AbilityQuestList.AddForm( newList.GetAt(index) )
	endwhile
	makeAbilityFormList()
endfunction
;___________________________________________________________________________________________________________________________

;Refereshes the ability alias formlist		; Change Alias while loop when SKSE SE released
function makeAbilityFormlist()
	INEQ_AbilityAliasProperties[] temp = new INEQ_AbilityAliasProperties[32]
	int ListSize = AbilityQuestList.GetSize()
	int iList 
	int count = 0
	while iList < ListSize
		Quest  AbilityQuest = AbilityQuestList.GetAt(iList) as Quest
		if (AbilityQuest)
			int iAlias = 0
			ReferenceAlias abRef = AbilityQuest.GetAlias(iAlias) as ReferenceAlias
			while ( abRef )
				if abRef != none && (abRef as INEQ_AbilityAliasProperties).getName() != ""
					temp[count] = abRef as INEQ_AbilityAliasProperties
					count += 1
				endif
				iAlias += 1
				abRef = AbilityQuest.GetAlias(iAlias) as ReferenceAlias
			endwhile
		endif
		iList += 1
	endwhile
	AbilityAliasArray = temp
EndFunction
;___________________________________________________________________________________________________________________________

; Changes references to the new item
Function  ChangeReference(ObjectReference akItemReference)
	ForceRefTo(akItemReference)
	int index = AbilityAliasArray.length
	while index > 0 
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].AssignToEquipment(akItemReference)
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Checks to see if any new ability can be unlocked
int Function AttemptUnlock()
	int unlockCount = 0
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None && AbilityAliasArray[index].UnlockAbility()
			unlockCount += 1
		endif
	endwhile
	return unlockCount
EndFunction
;__________________________________________________________________________________________________________________________

; Deactivates every alias, or every cheated alias if passed in as false
Function AttemptDeactivate(bool cheated = False)
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if (AbilityAliasArray[index] != None) && ( !cheated || !(AbilityAliasArray[index] as INEQ_AbilityAliasProperties).isUnlocked() )	;	!(cheated && (AbilityAliasArray[index] as INEQ_AbilityAliasProperties).isUnlocked())
			AbilityAliasArray[index].DeactivateAbility()
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Activates an ability and updates it to the current reference
Function AttemptActivate()
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].ActivateAbility()
			AbilityAliasArray[index].AssignToEquipment(GetReference())
		endif
	endwhile
endfunction
;___________________________________________________________________________________________________________________________

; If an ability has modifiable properties, returns them to default values
Function RestoreDefaultFields()
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].RestoreDefaultFields()
		endif
	endwhile
endfunction
;___________________________________________________________________________________________________________________________

; Fully clear all aliases, reset unlocks and activations to false
Function FullReset(bool bLock = False)
	Clear()
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].FullReset(bLock)
		endif
	endwhile
EndFunction
