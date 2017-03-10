Scriptname INEQ_MagickaSiphon extends ReferenceAlias 
{Tracks MP regen and divert a portion to registered abilities}

;===========================================  Properties  ===========================================================================>

String	Property	CastStop	=	"CastStop"	Autoreadonly	Hidden

;===========================================  Variables  ============================================================================>
Actor SelfRef

float MagickaRateMult
float MagickaRateMag
int magickaRateDrain

bool bEnableOffState = False

INEQ_AbilityBase[] registeredAb
float[] registeredMP
int [] registeredPriorty

INEQ_AbilityBase[] bufferAb
float[]	bufferMP
int [] bufferPriorty

int numRequests = 0
int numBuffered = 0
float previousTime

; Abilities should have a MP requirement and a priority. Abiliteis with the same priority are charged simultaneously.
; This means that passive wards with high priority will be charged first, ignoring all else while other abilities that may have other charging
; mechanics like the auriel's shield or the bloodskal blade can use it when somehting like the ward isn't depending on it.

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnInit()
	selfRef = GetReference() as Actor
	RegisterForAnimationEvent(SelfRef, CastStop)
	
	;previousTime = Game.GetTimeElapsed
	
	registeredPriorty = new int[8]
	registeredAb = new INEQ_AbilityBase[8]
	registeredMP = new float[8]
	
	bufferAb = new INEQ_AbilityBase[8]
	bufferMP = new float[8]
	bufferPriorty = new int[8]
	
	GoToState("Off")
EndEvent


;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

	Event OnBeginState()
		UnregisterForAnimationEvent(SelfRef, CastStop)
	EndEvent 
	
	;Empty events to override listening events
	
	Event OnSpellCast(Form akSpell)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
	EndEvent
	

	
	Event OnEndState()
		RegisterForAnimationEvent(SelfRef, CastStop)
	EndEvent
	
EndState
;___________________________________________________________________________________________________________________________

; Player is below maximum MP, 
State Active

	Event OnBeginState()
		MagickaRateMult =	SelfRef.GetActorValue("MagickaRateMult")
		MagickaRateMag	=	SelfRef.GetActorVaclue("MagickaRate") * SelfRef.getActorValue("Magicka") / SelfRef.getActorValuePercentage("Magicka")
		;add drain magicka spells if necessary
		;based on the the current magickaRateDrain, mp and soonest ability to recharge, RegisterForSingleUpdate()
	EndEvent
	
	Event OnUpdate()
		processUpdate()
	EndEvent
	
	
	Event OnEndState()
		;remove drain magicka spells if neessary
		UnregisterForUpdate()
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

; Player is at maximum MP, 
State ActiveMAX
	
	Event OnBeginState()
		magickaRateMult = SelfRef.GetActorValue("MagickaRateMult")
		MagickaRateMag	=	SelfRef.GetActorVaclue("MagickaRate") * SelfRef.getActorValue("Magicka") / SelfRef.getActorValuePercentage("Magicka")
		;based on the the current magickaRateMult, mp and soonest ability to recharge, RegisterForSingleUpdate()
	EndEvent
	
	Event OnUpdate()
		; decrease current phase mp's
		; send recharge if mp < 0
		; set current priorty
		; set current mp
		; Register for update on next item
	EndEvent

	Event OnEndState()
		UnregisterForUpdate()
	EndEvent
	
EndState

Function processUpdate()
		; decrease current phase mp's
		sendEvent()	; decrease current phase mp's and send recharge if mp < 0
		
		magickaRateMult = SelfRef.GetActorValue("MagickaRateMult")
		MagickaRateMag	=	SelfRef.GetActorVaclue("MagickaRate") * SelfRef.getActorValue("Magicka") / SelfRef.getActorValuePercentage("Magicka")
		
		if bEnableOffState 		; should handle this in the on state only
			toggle()
		endif
		; Register for update on min(next item, MaxMp - player's mp)
Endfunction


;___________________________________________________________________________________________________________________________

State SendingEvents

	;Stores requests in a temporary array
	bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akMagicka, int akPriority)
		if numBuffered == bufferAb.length || numBuffered + numRequests >= registeredAb.length
			return false
		else
			bufferAb[numBuffered] = akAsker
			bufferDist[numBuffered] = akMagicka
			bufferPriority[numBuffered] = akPriority
			numBuffered += 1
			return true
		endif
	endfunction
	
	; transfers elements from temporary arrays to the main array and then sorts it
	Event OnEndState()
		int i = 0
		while i < numBuffered && numRequests < registeredAb.length
			registeredAb[numRequests] = bufferAb[i]
			bufferAb[i] = none
			registeredDist[numRequests] = bufferDist[i]
			bufferDist[i] = 0.0
			registeredPriority[numRequests] = bufferPriority[i]
			bufferPriority[i] = 0
			numRequests += 1
			i += 1
		endWhile
		numbuffered = 0
		sortAscending()
	EndEvent

