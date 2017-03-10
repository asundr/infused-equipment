Scriptname INEQ_AbilityRegister extends ReferenceAlias 
{Core script that handles plugins, abilities and mod options via menus}

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
Message		Property	ChargeOptions	Auto
Message		Property	OtherOptions	Auto
Message		Property	FullResetWarn	Auto

GlobalVariable	Property	CheatMode	Auto
GlobalVariable	Property	MenuActive	Auto

Formlist	Property	RechargeQuestlist	Auto
Formlist	Property	AbilityToPlayerList	Auto

Quest		Property	MainQuest			Auto

Actor		Property	SelfRef				Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	InfuseTimout	=	5.0		Autoreadonly

;===========================================  Variables  ============================================================================>
bool bInfusionBusy			= False
bool bMaintenanceBusy		= False
bool bPluginRegistered		= False
bool bPluginRemoved			= False
int  iPluginRegisterPending	= 0

INEQ_MenuButtonConditional	Button
INEQ_ListenerMenu			ListenerMenu

INEQ_EquipmentScript[]		Equipment
INEQ_RechargeBase[]			RechargeList

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	Button = MainQuest as INEQ_MenuButtonConditional
	ListenerMenu = MainQuest as INEQ_ListenerMenu
	Equipment = new INEQ_EquipmentScript[8]
	RechargeList = new INEQ_RechargeBase[16]
	Equipment[0] = Alias_Sword001 	as INEQ_EquipmentScript
	Equipment[1] = Alias_Dagger001 	as INEQ_EquipmentScript
	Equipment[2] = Alias_Bow001 	as INEQ_EquipmentScript
	Equipment[3] = Alias_Shield001 	as INEQ_EquipmentScript
	Equipment[4] = Alias_Head001 	as INEQ_EquipmentScript
	Equipment[5] = Alias_Body001 	as INEQ_EquipmentScript
	Equipment[6] = Alias_Hands001 	as INEQ_EquipmentScript
	Equipment[7] = Alias_Feet001 	as INEQ_EquipmentScript
	if iPluginRegisterPending == 0
		makeRechargeList()
	endif
	Debug.Trace("[INEQ] Core initiated")
EndEvent
;___________________________________________________________________________________________________________________________

Event OnPlayerLoadGame()
	Utility.Wait(0.01)
	if !bMaintenanceBusy && !iPluginRegisterPending
		Maintenance()
	endif
EndEvent
;___________________________________________________________________________________________________________________________

State MaintenanceBusy

	; Waits until a plugin all currently installing plugins are installed, then calls maintenance() 
	Event OnUpdate()
		if bMaintenanceBusy || iPluginRegisterPending > 1
			RegisterForSingleUpdate(1.0)
		else
			iPluginRegisterPending -= 1
			maintenance()
		endif
	EndEvent
	
	; Overrides of menu shortcut funcitons to prevent ineference with maintenence()
	Function MainMenu()
		Debug.Notification("Updating INEQ plugins, please wait...")
	endFunction
	Function StartRegister()
		Debug.Notification("Updating INEQ plugins, please wait...")
	endFunction
	Function StartUnlocking()
		Debug.Notification("Updating INEQ plugins, please wait...")
	Endfunction
	Function StartSelectAbilities()
		Debug.Notification("Updating INEQ plugins, please wait...")
	endFunction
	Function StartAbilityOptions()
		Debug.Notification("Updating INEQ plugins, please wait...")
	EndFunction
	Function StartChargeOptions()
		Debug.Notification("Updating INEQ plugins, please wait...")
	EndFunction
	Function StartOtherOptions()
		Debug.Notification("Updating INEQ plugins, please wait...")
	EndFunction

EndState
;___________________________________________________________________________________________________________________________

; Called by plugins to ensure maintenance() is only called once when a plugin is added
Function PluginInstallStart()
	if !bPluginRegistered
		bPluginRegistered = True
	endif
	iPluginRegisterPending += 1
