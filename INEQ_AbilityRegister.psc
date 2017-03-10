Scriptname INEQ_AbilityRegister extends ReferenceAlias 
{Allows access to the abilities and mod options via menus}

;===========================================  Properties  ===========================================================================>
ReferenceAlias	Property	Alias_Shield001	Auto
ReferenceAlias	Property 	Alias_Feet001	Auto
ReferenceAlias	Property 	Alias_Head001  	Auto
ReferenceAlias	Property 	Alias_Body001  	Auto
ReferenceAlias	Property 	Alias_Hands001 	Auto
ReferenceAlias	Property	Alias_Bow001	Auto
ReferenceAlias  Property	Alias_Dagger001	Auto
ReferenceAlias  Property	Alias_Sword001	Auto

Keyword 	Property	ArmorBoots		Auto
Keyword 	Property	ArmorCuirass	Auto
Keyword 	Property	ArmorGauntlets	Auto
Keyword 	Property	ArmorHelmet		Auto
Keyword 	Property	ArmorShield		Auto
Keyword 	Property	ClothingBody	Auto
Keyword 	Property	ClothingFeet	Auto
Keyword 	Property	ClothingHands	Auto
Keyword 	Property	ClothingHead	Auto
Keyword 	Property	WeapTypeBattleaxe	Auto
Keyword 	Property	WeapTypeBow			Auto
Keyword 	Property	WeapTypeDagger		Auto
Keyword 	Property	WeapTypeGreatsword	Auto
Keyword 	Property	WeapTypeMace		Auto
Keyword 	Property	WeapTypeStaff		Auto
Keyword 	Property	WeapTypeSword		Auto
Keyword 	Property	WeapTypeWarAxe		Auto
Keyword 	Property	WeapTypeWarhammer	Auto

Message  	Property  	SelectAction  	Auto
Message		Property	EquipSlotSelect	Auto
Message		Property	AbilitySelect	Auto
Message		Property	AbilityOptions	Auto
Message		Property	OtherOptions	Auto
Message		Property	FullResetWarn	Auto

GlobalVariable	Property	CheatMode	Auto
GlobalVariable	Property	MenuActive	Auto

Quest	Property	MainQuest				Auto
Quest	Property	INEQ__AbilitiesToPlayer	Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	InfuseTimout	=	5.0	Autoreadonly

;===========================================  Variables  ============================================================================>
Actor SelfRef
bool isBusy

INEQ_MenuButtonConditional	Button
INEQ_ListenerMenu			ListenerMenu

INEQ_EquipmentScript[]		Equipment

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	SelfRef = self.GetReference() as Actor
	Button = MainQuest as INEQ_MenuButtonConditional
	ListenerMenu = MainQuest as INEQ_ListenerMenu
	Equipment = new INEQ_EquipmentScript[8]
	Equipment[0] = Alias_Sword001 	as INEQ_EquipmentScript
	Equipment[1] = Alias_Dagger001 	as INEQ_EquipmentScript
	Equipment[2] = Alias_Bow001 	as INEQ_EquipmentScript
	Equipment[3] = Alias_Shield001 	as INEQ_EquipmentScript
	Equipment[4] = Alias_Head001 	as INEQ_EquipmentScript
	Equipment[5] = Alias_Body001 	as INEQ_EquipmentScript
	Equipment[6] = Alias_Hands001 	as INEQ_EquipmentScript
	Equipment[7] = Alias_Feet001 	as INEQ_EquipmentScript
EndEvent

Event OnPlayerLoadGame()
	maintenance()
EndEvent

Function maintenance()
	; Referesh Equipment ability lists
	int i = Equipment.length
	while i > 0
		i -= 1
		Equipment[i].maintenance()
	endwhile
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

Function MainMenu()
	int aiButton
	MenuActive.setValue(1)
	While MenuActive.Value
		aiButton = SelectAction.Show()
		If aiButton == 0 			
			StartRegister()
			MenuActive.setValue(0)
		ElseIF aiButton == 1
			StartUnlocking()
		ElseIf aiButton == 2 
			StartSelectAbilities()
		ElseIf aiButton == 3 
			StartAbilityOptions()
		ElseIf aiButton == 4
			StartOtherOptions()
		elseif aiButton == 5
			MenuActive.setValue(0)
		EndIf
	EndWhile
