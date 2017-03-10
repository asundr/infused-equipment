Scriptname INEQ_AbilityRegister extends ReferenceAlias  

ReferenceAlias	Property	Alias_Shield001	Auto
ReferenceAlias	Property 	Alias_Feet001	Auto
ReferenceAlias	Property 	Alias_Head001  	Auto
ReferenceAlias	Property 	Alias_Body001  	Auto
ReferenceAlias	Property 	Alias_Hands001 	Auto

ReferenceAlias	Property	Alias_Bow001		Auto
ReferenceAlias  Property	Alias_Dagger001	Auto
ReferenceAlias  Property	Alias_Sword001		Auto

Keyword 	Property	ArmorBoots		Auto
Keyword 	Property	ArmorCuirass	Auto
Keyword 	Property	ArmorGauntlets	Auto
Keyword 	Property	ArmorHelmet	Auto
Keyword 	Property	ArmorShield		Auto
Keyword 	Property	ClothingBody	Auto
Keyword 	Property	ClothingFeet	Auto
Keyword 	Property	ClothingHands	Auto
Keyword 	Property	ClothingHead	Auto

Keyword 	Property	WeapTypeBattleaxe		Auto
Keyword 	Property	WeapTypeBow			Auto
Keyword 	Property	WeapTypeDagger		Auto
Keyword 	Property	WeapTypeGreatsword	Auto
Keyword 	Property	WeapTypeMace			Auto
Keyword 	Property	WeapTypeStaff			Auto
Keyword 	Property	WeapTypeSword		Auto
Keyword 	Property	WeapTypeWarAxe		Auto
Keyword 	Property	WeapTypeWarhammer	Auto


Formlist	 Property  AbilitySources  Auto

Actor  Property  SettingDialogue  Auto


ObjectReference ObjectRef
ObjectReference SelfRef


Event OnInit()
	SelfRef = self.GetReference()
EndEvent
	

State Register

	Event OnBeginState()
		Debug.Notification("Drop weapon to register it")
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
;		Debug.Notification("Item Dropped...")
		if  AbilitySources.HasForm(akBaseItem)
			;

		elseif 	(akBaseItem as Armor)

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
		SelfRef.AddItem(akItemReference)
		resetRequest()
	EndEvent

	Function resetRequest()
		GoToState("")
	Endfunction

	Event OnEndState()
		(ObjectRef as Arun_Test7).resetRequest()
	EndEvent

EndState




State Settings

	Event OnBeginState()
		Debug.Notification("Exit inventory to access settings")
		;add dialogue actor
	EndEvent








	Function resetRequest()
		GoToState("")
	Endfunction

	Event OnEndState()
		(ObjectRef as Arun_Test7).resetRequest()
	EndEvent

EndState





Function resetRequest()
;	Debug.Notification("Already reset")
endFunction


function ForceRefIfActive(ReferenceAlias akEquipmentAlias, ObjectReference akItemReference)
	(SelfRef as Actor).UnequipItem(akEquipmentAlias.GetRef().GetBaseObject() as Form, 	FALSE, 	FALSE)			; TESTING
	((akEquipmentAlias as ReferenceAlias) as INEQ_EquipmentScript).ChangeReference(akItemReference)
	Debug.Notification("Item has been infused!")
endFunction


Function StartRegister(ObjectReference akObject)
	GoToState("Register")
	ObjectRef = akObject
endFunction


Function StartSettings(ObjectReference akObject)
		GoToState("Settings")
		ObjectRef = akObject
endFunction