Endfunction
;___________________________________________________________________________________________________________________________

; Called after plugin has been installed, first call initiates a pending call to maintenance()
Function PluginInstallFinish()
	if 	iPluginRegisterPending > 1
		iPluginRegisterPending -= 1
		return
	else
		Debug.Notification("Installing new INEQ plugin(s)...")
	endif
	GoToState("MaintenanceBusy")
	RegisterForSingleUpdate(0.1)
endfunction
;___________________________________________________________________________________________________________________________

; Cleans formlists, refreshes recharge list and triggers maintenence on equipment slots
Function maintenance()
	bMaintenanceBusy = True
	Debug.Trace("[INEQ] Maintenance start...")
	
	RemoveNonesFromList(AbilityToPlayerList)
	RemoveNonesFromList(RechargeQuestlist)
	
	; Referesh Equipment ability lists
	int i = Equipment.length
	while i > 0
		i -= 1
		RemoveNonesFromList(Equipment[i].AbilityQuestList)
		Equipment[i].maintenance()
	endwhile
	
	makeRechargeList()
	
	; Notifies player of any update to INEQ plugins
	if bPluginRegistered || bPluginRemoved
		bPluginRemoved = False
		bPluginRegistered = False
		Debug.Notification("INEQ plugins have been updated!")
	endif
	
	bMaintenanceBusy = False
	Debug.Trace("[INEQ] Maintenance finished")
	GoToState("")
EndFunction
;___________________________________________________________________________________________________________________________

; Removes None entries from a Formlist (due to removing plugins)
Function RemoveNonesFromList(Formlist list)
	int i = 0
	if  !list.getAt(i)
		; Notifies player if plugin has been removed
		if !bPluginRemoved
			bPluginRemoved = True
			Debug.Notification("INEQ plugin(s) have been removed...")
			Debug.Trace("[INEQ] Cleaning removed plugins from Formlists")
		endif
		
		; Stores Quests from a list into an array, then reverts the form
		Quest[] QuestArr = new Quest[16]
		int count = 1
		i += 1
		int size = list.getSize()
		while i < size
			if list.getAt(i)
				QuestArr[i - count] = list.getAt(i) as Quest
			else
				count += 1
			endif
			i += 1
		endwhile
		list.Revert()
		
		; Adds the previously stored Quests back to the Formlist
		i = 1
		size -= count
		while i < size
			list.Addform(QuestArr[i])
			i += 1
		endwhile
	endif	
EndFunction
;___________________________________________________________________________________________________________________________

; Refresh Recharge alias list
Function makeRechargeList()
	INEQ_RechargeBase[] temp = new INEQ_RechargeBase[16]
	int ListSize = RechargeQuestlist.GetSize()
	int iList = 0
	int count = 0
	while iList < ListSize
		Quest  RechargeQuest = RechargeQuestlist.GetAt(iList) as Quest
		if (RechargeQuest)
			int iAlias = 0
			ReferenceAlias ref = RechargeQuest.GetAlias(iAlias) as ReferenceAlias
			while ( ref )
				if ref != none && (ref as INEQ_RechargeBase).getName() != ""
					temp[count] = ref as INEQ_RechargeBase
					count += 1
				endif
				iAlias += 1
				ref = RechargeQuest.GetAlias(iAlias) as ReferenceAlias
			endwhile
		endif
		iList += 1
	endwhile
	RechargeList = temp
EndFunction

;===============================================================================================================================
;====================================			Main			================================================
;================================================================================================

Function MainMenu()
	int aiButton
	MenuActive.setValue(1)
	while MenuActive.Value
		aiButton = SelectAction.Show()
		if aiButton == 0
			StartRegister()
			MenuActive.setValue(0)
		elseif aiButton == 1
			StartUnlocking()
		elseif aiButton == 2
			StartSelectAbilities()
		elseif aiButton == 3
			StartAbilityOptions()
		elseif aiButton == 4
			StartChargeOptions()
		elseif aiButton == 5
			StartOtherOptions()
		elseif aiButton == 6
			MenuActive.setValue(0)
		endif
	endwhile