EndFunction
;___________________________________________________________________________________________________________________________


State Register

	Event OnBeginState()
		Debug.Notification("Drop apparel or a weapon to infuse it")		
		RegisterForSingleUpdate(InfuseTimout)
	EndEvent
	
	Event OnUpdate()
		if !isBusy
			Debug.Notification("Infusion timed out")
			GoToState("")
		endif
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
;		Debug.Notification("Item Dropped...")
		isBusy = True
		if 	(akBaseItem as Armor)
			if akItemReference.HasKeyword(ArmorShield)
				ForceRefIfActive(Alias_Shield001, akItemReference)
			elseif akItemReference.HasKeyword(ArmorBoots) || akItemReference.HasKeyword(ClothingFeet)
				ForceRefIfActive(Alias_Feet001, akItemReference)
			elseif akItemReference.HasKeyword(ArmorCuirass) || akItemReference.HasKeyword(ClothingBody)
				ForceRefIfActive(Alias_Body001, akItemReference)
			elseif akItemReference.HasKeyword(ArmorGauntlets) || akItemReference.HasKeyword(ClothingHands)
				ForceRefIfActive(Alias_Hands001, akItemReference)
			elseif akItemReference.HasKeyword(ArmorHelmet) || akItemReference.HasKeyword(ClothingHead)
				ForceRefIfActive(Alias_Head001, akItemReference)
			endif
		elseif 	(akBaseItem as Weapon)
			if akItemReference.HasKeyword(WeapTypeDagger)
				ForceRefIfActive(Alias_Dagger001, akItemReference)
			elseif akItemReference.HasKeyword(WeapTypeSword) || akItemReference.HasKeyword(WeapTypeWarAxe) || akItemReference.HasKeyword(WeapTypeMace)
				ForceRefIfActive(Alias_Sword001, akItemReference)
			elseif akItemReference.HasKeyword(WeapTypeGreatsword) || akItemReference.HasKeyword(WeapTypeBattleaxe) || akItemReference.HasKeyword(WeapTypeWarhammer)
				ForceRefIfActive(Alias_Sword001, akItemReference)
			elseif akItemReference.HasKeyword(WeapTypeBow)
				ForceRefIfActive(Alias_Bow001, akItemReference)
;			elseif akItemReference.HasKeyword(WeapTypeStaff) 
;				ForceRefIfActive(Alias_Staff001, akItemReference)
			endif
		endif
		SelfRef.AddItem(akItemReference, 1, true)
		isBusy = False
		UnregisterForUpdate()
		GoToState("")
	EndEvent
	
	Event OnEndState()
		UnregisterForUpdate()
	EndEvent

EndState

function ForceRefIfActive(ReferenceAlias akEquipmentAlias, ObjectReference akItemReference)
	if akEquipmentAlias.getReference()	;&& SelfRef.IsEquipped(akEquipmentAlias.GetRef().GetBaseObject() as Form)
		SelfRef.UnequipItem(akEquipmentAlias.GetRef().GetBaseObject() as Form, 	FALSE, 	FALSE)
	endif
	((akEquipmentAlias as ReferenceAlias) as INEQ_EquipmentScript).ChangeReference(akItemReference)
	Debug.Notification("Item has been infused!")
endFunction

;___________________________________________________________________________________________________________________________

State Unlocking
	
	Event OnBeginState()
		int count = 0
		int index = Equipment.length
		while index > 0
			index -= 1
			count += Equipment[index].AttemptUnlock()
		endwhile
		if count > 1
			Debug.Notification("I have unlocked " +count+ " new abilities!")
		elseif count == 1
			Debug.Notification("I have unlocked one new ability!")
		else
			Debug.Notification("I didn't find any new abilities")
		endif
		GoToState("")
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________


