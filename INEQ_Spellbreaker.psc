Scriptname INEQ_Spellbreaker extends INEQ_AbilityBaseShield  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell property abSpellbreaker auto

String  Property  BlockStop  = 	"blockStop"  	Autoreadonly			; stop blocking
String  Property  BlockStart  =  "blockStartOut"  	Autoreadonly		; start blocking

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(selfRef, BlockStop)
	UnregisterForAnimationEvent(selfRef, BlockStart)
	SelfRef.removespell(abSpellbreaker)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

;State Unequipped
	
;	Event OnBeginState()
;		Debug.Notification("Enter Unequip")
;	EndEvent

;EndState

;___________________________________________________________________________________________________________________________

State Ready
	
	Event OnBeginState()
;		Debug.Notification("Enter Ready")
		SelfRef.removespell(abSpellbreaker)
		RegisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == selfRef) &&  (EventName == BlockStart)
			GoToState("Blocking")
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Blocking

	Event OnBeginState()
;		Debug.Notification("Enter blocking")
		SelfRef.addspell(abSpellbreaker, false)
		RegisterForAnimationEvent(selfRef, BlockStop)				
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  (akSource == selfRef) && ( EventName == BlockStop)
			GoToState("Ready")
		endif
	EndEvent

	Event OnEndState()
		SelfRef.removespell(abSpellbreaker)
		UnregisterForAnimationEvent(selfRef, BlockStop) 
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

;Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("SB-EquipEvent: ShieldRef:" +SelfRef.GetEquippedShield().getFormID()+ ", EquipRef:" +EquipRef.GetBaseObject().GetFormID())
;	
;	if akReference.HasKeyword(KW_EnbaleAbility)
;		EquipRef = akReference
;		GoToState("Ready")
;	elseif SelfRef.GetEquippedShield() && SelfRef.GetEquippedShield() == (EquipRef.GetBaseObject() as Armor)
;		GoToState("Ready")
;		;check for kw
;		Debug.Notification("Old shield equipped. HasKW: " +SelfRef.GetEquippedShield().HasKeyword(KW_EnbaleAbility))
;	endif
;EndFunction

;___________________________________________________________________________________________________________________________

;Function UnequipCheck(ObjectReference akReference)
;		if (akReference == EquipRef)
;			Debug.Notification("SB: Unequipped")
;			;EquipRef = none
;			GoToState("Unequipped")
;		endif
;EndFunction
