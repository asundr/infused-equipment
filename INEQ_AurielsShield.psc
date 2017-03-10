Scriptname INEQ_AurielsShield extends INEQ_AbilityBaseShield  
{Script for reflecting shield to appear to reflect certain incoming spells.}

;===========================================  Properties  ===========================================================================>
Spell  Property ChargeSpell1 Auto
Spell  Property ChargeSpell2 Auto
Spell  Property ChargeSpell3 Auto

Sound Property ChargSound Auto

ImagespaceModifier Property ChargeIMod Auto
ImagespaceModifier Property BlastIMod Auto

;GlobalVariable Property TimesHit Auto
;GlobalVariable Property CurrentStage Auto

;Int Property HitsUntilFirstCharge = 5 Auto	Hidden
;{Hit's required until the shiled reaches it's first charge (DEFAULT = 5)}
;Int Property HitsUntilSecondCharge = 10 Auto Hidden
;{Hit's required until the shiled reaches it's first charge (DEFAULT = 10)}
;Int Property HitsUntilThirdCharge = 15 Auto Hidden
;{Hit's required until the shiled reaches it's first charge (DEFAULT = 15)}

ReferenceAlias	Property	SharedChargesAlias	Auto

Int Property TimesHit Auto Hidden
Int Property  LocalCharges Auto	Hidden

Int Property ChargeInterval = 5 Autoreadonly Hidden
Int Property MaxLocalCharge	= 3 Autoreadonly Hidden
Int Property NumStages		= 3 Autoreadonly Hidden

String  Property  BashExit   =  "bashExit"  	Autoreadonly		; exit bashing
String  Property  BashStop   =  "bashStop"  	Autoreadonly		; stop bashing
String  Property  BashRelease =  "bashRelease"	Autoreadonly		; power bashing

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef
bool RefIsPlayer
int chargePriority = 1		;(0==prioritize shared charges, 1=prioritize local, 2= use local only)

INEQ_SharedCharges SharedCharges

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
	TimesHit = 0
	LocalCharges = 0
	SelfRef = akCaster
	RefIsPlayer = SelfRef == Game.GetPlayer()
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForUpdate()
	UnregisterForAnimationEvent(selfRef, BashRelease)
	UnregisterForAnimationEvent(selfRef, BashExit)
	UnregisterForAnimationEvent(selfRef, BashStop)
EndEvent



;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

; Override of base state in order to use busy state for OnWardHit (since States cannot be nested)
Auto State Unequipped
	
	Event OnBeginState()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(selfRef, BashRelease)
		UnregisterForAnimationEvent(selfRef, BashExit)
		UnregisterForAnimationEvent(selfRef, BashStop)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		EquipCheckKW(akReference)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	EndEvent
	
	Event OnWardHit(ObjectReference akCaster, Spell akSpell, int aiStatus)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

; Main state, uses all external events except for OnWardHit when it's delayed
State Equipped
	
	Event OnBeginState()
		if (RefIsPlayer)
			registerForAnimationEvent(selfRef, BashRelease)
		else
			registerForAnimationEvent(selfRef, BashExit)
			registerForAnimationEvent(selfRef, BashStop)
		endif
		UpdateShieldVisuals()
	EndEvent
	
EndState

;===============================================================================================================================
;====================================			Events			================================================
;================================================================================================

; When hit, increments times hit, possibly increasing the charge of the shield. Power attacks provide twice as much charge
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if abHitBlocked
		if abPowerAttack
			TimesHit += 2
		else
			TimesHit += 1
		endif
		if TimesHit >= ChargeInterval
			AddCharge()
			TimesHit %= ChargeInterval
		endif
	else
		;debug.Trace("I've been hit but NOT in the shield while blocking!")
	endif
EndEvent

;___________________________________________________________________________________________________________________________

; Event for spellbreaker ward, increasing TimesHit at specified maximum frequency
Event OnWardHit(ObjectReference akCaster, Spell akSpell, int aiStatus)
	if SelfRef.GetAnimationVariableBool("IsBlocking") && aiStatus == 1
		TimesHit +=1
		if TimesHit >= ChargeInterval
			AddCharge()
			TimesHit %= ChargeInterval
		endif
		GoToState("WardBusy")
		RegisterForSingleUpdate(1.0)
	endif