State SelectAbilities

	Event OnBeginState()
		MenuActive.SetValue(1)
		EquipmentSlotMenu()
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	; Menu for (de)acitvating available abilities. Shows 4  options at a time, pressing next (button 9) recursively calls itself at a later index
	Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0);,  bool abMenu = True)

		; Iterates ability list to find 4 unlocked abilities from a given index
		bool abMenu = True
		
		int max = AbilityArray.length
		INEQ_AbilityAliasProperties[] currAbilities = new INEQ_AbilityAliasProperties[4]
		String messageText = ""
		int count = 0
		if AbilityArray[index] == none
			index = max
		endif
		while index < max && count < 4
			if AbilityArray[index].isUnlocked() || CheatMode.value
				currAbilities[count] = AbilityArray[index]
				count += 1
				messageText += (count)+ ") " +AbilityArray[index].getName()+ "\n"
			endif
			index += 1
			
			; b/c array size may be larger than number of filled elements
			if AbilityArray[index] == none
				index = max
			endif
		endwhile

		; Notifies player if they don't have any abilities in that slot
		if currAbilities[0] == none && startIndex == 0
			Debug.Notification("You don't have any abilities of this type")
			return
		endif
		
		int aiButton
		While abMenu && MenuActive.Value
			Debug.MessageBox(messageText)
			setButton(currAbilities, index  < max)
			aiButton = AbilitySelect.Show()
			if aiButton == 0
				return	;Back Button
			elseif aiButton == 9
				AbilitySelectMenu(AbilityArray, index, index)	;Next Button
			elseif aiButton%2 == 1
				currAbilities[(aiButton - 1)/2].DeactivateAbility()
				Button.set(aiButton, false)
				Button.set(aiButton+1, True)
			else
				currAbilities[(aiButton - 1)/2].ActivateAbility()  ;item must be reinfused to get ability atm
				Button.set(aiButton, false)
				Button.set(aiButton - 1, true)
			endif
		endwhile
		
	EndFunction
	;___________________________________________________________________________________________________________________________

	;Formats a Button to display the correct Activate/deactivate options and a next button if necessary
	Function setButton(INEQ_AbilityAliasProperties[] array, bool belowMax)
		Button.clear()
		int index = array.length
		while index > 0 
			index -= 1
			if array[index] != none
				if array[index].isActivated()
					Button.Set(2*index + 1)
				else
					Button.Set(2*index + 2)
				endif
			endif
		endwhile

		if belowMax	; Enable next button if list isn't finished
			Button.Set(9)
		endif
	EndFunction
	
EndState

;___________________________________________________________________________________________________________________________

State AbilityOptions

	Event OnBeginState()
		MenuActive.SetValue(1)
		EquipmentSlotMenu()
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0);,  bool abMenu = True)
		
		;Iterate ability list to find 8 unlocked abilities from a given index
		bool abMenu = True
		
		int max = AbilityArray.length
		INEQ_AbilityAliasProperties[] currAbilities = new INEQ_AbilityAliasProperties[8]
		String messageText = ""
		int count = 0
		if AbilityArray[index] == none
			index = max
		endif
		while index < max && count < 8
			if AbilityArray[index].hasMenu()
				currAbilities[count] = AbilityArray[index]
				count += 1
				messageText += (count)+ ") " +AbilityArray[index].getName()+ "\n"
			endif
			index += 1
			
			; b/c array size may be larger than number of fileld elements
			if AbilityArray[index] == none
				index = max
			endif
		endwhile
		
		; Notifies player if the slot has no active abilities with options
		if currAbilities[0] == none && startIndex == 0
			Debug.Notification("No active abilities of this type have additional options")
			return
		endif
		
		int aiButton
		while abMenu && MenuActive.Value
			Debug.MessageBox(messageText)
			setButton(currAbilities, index < max)
			aiButton = AbilityOptions.Show()
			if aiButton == 0
				return	;Back
			elseif aiButton == 9
				AbilitySelectMenu(AbilityArray, index, index)
			else
				currAbilities[aiButton - 1].AbilityMenu(Button, ListenerMenu, MenuActive)
			endif
		endwhile
		
	EndFunction

	
	; Formats a Button to Display the options for accessing the Abilities options and a next buttton if necessary
	Function setButton(INEQ_AbilityAliasProperties[] array, bool belowMax)
		Button.clear()
		int index = array.length
		while index > 0
			index -= 1
			if array[index] != none
				Button.Set(index + 1)
			endif
		endwhile
		
		if belowMax	;Enable next button if list isn't finished
			Button.Set(9)
		endif
	EndFunction
	
