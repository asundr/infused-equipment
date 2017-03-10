Scriptname INEQ_DistanceTravelled extends ReferenceAlias 
{Registeres distances from objects and notifies the objects when the distance is traversed}

;===========================================  Properties  ===========================================================================>
GlobalVariable Property TotalDistance auto
; reset numberGV for when totaldistance gets too large/impresise

Static Property XMarker	Auto

String	Property  Step		=  "FootRight"  Autoreadonly		; any movement with right foot
String	Property  JumpEnd	=  "JumpDown"  	Autoreadonly		; jumping landing animation
String  Property  GetUp		=  "GetUpEnd"	Autoreadonly		; getting up after ragdoll

float	Property	interval 	= 	100.0	Autoreadonly		; distance interval to send events... might not be necessary since send events will usually only check once

float	Property	MaxDistanceStep		=	1000.0		Autoreadonly	; in units. accounts for teleporting doors. Could probably be lower, but players might want to increase speedmult
float	Property	MaxDistanceTravel	=	100000000.0	Autoreadonly	; in units. accounts for teleporting doors if bIncludeFastTravl = true. Skyrim's largest end to end is 62,115 units


;===========================================  Variables  ============================================================================>
Actor 	SelfRef
ObjectReference LastPosition

float milestone = 0.0
bool bEnableOffState 	= True		; if enabled, allows the script to stop tracking distance when nothing is registered
bool bIncludeFastTravel	= True		; if enabled, includes fast travel distance

INEQ_EventListenerBase[] registeredAb
float[] registeredDist

INEQ_EventListenerBase[] bufferAb
float[] bufferDist

INEQ_EventListenerBase[] UnregisterAB

int numRequests = 0
int numBuffered = 0
int numUnregistered = 0

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnInit()
	selfRef = GetReference() as Actor
	TotalDistance.SetValue(0)
	
	registeredAb = new INEQ_EventListenerBase[16]		; NOTE: should probably increase or provide a function to incrase array size if necesary
	registeredDist = new float[16]
	
	bufferAb = new INEQ_EventListenerBase[16]
	bufferDist = new float[16]
	
	UnregisterAB = new INEQ_EventListenerBase[16]
		
	GoToState("Off")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Active

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, Step)			; on step event, eupdate distance
		RegisterForAnimationEvent(SelfRef, JumpEnd)			; ignore fall distance
		RegisterForAnimationEvent(SelfRef, GetUp)			; ignore ragdoll distance
		LastPosition = SelfRef.Placeatme(XMarker, abForcePersist = True)
	EndEvent
	
	; On step event, calculates displacement and adds it to the total if it's valid. Upon reachinga milestone, attempts to sends events to registered objects
	Event OnAnimationEvent(ObjectReference akSource, String asEventName)
		if asEventName == Step
			float displacement = LastPosition.getDistance(SelfRef)
			if (displacement < MaxDistanceStep) || (bIncludeFastTravel && displacement < MaxDistanceTravel)
				TotalDistance.setValue(TotalDistance.getValue() + displacement * 3.0 / 64.0) ;units to feet conversion
				if TotalDistance.getValue() > milestone	;NOTE: Using this method can lead to issues if player manually edits the GV since the milestone will be updated. This means events will be delayed if GV reduced
					milestone = TotalDistance.getValue() + interval
					sendEvent()
					if TotalDistance.getValue() > MaxDistanceTravel
						floatPrecisionMaintenance()
					endif
				endif
			endif
		endif
		LastPosition.MoveTo(SelfRef)		;jump/getup events will trigger this and ignore the displacement
	EndEvent
	
	; To prevent teleports from couting towards distance travelled
	Event OnTranslationComplete()
		LastPosition.MoveTo(SelfRef)
	EndEvent
	
	bool Function toggle()
		;Debug.Notification("Entering Off")
		GoToState("Off")
		return false
	endFunction
	
	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, Step)
		UnregisterForAnimationEvent(SelfRef, JumpEnd)
		UnregisterForAnimationEvent(SelfRef, GetUp)
		LastPosition.Disable()
		LastPosition.Delete()
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