EndEvent

;Delay to prevent concentration spell from charging the ward too fast
State WardBusy
	
	Event OnWardHit(ObjectReference akCaster, Spell akSpell, int aiStatus)
	EndEvent
	
	Event OnUpdate()
		GoToState("Equipped")
	EndEvent
	
	Event OnEndState()
		UnregisterForUpdate()
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

; Cast the apropriate spell on bash and removes charges. Possibly uses charges from SharedCharges
Event OnAnimationEvent(ObjectReference akSource, string EventName)
	if RefIsPlayer
		if (eventName == BashRelease)
			if chargePriority == 0
				prioritizeShared()
			elseif chargePriority == 1
				prioritizeLocal()
			elseif chargePriority == 2
				localOnly()
			else
				Debug.Trace("INEQ_AurielsShield: Unhandled priority value " + chargePriority)
			endif
		endif
	else
		if (eventName == BashExit) || (eventName == BashStop)
			localOnly()
			UpdateShieldVisuals()
		endif
	endif
EndEvent
	
;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Uses any shared charges and -- if less than  the top spell cost -- any aditional local charges
function prioritizeShared()
	int total = SharedCharges.requestChargeUpTo(NumStages)
	total += removeLocalChargeUpTo(NumStages - total)
	castBashSpell(total)
	UpdateShieldVisuals(localCharges + SharedCharges.getCharge())
Endfunction

; Uses any local charges first. If localCharges = 0,  uses shared charges instead
function prioritizeLocal()
	int total = removeLocalChargeUpTo(NumStages)
	if total == 0
		total = SharedCharges.requestChargeUpTo(NumStages)
	endif
	castBashSpell(total)
	UpdateShieldVisuals()
endFunction

; Only uses the number of local charges when casting bash spell. Allowing player to reliably charge shared charges for other abilities
function localOnly()
	int total = removeLocalChargeUpTo(NumStages)
	castBashSpell(total)
	UpdateShieldVisuals()
endFunction

;___________________________________________________________________________________________________________________________

; Casts the offensive spell depending on the number of charges expended
function castBashSpell(int charges)
	if charges == 3
		BlastIMod.Apply(1.0)
		ChargeSpell3.cast(selfRef)
	elseif charges == 2
		BlastIMod.Apply(0.6)
		ChargeSpell2.cast(selfRef)	
	elseif charges == 1
		BlastIMod.Apply(0.3)
		ChargeSpell1.cast(selfRef)
	endif
endFunction
;___________________________________________________________________________________________________________________________

; Add the given number of charges to the local charge. If too much, transfers the charges to the SharedCharge
function AddCharge(int num = 1)
	LocalCharges += num
	if LocalCharges > MaxLocalCharge
		SharedCharges.AddCharge(LocalCharges - MaxLocalCharge)
		LocalCharges = MaxLocalCharge
	else
		UpdateShieldVisuals()
		if RefIsPlayer
			ChargeIMod.Apply()
		endif
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Removes and returns the number of requested charges from the local charge
int function removeLocalChargeUpTo(int iRequest, bool bExact = False)
	if iRequest > 0
		if LocalCharges >= iRequest
			LocalCharges -= iRequest
			return iRequest
		elseif !bExact
			iRequest = LocalCharges
			LocalCharges = 0
			return iRequest
		else
			return 0
		endif
	else
		return 0
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Updates the visuals on the shield according to the number of local charges
Function UpdateShieldVisuals(int charges = 0)
	if !charges
		charges = LocalCharges
	endif
	if charges == 1
		;debug.Notification("Shield at LEVEL 1")
		selfRef.SetSubGraphFloatVariable("fDampRate", 1)
		selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.75)
	elseif charges == 2
		;debug.Notification("Shield at LEVEL 2")
		selfRef.SetSubGraphFloatVariable("fDampRate", 1)
		selfRef.SetSubGraphFloatVariable("fToggleBlend", 0.85)
	elseif charges >= 3
		;debug.Notification("Shield at LEVEL 3")
		selfRef.SetSubGraphFloatVariable("fDampRate", 1)
		selfRef.SetSubGraphFloatVariable("fToggleBlend", 1)
	else
		selfRef.SetSubGraphFloatVariable("fToggleBlend", 0)
	endif
EndFunction
