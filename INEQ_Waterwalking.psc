Scriptname INEQ_Waterwalking extends ActiveMagicEffect  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto
ReferenceAlias property Alias_Armour auto
Spell property abWaterwalking auto

String  Property  AnimWalking1  =  "FootRight"  Autoreadonly		; any movement with left foot
String  Property  AnimWalking2  =  "FootLeft"  Autoreadonly			; any movement with right foot
String  Property  AnimJump  =  "JumpUp"  Autoreadonly				; jumping up animation

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

State Unequipped
	
	Event OnBeginState()
		SelfRef.removespell(abWaterwalking)			;SelfREF.setActorValue("waterwalking", 0)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("equip")
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Swimming
	
	Event OnBeginState()
		SelfRef.removespell(abWaterwalking)				;SelfREF.setActorValue("waterwalking", 0)
		RegisterForAnimationEvent(selfRef, AnimJump)		
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == selfRef) &&  (EventName == AnimJump) 
			GoToState("Waterwalking")
		endif
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent		
	
	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, AnimJump)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Waterwalking

	Event OnBeginState()
		SelfRef.addspell(abWaterwalking, false)						;SelfRef.setActorValue("waterwalking", 1)
		RegisterForAnimationEvent(selfRef, AnimWalking1)				
		RegisterForAnimationEvent(selfRef, AnimWalking2)				
	EndEvent

	; By sneaking and looking down you can enter the water
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  (selfRef.getAngleX() > 80 ) && (akSource == selfRef) &&( ( EventName == AnimWalking1) || ( EventName == AnimWalking2) )
			GoToState("Swimming")
		endif
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, AnimWalking2)	
		UnregisterForAnimationEvent(selfRef, AnimWalking1) 
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )
	if akReference.HasKeyword(KW_EnbaleAbility)
;		Debug.Notification("KW found")
		EquipRef = akReference
		GoToState("Swimming")
;	else
;		Debug.Notification("Missing KW")
	endif
EndFunction

;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
;		Debug.Notification("Unequip event...")
;		Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
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
	UnregisterForAnimationEvent(selfRef, AnimWalking1)
	UnregisterForAnimationEvent(selfRef, AnimWalking2)
	UnregisterForAnimationEvent(selfRef, AnimJump)
	SelfRef.removespell(abWaterwalking)						;SelfREF.setActorValue("waterwalking", 0)
EndEvent