EndState

;===============================================================================================================================
;====================================		Listening envents		================================================
;================================================================================================

; listen for events that might change regen rate like spells / equipment etc then update the totalMP and the magickaRateMult

Event OnSpellCast(Form akSpell)
	
EndEvent

Event OnAnimationEvent(ObjectReference akSource, string EventName)

EndEvent

;Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
;
;EndEvent

;Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)

;EndEvent

;Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	
;EndEvent



;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

function UpdateState
EndFunction

;placeholder for overrides in Active/Off states
bool Function toggle()
EndFunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted from farthest to closest. Sends an event to the closest index until the next one is too far away
function sendEvent()
	String previous = GetState()
	GoToState("SendingEvents")
	
	int currentPriority = registeredPriority[numRequests - 1]
	int count = 0
	while  (numRequests - count) && registeredMP[numRequests - count - 1]	;count current number at highest priority
		count += 1
	endwhile
	
	if SelfRef.IsInCombat()
		float modifier = MagickaRateMag * MagickaRateMult * timePassed / count / 3.0
	else
		float modifier = MagickaRateMag * MagickaRateMult * timePassed / count
	endif
	
	while count > 0
		registeredMP[numRequests - 1] -=  modifier
		if registeredMP[numRequests - 1] < 0.0
			registeredAb[numRequests - 1].OnMagickaSiphonEvent()
			registeredAb[numRequests - 1] = none
			registeredMP[numRequests - 1] = 0.0
			count -= 1
			numRequests -= 1
		endif
	endwhile
	
	GoToState(previous)
endfunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted. If passed reference is registered, shift the elements down and remove the last one [NEEDS TESTING]
function UnregisterForEvent(INEQ_EventListenerBase akAsker)
	int index = registeredAb.find(akAsker)
	if index != -1
		index += 1
		while index < numRequests
			registeredAb[index - 1] = registeredAb[index]
			registeredMP[index - 1] = registeredMP[index]
			registeredPriority[index - 1] = registeredPriority[index]
		endwhile
		if index < registeredAb.length
			registeredAb[index] = None
			registeredMP[index] = 0.0
			registeredPriority = 0
		endif
		numRequests -= 1
	endif
	;reset registerforupdate
EndFunction
;___________________________________________________________________________________________________________________________

; Registers an item and a distance by adding it to an array, then sorts the items by descending distance
bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akMagicka, int akPriority)
	int index = registeredAb.find(akAsker)
	if  index < 0
		if numRequests == registeredAb.length
			return false
		else
			registeredAb[numRequests] = akAsker
			registeredMP[numRequests] = akMagicka
			registeredPriorty[numRequests] = akPriority
			numRequests += 1
			if bEnableOffState && numRequests == 1
				toggle()
			endif
		endif
	else
		registeredAb[index] = akAsker
		registeredMP[index] = akMagicka
		registeredPriorty[index] = akPriority
	endif
	sortAscending()	;sort array from farthest to closest so that the send event can poll the minimum number of indicies
	return true
	;update registerforupdate
endFunction
;___________________________________________________________________________________________________________________________

; replace with better sorting algorithm later if many items are registered at any one time
function sortAscending()
	int index1 = 0
	while index1 < numRequests - 1
		int index2 = index1 + 1
		while index2 < numRequests
			if registeredPriorty[index1] == registeredPriority[index2] && registeredMP[index1] < registeredMP[index2]
				swap(index1, index2)
			elseif registeredPriorty[index1] > registeredPriority[index2]
				swap(index1, index2)
			endif
			index2 += 1
		endwhile
		index1 +=1
	endwhile		
endfunction
;___________________________________________________________________________________________________________________________

; takes 2 indexes and swaps their contents in the ability and distance arrays (Update if i find a way to make stucts)
function swap(int a, int b)
	INEQ_EventListenerBase tempAb = registeredAb[a]
	registeredAb[a] = registeredAb[b]
	registeredAb[b] = tempAb
	
	float tempMP = registeredMP[a]
	registeredMP[a] = registeredMP[b]
	registeredMP[b] = tempMP
	
	int tempPriority = registeredPriorty[a]
	registeredPriorty[a] = registeredPriorty[b]
	registeredPriorty[b] = tempPriority
endfunction
;___________________________________________________________________________________________________________________________
