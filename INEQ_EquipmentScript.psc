Scriptname INEQ_EquipmentScript extends ReferenceAlias  
{Takes a list of Quests that contain aliases to available abilities and reassigns the abilities}

; QUEST ALIASES MUST HAVE CONSECUTIVE INDEXES FROM 0, DONT DELETE ALIAS, REUSE THEM

FormList  Property  AbilityQuestList  Auto

Function  ChangeReference(ObjectReference akItemReference)
	self.ForceRefTo(akItemReference)
	
	int index1 = AbilityQuestList.GetSize()
	while index1 > 0
		index1-=1
		Quest  abilityAliasList = AbilityQuestList.GetAt(index1) as Quest
		if (abilityAliasList)
;			Debug.Notification("Quest Found")
			int index2 = 0
			ReferenceAlias abRef= abilityAliasList.GetAlias(index2) as ReferenceAlias
			while ( abRef )
				INEQ_AbilityAliasProperties abProperties = abRef as INEQ_AbilityAliasProperties 
;				Debug.Notification("Alias: " +index2+ " isUnlocked? " +abProperties.IsUnlocked+ ", isActive? "+abProperties.IsActive)
				if (abProperties.IsUnlocked && abProperties.IsActive)
;					Debug.Notification("Ref Changed")
					abRef.ForceRefTo(akItemReference)
				endif
				abRef = abilityAliasList.GetAlias(index2) as ReferenceAlias
				index2+=1
			endwhile
		endif
	endwhile

EndFunction

; Change 2nd while loop when SKSE SE released



function addAbilitiesAsForm(FormList newList)
	int index = newList.GetSize()
	while index > 0
		index -= 1
		AbilityQuestList.AddForm( newList.GetAt(index) )
	endwhile
endfunction