EndState

;___________________________________________________________________________________________________________________________

State OtherOptions

	Event OnBeginState()
		bool abMenu = True
		MenuActive.SetValue(1)
		int aiButton = 0

		While abMenu && MenuActive.Value
			If aiButton != -1 			; Wait for input (this can prevent problems if recycling the aiButton argument in submenus)
				aiButton = OtherOptions.Show() ; Main Menu
				if aiButton == 0
					abMenu = False	; back button
				elseif aiButton == 1
					ActivateAllAvailable()
					Debug.Notification("All available abilities have been activated")
				elseIf aiButton == 2
					DeactivateAll()
					Debug.Notification("All abilities have been deactivated")
				elseif aiButton == 3
					maintenance()
					Debug.Notification("Ability arrays have been updated")
				ElseIF aiButton == 4
					aiButton = FullResetWarn.Show()
					if aiButton == 0
						CheatMode.value = 0
						FullResetAll()
;						INEQ__AbilitiesToPlayer.stop()		; testing to apply edits to aliases, see AttemptFullReset in EquipmentScript for more
;						INEQ__AbilitiesToPlayer.start()
;						
;						Alias_Sword001.GetOwningQuest().stop()
;						Alias_Sword001.GetOwningQuest().start()
						
						Debug.Notification("All abilities have been completely reset and must be unlocked again")
					endif
				ElseIf aiButton == 5 
					CheatMode.value = 1
					Debug.Notification("Cheat mode activated")
				ElseIf aiButton == 6 
					CheatMode.value = 0
					DeactivateAll(True)
					Debug.MessageBox("Stop right there criminal scum! Nobody cheats on my watch! I'm confiscating your stolen abilities! Now earn them properly or its off to jail.")
				EndIf
			EndIf
		EndWhile
		MenuActive.setValue(1)
		GoToState("")
	EndEvent

EndState

function ActivateAllAvailable()
	int index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].AttemptActivate()
	endwhile
endFunction

function DeactivateAll(bool cheated = False)
	int index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].AttemptDeactivate(cheated)
	endwhile
endFunction

function FullResetAll()
	int index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].AttemptFullReset()
	endwhile
endFunction

;===============================================================================================================================
;====================================		Shared Functions		================================================
;================================================================================================

; Presents the user with a list of item slots and calls the menu function on the slot selected
Function EquipmentSlotMenu()
	bool abMenu = True
	int aiButton
	While abMenu && MenuActive.Value
		aiButton = EquipSlotSelect.Show() ; Main Menu
		if aiButton == 0		;back return
			abMenu = False
		elseif aiButton == 9	;cancel
			MenuActive.SetValue(0)
		else
			AbilitySelectMenu(Equipment[aiButton - 1].AbilityAliasArray)
		EndIf
	EndWhile
EndFunction

;___________________________________________________________________________________________________________________________
;							Empty placehoder functions for overwriting
Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0);,  bool abMenu = True)
	Debug.Trace(self+ " accessed AbilitySelectMenu() in the Empty State")
EndFunction

Function SetButton(INEQ_AbilityAliasProperties[] array, bool belowMax)
	Debug.Trace(self+ " accessed SetButton() in the Empty State")
EndFunction

;___________________________________________________________________________________________________________________________
;							Functions to allow other objects to shortcut to parts of the menu
Function StartRegister()
	GoToState("Register")
endFunction

Function StartUnlocking()
	GoToState("Unlocking")
Endfunction

Function StartSelectAbilities()
	GoToState("SelectAbilities")
endFunction

Function StartAbilityOptions()
	GoToState("AbilityOptions")
EndFunction

Function StartOtherOptions()
	GoToState("OtherOptions")
EndFunction