; Prevents registrations from changing the array while sending events. Instead, stores registrations 
; in a temporary buffer array then transfers them when the main array is no longer sending events
State RegisterBusy

	; TESTING
	Event OnUpdate()
		RegisterForSingleUpdate(0.1)
	EndEvent
	
	;Stores requests in a temporary array
	bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akDistance)
		if numBuffered == bufferAb.length || numBuffered + numRequests >= registeredAb.length
			Debug.Trace(self+ ": Number of requests exceeded buffer or main array on adding " +akAsker)
			return false
		else
			bufferAb[numBuffered] = akAsker
			bufferDist[numBuffered] = TotalDistance.Value + akDistance
			numBuffered += 1
			return true
		endif
	endfunction
	
	
	; Stores unregistration requests in an array
	Function UnregisterForEvent(INEQ_EventListenerBase akAsker)
		int index = BufferAB.find(akAsker)
		if index != -1
			BufferAB[index] = None
			BufferDist[index] = 0.0
			numUnregistered += 1
		endif
		index = registeredAB.find(akAsker)
		if index != -1
			UnregisterAB[numUnregistered] = akAsker
			numUnregistered += 1
		endif
	EndFunction
	
	
	; transfers elements from temporary arrays to the main array and then sorts it
	Event OnEndState()
	
;		ShiftElementsDown(BufferAB, BufferDist)
;		int i = 0
;		while i < numBuffered ;&& numRequests < registeredAb.length
;			registeredAb[numRequests] = bufferAb[i]
;			registeredDist[numRequests] = bufferDist[i]
;			bufferAb[i] = none
;			bufferDist[i] = 0.0
;			numRequests += 1
;			i += 1
;		endWhile
;		numbuffered = 0
;		sortDescending()

		; Adds all elements registered while sending events (see INEQ_MagickaSiphon for detials)
		if numBuffered
			int i = 0
			int max = iMin(numBuffered + numUnregistered, RegisteredAB.length)
			while i < max
				if BufferAB[i] != None
					int index = RegisteredAB.find(BufferAB[i])
					if index == -1
						index = numRequests
						numRequests += 1
					endif
					RegisteredAB[index] = BufferAB[i]
					RegisteredDist[index] = BufferDist[i]
					BufferAB[i] = None
					BufferDist[i] = 0.0
				endif
				i += 1
			endwhile
		endif
		
		; Removes all unregistered after the register array is no longer busy
		if numUnregistered
			int i = UnregisterAB.length
			while i > 0
				i -= 1
				if UnregisterAB[i] != None
					int index = RegisteredAB.find(UnregisterAB[i])
					if index != -1
						RegisteredAB[index] = None
						RegisteredDist[index] = 0.0
					endif
					unregisterAB[i] = None
				endif
			endwhile	
			ShiftElementsDown(RegisteredAB, RegisteredDist)
		endif
		
		if numbuffered || numUnregistered
			numUnregistered = 0
			numBuffered = 0
			sortDescending()
		endif
	
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Off

	bool function toggle()
		;Debug.Notification("Entering On")
		GoToState("Active")
		return true
	endFunction
	
EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

;placeholder for overrides in Active/Off states
bool Function toggle()
EndFunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted from farthest to closest. Sends an event to the closest index until the next one is too far away
function sendEvent()
	String previous = GetState()
	GoToState("RegisterBusy")
	while numRequests && registeredDist[numRequests - 1] && registeredDist[numRequests - 1] < TotalDistance.Value
		numRequests -= 1
		RegisteredAB[numRequests].bRegisteredDT = False
		registeredAb[numRequests].OnDistanceTravelledEvent()
		registeredAb[numRequests] = none
		registeredDist[numRequests] = 0.0
	endwhile
	GoToState(previous)
	if bEnableOffState && numRequests == 0		; should handle this in the on state only
		toggle()
	endif
endfunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted. If passed reference is registered, shift the elements down and remove the last one [NEEDS TESTING]
function UnregisterForEvent(INEQ_EventListenerBase akAsker)
	int index = registeredAb.find(akAsker)
	if index != -1
		String previous = GetState()
		GoToState("RegisterBusy")
		index += 1
		while index < numRequests
			registeredAb[index - 1] = registeredAb[index]
			registeredDist[index - 1] = registeredDist[index]
			index += 1
		endwhile
		registeredAb[index - 1] = None
		registeredDist[index - 1] = 0.0
		numRequests -= 1
		GoToState(previous)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Registers an item and a distance by adding it to an array, then sorts the items by descending distance
bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akDistance)
	int index = registeredAb.find(akAsker)
	if  index < 0
		if numRequests == registeredAb.length
			Debug.Trace(self+ ": Number of requests exceeded buffer or main array on adding " +akAsker)
			return false
		else
			registeredAb[numRequests] = akAsker
			registeredDist[numRequests] = TotalDistance.Value + akDistance
			numRequests += 1
			if bEnableOffState && numRequests == 1
				toggle()
			endif
		endif
	else
		registeredAb[index] = akAsker
		registeredDist[index] = TotalDistance.Value + akDistance
	endif
	sortDescending()	;sort array from farthest to closest so that the send event can poll the minimum number of indicies
	return true
endFunction
;___________________________________________________________________________________________________________________________

; Takes an array of INEQ_EvntListenerBase and shifts all elements towards 0
function ShiftElementsDown(INEQ_EventListenerBase[] akListener, float[] akDistance = None)
	int firstNone = getFirstNone(akListener)
	int lastElement = getLastElement(akListener)
	while firstNone != -1 && lastElement != -1 && firstNone < lastElement
		akListener[firstNone] = akListener[lastElement]
		akListener[lastElement] = None
		if akDistance
			akDistance[firstNone] = akDistance[lastElement]
			akDistance[lastElement] = 0.0
		endif
		firstNone = getFirstNone(akListener, firstNone)
		lastElement = getLastElement(akListener, lastElement)
	endwhile
endfunction
;___________________________________________________________________________________________________________________________

; Returns the last None element of the array from "ending" or -1 if not found
int function getLastElement(INEQ_EventListenerBase[] arr, int ending = -1)
	if ending == -1
		ending = arr.length
	endif
	while ending > 0
		ending -= 1
		if arr[ending] != none
			return ending
		endif
	endwhile
	return -1
endfunction
;___________________________________________________________________________________________________________________________

; Returns the last non-None element of the array from "starting" or -1 if not found
int function getFirstNone(INEQ_EventListenerBase[] arr, int starting = 0)
	while starting < arr.length
		if arr[starting] == none
			return starting
		endif
		starting += 1
	endwhile
	return -1
endfunction
;___________________________________________________________________________________________________________________________

; replace with better sorting algorithm later if many items are registered at any one time
function sortDescending()
	int index1 = 0
	while index1 < numRequests - 1
		int index2 = index1 + 1
		while index2 < numRequests
			if registeredDist[index1] < registeredDist[index2]
				swap(index1, index2)
			endif
			index2 += 1
		endwhile
		index1 +=1
	endwhile		
endfunction
;___________________________________________________________________________________________________________________________

; takes 2 indexes and swaps their contents in the ability and distance arrays
function swap(int a, int b)
	INEQ_EventListenerBase tempAb
	float tempDist
	
	tempAb = registeredAb[a]
	registeredAb[a] = registeredAb[b]
	registeredAb[b] = tempAb
	
	tempDist = registeredDist[a]
	registeredDist[a] = registeredDist[b]
	registeredDist[b] = tempDist
endfunction
;___________________________________________________________________________________________________________________________

; Returns the smaller of two integers
int function iMin(int a, int b)
	if a < b
		return a
	else
		return b
	endif
endFunction
;___________________________________________________________________________________________________________________________

;for testing
function printarray()
	String s = "" +numRequests+ " [" +registeredDist[0]
	int i = 1
	while (i < numRequests)
		s += ", " + registeredDist[i]
		i += 1
	endwhile
	s += "]"
	Debug.MessageBox(s)
endfunction
;___________________________________________________________________________________________________________________________

; Shifts total and registered distances towards zero in order to maintian preceision / prevent overload
function floatPrecisionMaintenance()
	int i = numRequests
	while i > 0
		i -= 1
		registeredDist[i] = registeredDist[i] - TotalDistance.Value
	endWhile
	resetDistance()
endFunction
;___________________________________________________________________________________________________________________________

function resetDistance()
	TotalDistance.Value = 0.0
	milestone = interval
endfunction

function fullReset()
	resetDistance()
	int i = registeredDist.length
	while i > 0
		i -= 1
		registeredDist[i] = 0.0
		registeredAb[i] = none
	endwhile
	numRequests = 0
	bEnableOffState 	= True
	bIncludeFastTravel	= True	
endfunction
;___________________________________________________________________________________________________________________________

; make into full properties?
function setOffState(bool bOff = true)
	bEnableOffState = bOff
	if bOff
		if !numRequests
			GoToState("Off")
		endif
	else
		GoToState("Active")
	endif
endfunction

function setIncludeFastTravel(bool bEnable = true)
	bIncludeFastTravel = bEnable
endfunction
