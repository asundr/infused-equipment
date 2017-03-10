Scriptname INEQ_Spellbreaker extends ActiveMagicEffect  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto
ReferenceAlias property Alias_Armour auto
Spell property abSpellbreaker auto

String  Property  BlockStop  = 	"blockStop"  	Autoreadonly			; stop blocking
String  Property  BlockStart  =  "blockStartOut"  	Autoreadonly		; start blocking

;===========================================  Variables  ============================================================================>

Actor SelfRef
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	selfRef = akCaster
	GoToState( "Unequipped")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

EndState

State Unequipped
	
	Event OnBeginState()
		Debug.Notification("Enter Unequip")
		SelfRef.removespell(abSpellbreaker)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("Equip")
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Ready
	
	Event OnBeginState()
		Debug.Notification("Enter Ready")
		SelfRef.removespell(abSpellbreaker)
		RegisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == selfRef) &&  (EventName == BlockStart)
			GoToState("Blocking")
		endif
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Blocking

	Event OnBeginState()
		Debug.Notification("Enter blocking")
		SelfRef.addspell(abSpellbreaker, false)
		RegisterForAnimationEvent(selfRef, BlockStop)				
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  (akSource == selfRef) && ( EventName == BlockStop)
			GoToState("Ready")
		endif
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, BlockStop) 
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )

	Debug.Notification("equpped:" +(SelfRef.GetEquippedShield() as Form)+ ", Ref base:" +EquipRef.GetBaseObject())

	if akReference.HasKeyword(KW_EnbaleAbility)		; || (SelfRef.GetEquippedShield() as Form) == EquipRef.GetBaseObject() ; might cause ward to persiste when equiping bow then 2H after using shield
;		Debug.Notification("KW found")
		EquipRef = akReference
		GoToState("Ready")
;	else
;		Debug.Notification("Missing KW")
	endif
EndFunction

;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
;		Debug.Notification("Unequip event...")
		Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
		if (akReference == EquipRef)
;			Debug.Notification("Unequipped, effect disabled")
			EquipRef = none
			GoToState("Unequipped")
;		else
;			Debug.Notification("(" +akReference.getFormID()+ ") Not the equipped ref")
		endif
EndFunction

;___________________________________________________________________________________________________________________________

Function ResetState()
	if !EquipRef.HasKeyword(KW_EnbaleAbility)
		GoToState("Unequipped")
	endif
EndFunction

;===============================================================================================================================
;====================================		   Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(selfRef, BlockStop)
	UnregisterForAnimationEvent(selfRef, BlockStart)
	SelfRef.removespell(abSpellbreaker)
EndEvent
