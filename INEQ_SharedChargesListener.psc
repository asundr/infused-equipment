Scriptname INEQ_SharedChargesListener extends INEQ_EventListenerBase
{Links to the SharedCharge class and gives it access to EventListener behavior}

;===========================================  Properties  ===========================================================================>
ReferenceAlias	Property	SharedChargesAlias		Auto
ReferenceAlias	Property	DistanceTravelledAlias	Auto
ReferenceAlias	Property	MagickaSiphonAlias		Auto

Bool	Property	bRegisteredDT	=	False	Auto	Hidden
Bool	Property	bRegisteredMS	=	False	Auto	Hidden

;===========================================  Variables  ============================================================================>
INEQ_SharedCharges 		SharedCharges
INEQ_DistanceTravelled	DistanceTravelled
INEQ_MagickaSiphon		MagickaSiphon

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
	MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
	SharedCharges.registerListener(self)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	DistanceTravelled.UnregisterForEvent(self)
	MagickaSiphon.UnregisterForEvent(self)
EndEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; When called by SharedCharges, attempts to register a DistanceTravelled Event
Function RegisterForDistanceTravelledEvent(float akDistance)
	if !bRegisteredDT
		bRegisteredDT = DistanceTravelled.RegisterForEvent(self, akDistance)
	endif
EndFunction

; When called by SharedCharges, unregisters for DistanceTravelled Event
Function UnregisterForDistanceTravelledEvent()
	if bRegisteredDT
		bRegisteredDT = False
		DistanceTravelled.UnregisterForEvent(self)
	endif
EndFunction

; Forwards the DistanceTravelled Event to SharedCharges
Function OnDistanceTravelledEvent()
	bRegisteredDT = False
	SharedCharges.OnDistanceTravelledEvent()
EndFunction

; Returns whether the 
bool Function isRegisteredDistanceTravelled()
	return bRegisteredDT
EndFunction

;___________________________________________________________________________________________________________________________

; When called by SharedCharges, attempts to register a MagickaSiphon Event
Function RegisterForMagickaSiphonEvent(float akMagicka, int akPriority)
	if !bRegisteredMS
		bRegisteredMS = MagickaSiphon.RegisterForEvent(self, akMagicka, akPriority)
	endif
EndFunction

; When called by SharedCharges, unregisters for DistanceTravelled Event
Function UnregisterForMagickaSiphonEvent()
	if bRegisteredMS
		bRegisteredMS = False
		MagickaSiphon.UnregisterForEvent(self)
	endif
EndFunction

; Forwards the MagickaSiphon Event to SharedCharges
Function OnMagickaSiphonEvent()
	bRegisteredMS = False
	SharedCharges.OnMagickaSiphonEvent()
EndFunction

bool Function isRegisteredMagickaSiphon()
	return bRegisteredMS
EndFunction