EndFunction

;===============================================================================================================================
;====================================	  	  Register			================================================
;================================================================================================

State Register

	Event OnBeginState()
		Debug.Notification("Drop apparel or a weapon to infuse it")		
		RegisterForSingleUpdate(InfuseTimout)
	EndEvent
	;___________________________________________________________________________________________________________________________

	Event OnUpdate()
		if !bInfusionBusy
			Debug.Notification("Infusion timed out")
			GoToState("")
		endif
	EndEvent
	;___________________________________________________________________________________________________________________________

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
		bInfusionBusy = True
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
		SelfRef.AddItem(akItemReference, 1, True)
		bInfusionBusy = False
		UnregisterForUpdate()
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	Event OnEndState()
		UnregisterForUpdate()
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

function ForceRefIfActive(ReferenceAlias akEquipmentAlias, ObjectReference akItemReference)
	if akEquipmentAlias.getReference()
		SelfRef.UnequipItem(akEquipmentAlias.GetRef().GetBaseObject() as Form, 	False, 	False)
	endif
	((akEquipmentAlias as ReferenceAlias) as INEQ_EquipmentScript).ChangeReference(akItemReference)
	Debug.Notification("Item has been infused!")
endFunction

;===============================================================================================================================
;====================================	    Unlocking			================================================
;================================================================================================
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

;===============================================================================================================================
;====================================	   Select Abilities		================================================
;================================================================================================
State SelectAbilities

	Event OnBeginState()
		MenuActive.SetValue(1)
		EquipmentSlotMenu()
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	; Menu for (de)acitvating available abilities. Shows 4  options at a time, pressing next (button 9) recursively calls itself at a later index
	Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0)
		; Iterates ability list to find 4 unlocked abilities from a given index
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
		bool abMenu = True
		MenuActive.SetValue(1)
		While abMenu && MenuActive.Value
			Debug.MessageBox(messageText)
			setButton(currAbilities, index  < max)
			aiButton = AbilitySelect.Show()
			if aiButton == 0			;Back Button
				abMenu = False	
			elseif aiButton == 9		;Next Button
				AbilitySelectMenu(AbilityArray, index, index)
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

;===============================================================================================================================
;====================================	   Ability Options		================================================
;================================================================================================
State AbilityOptions

	Event OnBeginState()
		MenuActive.SetValue(1)
		EquipmentSlotMenu()
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	; Shows 8 options menus at a time, pressing next (button 9) recursively calls itself at a later index
	Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0)
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
			if aiButton == 0		; Back
				abMenu = False	
			elseif aiButton == 9	; Cancel
				AbilitySelectMenu(AbilityArray, index, index)
			else
				currAbilities[aiButton - 1].AbilityMenu(Button, ListenerMenu, MenuActive)
			endif
		endwhile
		
	EndFunction
	;___________________________________________________________________________________________________________________________
	
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
		if belowMax	; Next button
			Button.Set(9)
		endif
	EndFunction
	
EndState

