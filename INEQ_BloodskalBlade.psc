Scriptname INEQ_BloodskalBlade extends activemagiceffect  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto

Spell Property DLC2BloodskalBladeSpellHoriz auto
Spell Property DLC2BloodskalBladeSpellVert auto

String  Property  WeaponSwing  = 	"weaponSwing"  	Autoreadonly			; weapon attack
;String  Property  BlockStart  =  "blockStartOut"  	Autoreadonly		; start blocking

;===========================================  Variables  ============================================================================>

Actor SelfRef
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	SelfRef = akCaster
	GoToState( "Unequipped")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

EndState

;___________________________________________________________________________________________________________________________

State Unequipped
	
	Event OnBeginState()
		
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("equip")
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Ready
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)

		int direction = ( selfRef.GetAnimationVariableFloat( "Direction" ) * 4) as int

		if (akSource == Game.GetPlayer())
			if  eventname == WeaponSwing &&\
					selfref.GetAnimationVariableBool("bAllowRotation") &&\
				   !selfref.GetAnimationVariableBool("isBlocking") &&\
				   !selfref.GetAnimationVariableBool("isBashing") &&\
				   !selfref.GetAnimationVariableBool("isSneaking")
				if (   direction % 2 == 0)
					DLC2BloodskalBladeSpellVert.cast(akSource)
				else
					DLC2BloodskalBladeSpellHoriz.cast(akSource)
				endif
			endif
		endif
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponSwing)
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
	UnregisterForAnimationEvent(selfRef, WeaponSwing)
EndEvent