Scriptname INEQ_SharedChargesListener extends INEQ_EventListenerBase
{Links to the SharedCharge class and gives it access to EventListener behavior}

;===========================================  Properties  ===========================================================================>
ReferenceAlias	Property	SharedChargesAlias		Auto
ReferenceAlias	Property	DistanceTravelledAlias	Auto

Bool Property bDistanceChargingActive Auto Hidden

;===========================================  Variables  ============================================================================>
INEQ_SharedCharges 		SharedCharges
INEQ_DistanceTravelled	DistanceTravelled

;int count

;float distance

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	bDistanceChargingActive = False
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
	SharedCharges.registerListener(self)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	DistanceTravelled.UnregisterForEvent(self)
EndEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; When called by SharedCharges, attempts to register a DistanceTravelledEvent
Function RegisterForDistanceTravelledEvent(float akDistance)
;	distance = akDistance
	DistanceTravelled.RegisterForEvent(self, akDistance)
;	if DistanceTravelled.RegisterForEvent(self, distance)
;		bDistanceChargingActive = True
;	else
;		GoToState("WaitingForDT")
;	endif
EndFunction

; Temporary state to ensure registration if DistanceTravelled is currently busy sending events
;State WaitingForDT
;	
;	Event OnBeginState()
;		count = 0
;		RegisterForSingleUpdate(0.2)
;	EndEvent
;	
;	Event OnUpdate()
;		if 	DistanceTravelled.RegisterForEvent(self, distance)
;			GoToState("")
;		else
;			if count < 10
;				count += 1
;				RegisterForSingleUpdate(0.2)
;			else
;				bDistanceChargingActive = True
;				GoToState("")
;			endif
;		endif
;	EndEvent
;
;EndState
;___________________________________________________________________________________________________________________________

; Forwards the distance travelled event to SharedCharges
Function OnDistanceTravelledEvent()
	bDistanceChargingActive = False
	SharedCharges.OnDistanceTravelledEvent()
EndFunction
