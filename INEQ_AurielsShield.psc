Scriptname INEQ_AurielsShield extends ActiveMagicEffect  
{Script for reflecting shield to appear to reflect certain incoming spells.}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto

Spell  Property ChargeSpell1 Auto
Spell  Property ChargeSpell2 Auto
Spell  Property ChargeSpell3 Auto

Sound Property ChargSound Auto

ImagespaceModifier Property ChargeIMod Auto
ImagespaceModifier Property BlastIMod Auto

GlobalVariable Property TimesHit Auto
GlobalVariable Property CurrentStage Auto

Int Property HitsUntilFirstCharge = 5 Auto
{Hit's required until the shiled reaches it's first charge (DEFAULT = 5)}
Int Property HitsUntilSecondCharge = 10 Auto
{Hit's required until the shiled reaches it's first charge (DEFAULT = 10)}
Int Property HitsUntilThirdCharge = 15 Auto
{Hit's required until the shiled reaches it's first charge (DEFAULT = 15)}

String  Property  BashExit   =  "bashExit"  	Autoreadonly		; exit bashing
String  Property  BashStop   =  "bashStop"  	Autoreadonly		; stop bashing
String  Property  BashRelease =  "bashRelease"	Autoreadonly		; power bashing

;===========================================  Variables  ============================================================================>

;Actor PlayerRef
Actor SelfRef
ObjectReference EquipRef
bool RefIsPlayer

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	SelfRef = akCaster
	RefIsPlayer = SelfRef == Game.GetPlayer()
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

State Equipped
	
	Event OnBeginState()
		if (RefIsPlayer)
			registerForAnimationEvent(selfRef, BashRelease)
		else
			registerForAnimationEvent(selfRef, BashExit)
			registerForAnimationEvent(selfRef, BashStop)
		endif
		RegisterforSingleUpdate(0)
	EndEvent

	
	Event OnUpdate()
		;debug.trace("Updating once")
		if CurrentStage.GetValue() == 1
			;debug.Notification("Shield at LEVEL 1")
			selfRef.SetSubGraphFloatVariable("fDampRate", 1)
			selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.75)
		elseif CurrentStage.GetValue() == 2
			;debug.Notification("Shield at LEVEL 2")
			selfRef.SetSubGraphFloatVariable("fDampRate", 1)
			selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.85)
		elseif CurrentStage.GetValue() == 3
			;debug.Notification("Shield at LEVEL 3")
			selfRef.SetSubGraphFloatVariable("fDampRate", 1)
			selfRef.SetSubGraphFloatVariable("fToggleBlend", 1)
		endif
	EndEvent
	
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)

		if abHitBlocked 
			;debug.Trace("I've been hit in the SHIELD WHILE BLOCKING!")
			TimesHit.SetValue(TimesHit.GetValue() + 1)
			ChargSound.play(selfRef) 

			if (TimesHit.GetValue() == HitsUntilFirstCharge)
				;debug.Notification("Shield at LEVEL 1")
				selfRef.SetSubGraphFloatVariable("fDampRate", 1)
				selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.75)
				if RefIsPlayer
					ChargeIMod.Apply()
				endif
				CurrentStage.SetValue(1)
			elseif (TimesHit.GetValue() == HitsUntilSecondCharge)
				;debug.Notification("Shield at LEVEL 2")
				selfRef.SetSubGraphFloatVariable("fDampRate", 1)
				selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.85)
				if RefIsPlayer
					ChargeIMod.Apply()
				endif
				CurrentStage.SetValue(2)
			elseif (TimesHit.GetValue() == HitsUntilThirdCharge)
				;debug.Notification("Shield at LEVEL 3")
				selfRef.SetSubGraphFloatVariable("fDampRate", 1)
				selfRef.SetSubGraphFloatVariable("fToggleBlend", 1)
				if RefIsPlayer
					ChargeIMod.Apply()
				endif
				CurrentStage.SetValue(3)
			endif

		else
			;debug.Trace("I've been hit but NOT in the shield while blocking!")
		endif

	EndEvent
	
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		
		if RefIsPlayer
			if (eventName == BashRelease)
				;debug.Trace("I'm catching the bashRelease anim event")
				if CurrentStage.GetValue() == 1
					BlastIMod.Apply(0.3)
					ChargeSpell1.cast(selfRef)
				elseif CurrentStage.GetValue() == 2
					BlastIMod.Apply(0.6)
					ChargeSpell2.cast(selfRef)	
				elseif CurrentStage.GetValue() == 3
					BlastIMod.Apply(1)
					ChargeSpell3.cast(selfRef)	
				endif	
				selfRef.SetSubGraphFloatVariable("fToggleBlend", 0)
				CurrentStage.SetValue(0)
				TimesHit.SetValue(0)
				;debug.Notification("Shield at LEVEL 0")
			endif
		else
			if (eventName == BashExit) || (eventName == BashStop)
				;debug.Trace("I'm catching the bashRelease anim event")
				if CurrentStage.GetValue() == 1
					ChargeSpell1.cast(selfRef)
				elseif CurrentStage.GetValue() == 2
					ChargeSpell2.cast(selfRef)	
				elseif CurrentStage.GetValue() == 3
					ChargeSpell3.cast(selfRef)	
				endif	
				selfRef.SetSubGraphFloatVariable("fToggleBlend", 0)
				CurrentStage.SetValue(0)
				TimesHit.SetValue(0)
				;debug.Notification("Shield at LEVEL 0")
			endif
		endif
			
	EndEvent
	

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	
	Event OnEndState()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(selfRef, BashRelease)
		UnregisterForAnimationEvent(selfRef, BashExit)
		UnregisterForAnimationEvent(selfRef, BashStop)
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
		GoToState("Equipped")
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
	UnregisterForAnimationEvent(selfRef, BashRelease)
	UnregisterForAnimationEvent(selfRef, BashExit)
	UnregisterForAnimationEvent(selfRef, BashStop)
EndEvent