;===============================================================================================================================
;====================================	   Charge Options		================================================
;================================================================================================
State ChargeOptions

	Event OnBeginState()
		MenuActive.SetValue(1)
		ChargeSelectMenu(RechargeList)
		GoToState("")
	EndEvent
	;___________________________________________________________________________________________________________________________

	; Shows 8 charge sources at a time, pressing next (button 9) recursively calls itself at a later index
	Function ChargeSelectMenu(INEQ_RechargeBase[] RechargeArray, int startIndex = 0, int index = 0)
	
		int max = RechargeArray.length
		INEQ_RechargeBase[] currRecharge = new INEQ_RechargeBase[8]
		String messageText = ""
		int count = 0
		if RechargeArray[index] == none
			index = max
		endif
		while index < max && count < 8
			if RechargeArray[index].hasMenu()
				currRecharge[count] = RechargeArray[index]
				count += 1
				messageText += (count)+ ") " +RechargeArray[index].getName()+ "\n"
			endif
			index += 1
			
			; b/c array size may be larger than number of filled elements
			if RechargeArray[index] == none
				index = max
			endif
		endwhile

		; Notifies player if they don't have any abilities in that slot
		if currRecharge[0] == none && startIndex == 0
			Debug.Notification("You don't have any abilities of this type")
			return
		endif
		
		int aiButton
		bool abMenu = True
		MenuActive.SetValue(1)
		while abMenu && MenuActive.Value
			Debug.MessageBox(messageText)
			setButtonRecharge(currRecharge, index  < max)
			aiButton = ChargeOptions.Show()
			if aiButton == 0
				abMenu = False
			elseif aiButton == 9
				ChargeSelectMenu(RechargeArray, index, index)
			else
				currRecharge[aiButton - 1].ChargeMenu(Button, ListenerMenu, MenuActive)
			endif
		endwhile
	
	EndFunction
	;___________________________________________________________________________________________________________________________

	; Formats a Button to Display the options for accessing the Abilities options and a next buttton if necessary
	Function setButtonRecharge(INEQ_RechargeBase[] array, bool belowMax)
		Button.clear()
		int index = array.length
		while index > 0
			index -= 1
			if array[index] != none
				Button.Set(index + 1)
			endif
		endwhile
		if belowMax	; Next button
			Button.Set(9)
		endif
	EndFunction
	
EndState

;===============================================================================================================================
;====================================	   Other Options		================================================
;================================================================================================

State OtherOptions

	Event OnBeginState()
		bool abMenu = True
		MenuActive.SetValue(1)
		int aiButton = 0
		while abMenu && MenuActive.Value
			aiButton = OtherOptions.Show()	; Main Menu
			if aiButton == 0
				abMenu = False				; back button
			elseif aiButton == 1
				ActivateAll()
				Debug.Notification("All available abilities have been activated")
			elseif aiButton == 2
				DeactivateAll()
				Debug.Notification("All abilities have been deactivated")
			elseif aiButton == 3
				RestoreDefaultsAll()
				Debug.Notification("Defaults have been restored")
			elseif aiButton == 4
				aiButton = FullResetWarn.Show()
				if aiButton == 0
					FullResetAll(True)
					Debug.Notification("All abilities have been completely reset and must be unlocked again")
				elseif aiButton == 1
					FullResetAll()
					Debug.Notification("Everything except for learned abilities have been reset")
				endif
			elseif aiButton == 5 
				CheatMode.SetValue(1)
				Debug.Notification("Cheat mode activated")
			elseif aiButton == 6 
				CheatMode.SetValue(0)
				DeactivateAll(True)
				Debug.Notification("Cheat mode deactivated")
			endif
		endwhile
		MenuActive.setValue(1)
		GoToState("")
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

; Activates all unlocked or cheated abilities
Function ActivateAll()
	int index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].ActivateAll()
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Deactivates all activated abilities
function DeactivateAll(bool cheated = False)
	int index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].DeactivateAll(cheated)
	endwhile
endFunction
;___________________________________________________________________________________________________________________________

