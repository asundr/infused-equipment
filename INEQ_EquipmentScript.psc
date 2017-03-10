Scriptname INEQ_EquipmentScript extends ReferenceAlias  
{Takes a list of Quests that contain aliases to available abilities and reassigns the abilities}

FormList  Property  AbilityQuestList	Auto	;contians base abilities at 0, plugin abilities after
INEQ_AbilityAliasProperties[]	Property	AbilityAliasArray	Auto

Event OnInit()
	makeAbilityFormlist()
endEvent

Function maintenance()
	makeAbilityFormlist()
EndFunction

; Adds new quests to ability quest formlist
function addAbilityQuestAsFormlist(FormList newList)
	int index = newList.GetSize()
	while index > 0
		index -= 1
		AbilityQuestList.AddForm( newList.GetAt(index) )
	endwhile
	makeAbilityFormList()
endfunction


;Refereshes the ability alias formlist		; Change Alias while loop when SKSE SE released
function makeAbilityFormlist()
	INEQ_AbilityAliasProperties[] temp = new INEQ_AbilityAliasProperties[32]
	int iList = AbilityQuestList.GetSize()
	int count = 0
	while iList > 0
		iList-=1
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
	endwhile
	AbilityAliasArray = temp
EndFunction


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


; Deactivates every alias, or every cheated alias if passed in as false
Function AttemptDeactivate(bool cheated = False)
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if (AbilityAliasArray[index] != None) && ( !cheated || !(AbilityAliasArray[index] as INEQ_AbilityAliasProperties).isUnlocked() )	;	!(cheated && unlocked)
			AbilityAliasArray[index].DeactivateAbility()
		endif
	endwhile
	clear()
EndFunction

Function AttemptActivate()
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].ActivateAbility()
		endif
	endwhile
endfunction

; Fully clear all aliases, reset unlocks and activations to false
Function AttemptFullReset()
	int index = AbilityAliasArray.length
	while index > 0
		index -= 1
		if AbilityAliasArray[index] != None
			AbilityAliasArray[index].FullReset()
		endif
	endwhile
	
	;stop/ start all quests containing kw and abilityproperty script
;	index = AbilityQuestList.GetSize()
;	while index
;		index -= 1
;		Quest temp = AbilityQuestList.getAt(index) as Quest
;		temp.stop()
;		temp.start()
;	endwhile
	
EndFunction

