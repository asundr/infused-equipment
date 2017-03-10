Scriptname INEQ_EventListenerBase extends ActiveMagicEffect Hidden
{Base used for abilities and effects that can register and listen for INEQ updates}

;===========================================  Properties  ===========================================================================>
ReferenceAlias	Property	DistanceTravelledAlias	Auto	Hidden
ReferenceAlias	Property	MagickaSiphonAlias		Auto	Hidden
ReferenceAlias	Property	SharedChargesAlias		Auto	Hidden

bool	Property	bRegisteredDT	=	False	Auto	Hidden
bool	Property	bRegisteredMS	=	False	Auto	Hidden

int		Property	LocalCharge		=	0		Auto	Hidden
int		Property	MaxLocalCharge	=	1		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
String	Property	PluginName		=	"InfusedEquipment.esp"	Autoreadonly
int		Property	RechargeQuestID	=	0x001305b7				Autoreadonly
;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	EffectStart(akTarget, akCaster)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	EffectFinish(akTarget, akCaster)
EndEvent

Event OnPlayerLoadGame()
	PlayerLoadGame()
EndEvent
;___________________________________________________________________________________________________________________________

Function EffectStart(Actor akTarget, Actor akCaster)
	if !DistanceTravelledAlias
		DistanceTravelledAlias = (Game.GetFormFromFile(RechargeQuestID, PluginName) as Quest).GetAlias(0) as ReferenceAlias
	endif
	
	if !SharedChargesAlias
		SharedChargesAlias = (Game.GetFormFromFile(RechargeQuestID, PluginName) as Quest).GetAlias(1) as ReferenceAlias
	endif
	
	if !MagickaSiphonAlias
		MagickaSiphonAlias = (Game.GetFormFromFile(RechargeQuestID, PluginName) as Quest).GetAlias(2) as ReferenceAlias
	endif
	RestoreDefaultFields()
EndFunction

Function EffectFinish(Actor akTarget, Actor akCaster)
	UnregisterForDistanceTravelledEvent()
	UnregisterForMagickaSiphonEvent()
EndFunction

Function PlayerLoadGame()
EndFunction

Function Maintenance()
EndFunction

Function RestoreDefaultFields()
EndFunction

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================
; INEQ_DistanceTravelled
Function OnDistanceTravelledEvent()
	Debug.Trace(self+ ": Could not find DistanceTravelledEvent override on Requester")
EndFunction

function RegisterForDistanceTravelledEvent(float akDistance)
	if !bRegisteredDT && LocalCharge < MaxLocalCharge
		bRegisteredDT = (DistanceTravelledAlias as INEQ_DistanceTravelled).RegisterForEvent(self, akDistance)
	endif
Endfunction

Function UnregisterForDistanceTravelledEvent()
	if bRegisteredDT
		bRegisteredDT = False
		(DistanceTravelledAlias as INEQ_DistanceTravelled).UnregisterForEvent(self)
	endif
EndFunction

bool Function isRegisteredDistanceTravelled()
	return bRegisteredDT
EndFunction
;___________________________________________________________________________________________________________________________

; INEQ_MagickaSiphon
Function OnMagickaSiphonEvent()
	Debug.Trace(self+ ": Could not find OnMagickaSiphonEvent override on Requester")
EndFunction

function RegisterForMagickaSiphonEvent(float akMagicka, int akPriority)
	if !bRegisteredMS && LocalCharge < MaxLocalCharge
		bRegisteredMS = (MagickaSiphonAlias as INEQ_MagickaSiphon).RegisterForEvent(self, akMagicka, akPriority)
	endif
endfunction

Function UnregisterForMagickaSiphonEvent()
	if bRegisteredMS
		bRegisteredMS = False
		(MagickaSiphonAlias as INEQ_MagickaSiphon).UnregisterForEvent(self)
	endif
endfunction

bool Function isRegisteredMagickaSiphon()
	return bRegisteredMS
EndFunction
;___________________________________________________________________________________________________________________________

;INEQ_SharedCharges
int Function GetSharedCharge()
	return (SharedChargesAlias as INEQ_SharedCharges).getCharge()
EndFunction

Function AddSharedCharge(int charge = 1)
	(SharedChargesAlias as INEQ_SharedCharges).addCharge(charge)
EndFunction

bool Function RequestSharedCharge(int charge)
	return (SharedChargesAlias as INEQ_SharedCharges).requestChargeUpTo(charge, True)
EndFunction

int Function RequestSharedChargeUpTo(int charge)
	return (SharedChargesAlias as INEQ_SharedCharges).requestChargeUpTo(charge)
EndFunction