; Resets all properties in Recharge sources and Abilities
Function RestoreDefaultsAll()
	int index = RechargeList.length
	while index > 0
		index -= 1
		if RechargeList[index]
			RechargeList[index].RestoreDefaultFields()
		endif
	endwhile
	index = Equipment.length
	while index > 0
		index -= 1
		Equipment[index].RestoreDefaultFields()
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Deactivates (and locks) abilities, then stops and starts every quest to reset
function FullResetAll(bool bLock = False)
	Debug.Trace("[INEQ] Full reset start...")
	CheatMode.SetValue(1)
	ActivateAll()
	formlist[] EquipmentQuests = new formlist[8]
	int i = Equipment.length
	while i > 0
		i -= 1
		EquipmentQuests[i] = Equipment[i].AbilityQuestList
		Equipment[i].FullReset(bLock)
	endwhile
	CheatMode.SetValue(0)
	
	Alias_Sword001.GetOwningQuest().stop()

	i = EquipmentQuests.length
	while i > 0
		i -= 1
		StopQuestFormlist(EquipmentQuests[i])
	endwhile
	
	i = 0
	int max = RechargeList.length
	while i < max && RechargeList[i]
		RechargeList[i].FullReset()
		i += 1
	endwhile
	
	StopQuestFormlist(AbilityToPlayerList)
	StopQuestFormlist(RechargeQuestlist)
	
	StartQuestFormList(RechargeQuestlist)
	StartQuestFormlist(AbilityToPlayerList)
	
	i = EquipmentQuests.length
	while i > 0
		i -= 1
		StartQuestFormlist(EquipmentQuests[i])
	endwhile
	
	Alias_Sword001.GetOwningQuest().start()
	Debug.Trace("[INEQ] Full reset finished")
endFunction
;___________________________________________________________________________________________________________________________

; Stops every Quest in a Formlist
Function StopQuestFormlist(Formlist list)
;	String s = "["
	int i = list.GetSize()
	while i > 0
		i -= 1
;		s += list.GetAt(i) + ", "
		(list.GetAt(i) as Quest).Stop()
	endwhile
;	Debug.Trace(s + "]")
EndFunction
;___________________________________________________________________________________________________________________________

; Starts every Quest in a Formlist
Function StartQuestFormlist(Formlist list)
;	String s = "["
	int i = 0
	int max = list.GetSize()
	while i < max
;		s += list.GetAt(i) + ", "
		(list.GetAt(i) as Quest).Start()
		i += 1
	endwhile
;	Debug.Trace(s + "]")
EndFunction

;===============================================================================================================================
;====================================		Shared Functions		================================================
;================================================================================================

; Presents the user with a list of item slots and calls the menu function on the slot selected
Function EquipmentSlotMenu()
	bool abMenu = True
	int aiButton
	While abMenu && MenuActive.Value
		aiButton = EquipSlotSelect.Show()
		if aiButton == 0		; back
			abMenu = False
		elseif aiButton == 9	; cancel
			MenuActive.SetValue(0)
		else
			AbilitySelectMenu(Equipment[aiButton - 1].AbilityAliasArray)
		endif
	EndWhile
EndFunction

;___________________________________________________________________________________________________________________________
;							Empty placehoder functions for overwriting
Function AbilitySelectMenu(INEQ_AbilityAliasProperties[] AbilityArray, int startIndex = 0, int index = 0);,  bool abMenu = True)
	Debug.Trace(self+ " accessed AbilitySelectMenu() in the Empty State")
EndFunction

Function ChargeSelectMenu(INEQ_RechargeBase[] RegisterArray, int startIndex = 0, int index = 0)
	Debug.Trace(self+ " accessed ChargeSelectMenu() in Empty state")
EndFunction

Function SetButton(INEQ_AbilityAliasProperties[] array, bool belowMax)
	Debug.Trace(self+ " accessed SetButton() in the Empty State")
EndFunction

Function setButtonRecharge(INEQ_RechargeBase[] array, bool belowMax)
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

Function StartChargeOptions()
	GoToState("ChargeOptions")
EndFunction

Function StartOtherOptions()
	GoToState("OtherOptions")
EndFunction
;___________________________________________________________________________________________________________________________

; Prints the contents of a Formlist to the Papyrus log
function TraceFormlist(Formlist list, String s)
	int size = list.getsize()
	s += " " + iPluginRegisterPending + " " + size + " ["
	int i = 0
	while i < size
		s += list.getat(i) + ", "
		i += 1
	endwhile
	Debug.trace(s + "]")
Endfunction
