Scriptname INEQ_EventListenerBase extends ActiveMagicEffect Hidden
{}

;===========================================  Properties  ===========================================================================>

;ReferenceAlias	Property	SharedChargesAlias		Auto
ReferenceAlias	Property	DistanceTravelledAlias	Auto
ReferenceAlias	Property	MagickaSiphonAlias		Auto

bool	Property	bRegisteredDT	=	False	Auto	Hidden
bool	Property	bRegisteredMS	=	False	Auto	Hidden

int		Property	LocalCharge		=	0		Auto	Hidden
int		Property	MaxLocalCharge	=	1		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>

String	Property	ModName		=	"InfusedEquipment.esp"	Autoreadonly
int		Property	QuestID		=	0x001305b7	Autoreadonly

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
	self.Maintenance()
EndFunction

Function EffectFinish(Actor akTarget, Actor akCaster)
EndFunction

Function PlayerLoadGame()
EndFunction

Function Maintenance()
	if !DistanceTravelledAlias
		DistanceTravelledAlias = (Game.GetFormFromFile(QuestID, ModName) as Quest).GetAlias(0) as ReferenceAlias
	endif
	
	if !MagickaSiphonAlias
		MagickaSiphonAlias = (Game.GetFormFromFile(QuestID, ModName) as Quest).GetAlias(2) as ReferenceAlias
	endif
		
;	if DistanceTravelled
;		RegisterForDistanceTravelledEvent(ChargeDistance)
;	else
;		DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
;		if DistanceTravelled
;			RegisterForDistanceTravelledEvent(ChargeDistance)
;		endif
;	endif
;	
;	if MagickaSiphon
;		RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
;	else
;		MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
;		if MagickaSiphon
;			RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
;		endif
;	endif
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

Function RestoreDefaultFields()
EndFunction
