Scriptname INEQ_ForcefulDraw extends ActiveMagicEffect  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto

Spell property ForcefulDrawSpell auto
Spell property VisualsSpell auto

Explosion property DLC1SC_LightningBoltImpactExplosion auto
Explosion property DLC1VampDetectLifeExplosion auto


String  Property  WeaponDrawn  = "WeaponDraw"  	Autoreadonly			; Draw weapon


;===========================================  Variables  ============================================================================>

Actor SelfRef
ObjectReference EquipRef

bool bRecharged

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	selfRef = akCaster
	bRecharged = True
	GoToState( "Unequipped")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

EndState

State Unequipped

	Event OnBeginState()
;		Debug.Notification("State unequippped")
	EndEvent
	
	Event OnUpdate()
		bRecharged = True
		Debug.Notification("Forceful Draw recharged!")
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("equip")
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Ready

	Event OnBeginState()
;		Debug.Notification("State Ready")
		registerForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
;			Debug.Notification("Weapon is drawn")
			if selfRef.isInCombat()
				if !selfRef.isSneaking()
					CastForcefulDraw()
				else
;					Debug.Notifiction("Player is sneaking, not cast")
				endif
			else
;				Debug.Notifiction("Player is not in combat, not cast")
			endif
	endEVENT

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Recharging

	Event OnBeginState()
		if(bRecharged)
			GoToState("Ready")
		else
			RegisterForSingleUpdate(300) ;900
		endif
	EndEvent

	Event OnUpdate()
		bRecharged = True
		Debug.Notification("Forceful Draw recharged!")
		GoToState("Ready")
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent

	Event OnEndState()
		
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function CastForcefulDraw()
	selfRef.placeatme(DLC1SC_LightningBoltImpactExplosion)
	VisualsSpell.cast(selfRef,selfRef)
	selfRef.placeatme(DLC1VampDetectLifeExplosion)
	ForcefulDrawSpell.cast(selfRef)
	bRecharged = False
	GoToState("Recharging")
EndFunction

;___________________________________________________________________________________________________________________________

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )
	if akReference.HasKeyword(KW_EnbaleAbility)
;		Debug.Notification("KW found")
		EquipRef = akReference
		GoToState("Recharging")
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
	UnregisterForUpdate()
	UnregisterForAnimationEvent(selfRef, WeaponDrawn)
EndEvent