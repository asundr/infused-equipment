Scriptname INEQ_DistanceTravelled extends INEQ_RechargeBase 
{Registeres distances from objects and notifies the objects when the distance is traversed}

;===========================================  Properties  ===========================================================================>
GlobalVariable Property TotalDistance auto	; reset numberGV for when totaldistance gets too large/impresise

Static Property XMarker	Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	interval 			= 	100.0		Autoreadonly	; distance interval to send events... might not be necessary since send events will usually only check once
float	Property	MaxDistanceStep		=	1000.0		Autoreadonly	; in units. accounts for teleporting doors. Could probably be lower, but players might want to increase speedmult
float	Property	MaxDistanceTravel	=	100000000.0	Autoreadonly	; in units. accounts for teleporting doors if bIncludeFastTravl = true. Skyrim's largest end to end is 62,115 units

bool	Property	bDebugTrace		=	True	Autoreadonly
bool	Property	bDebugMessage	=	False	Autoreadonly

String	Property  Step		=  "FootRight"  Autoreadonly		; any movement with right foot
String	Property  JumpEnd	=  "JumpDown"  	Autoreadonly		; jumping landing animation
String  Property  GetUp		=  "GetUpEnd"	Autoreadonly		; getting up after ragdoll
;===========================================  Variables  ============================================================================>
ObjectReference LastPosition

float milestone = 0.0
bool bEnableOffState		; if enabled, allows the script to stop tracking distance when nothing is registered
bool bIncludeFastTravel		; if enabled, includes fast travel distance

INEQ_EventListenerBase[] RegisteredAB
float[] RegisteredDist

INEQ_EventListenerBase[] BufferAB
float[] BufferDist

INEQ_EventListenerBase[] UnregisterAB

int numRequests
int numBuffered
int numUnregistered
;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	parent.Init()
	TotalDistance.SetValue(0)
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bEnableOffState		= True
	bIncludeFastTravel	= True
EndFunction

Function FullReset()
	parent.FullReset()
	milestone = interval + TotalDistance.Value
	RegisteredAB = new INEQ_EventListenerBase[32]
	RegisteredDist = new float[32]
	BufferAB = new INEQ_EventListenerBase[16]
	BufferDist = new float[16]
	UnregisterAB = new INEQ_EventListenerBase[16]
	numRequests = 0
	numBuffered = 0
	numUnregistered = 0
	GoToState("Off")
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

	Function UpdateState()
		if numRequests > 0 || !bEnableOffState
			GoToState("Active")
		endif
	EndFunction
	
EndState
;___________________________________________________________________________________________________________________________

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
				TotalDistance.Value += displacement * 3.0/64.0	;setValue(TotalDistance.getValue() + displacement * 3.0 / 64.0) ;units to feet conversion
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

	Function UpdateState()
		if numRequests == 0 && bEnableOffState
			GoToState("Off")
		endif
	EndFunction
	
	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, Step)
		UnregisterForAnimationEvent(SelfRef, JumpEnd)
		UnregisterForAnimationEvent(SelfRef, GetUp)
		LastPosition.Disable()
		LastPosition.Delete()
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

; Prevents functions from changing the array while modifying it. Instead, stores (un)registrations 
; in a temporary buffer array then applies them when the main array is no longer busy
State RegisterBusy

	; TESTING
	Event OnUpdate()
		RegisterForSingleUpdate(0.1)
	EndEvent
	
	;Stores requests in a temporary array
	bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akDistance)
	;DEBUGTEXT("{Reg  S}", 0,  false, True)
		if numBuffered == BufferAB.length || numBuffered + numRequests >= RegisteredAB.length
			Debug.Trace(self+ ": Number of requests exceeded buffer or main array on adding " +akAsker)
			return false
		else
			BufferAB[numBuffered] = akAsker
			BufferDist[numBuffered] = TotalDistance.Value + akDistance
			numBuffered += 1
			return true
		endif
	;DEBUGTEXT("{Reg  E}", 0,  false, True)
	endfunction
	
	
	; Stores unregistration requests in an array
	Function UnregisterForEvent(INEQ_EventListenerBase akAsker)
	;DEBUGTEXT("{Unreg S}", 0,  false, True)
		int index = BufferAB.find(akAsker)
		if index != -1
			BufferAB[index] = None
			BufferDist[index] = 0.0
			numUnregistered += 1
		endif
		index = RegisteredAB.find(akAsker)
		if index != -1
			UnregisterAB[numUnregistered] = akAsker
			numUnregistered += 1
		endif
	;DEBUGTEXT("{Unreg E}", 0,  false, True)
	EndFunction
	
	
	; transfers elements from temporary arrays to the main array and then sorts it
	Event OnEndState()
	;DEBUGTEXT("{Busy S}", 0,  false, True)

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
					UnregisterAB[i] = None
				endif
			endwhile	
			ShiftElementsDown(RegisteredAB, RegisteredDist)
		endif
		
		if numbuffered || numUnregistered
			numUnregistered = 0
			numBuffered = 0
			sortDescending()
		endif
	;DEBUGTEXT("{Busy E}", 0,  false, True)
	EndEvent

EndState

;===============================================================================================================================
;====================================		Main Functions			================================================
;================================================================================================

; Assumes array sorted from farthest to closest. Sends an event to the closest index until the next one is too far away
function sendEvent()
	String previous = GetState()
	GoToState("RegisterBusy")
	while numRequests && RegisteredDist[numRequests - 1] && RegisteredDist[numRequests - 1] < TotalDistance.Value
	;DEBUGTEXT("{Send S}", 0,  false, True)
		numRequests -= 1
		RegisteredAB[numRequests].bRegisteredDT = False
		RegisteredAB[numRequests].OnDistanceTravelledEvent()
		RegisteredAB[numRequests] = none
		RegisteredDist[numRequests] = 0.0
	;DEBUGTEXT("{Send S}", 0,  false, True)
	endwhile
	GoToState(previous)
	UpdateState()
endfunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted. If passed reference is registered, shift the elements down and remove the last one [NEEDS TESTING]
function UnregisterForEvent(INEQ_EventListenerBase akAsker)
;DEBUGTEXT("{Unreg S}", 0,  false, True)
	int index = RegisteredAB.find(akAsker)
	if index != -1
		String previous = GetState()
		GoToState("RegisterBusy")
		index += 1
		while index < numRequests
			RegisteredAB[index - 1] = RegisteredAB[index]
			RegisteredDist[index - 1] = RegisteredDist[index]
			index += 1
		endwhile
		RegisteredAB[index - 1] = None
		RegisteredDist[index - 1] = 0.0
		numRequests -= 1
		GoToState(previous)
		UpdateState()
	endif
;DEBUGTEXT("{Unreg E}", 0,  false, True)
EndFunction
;___________________________________________________________________________________________________________________________

; Registers an item and a distance by adding it to an array, then sorts the items by descending distance
bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akDistance)
;DEBUGTEXT("{Reg S}", 0,  false, True)
	String previous = GetState()
	GoToState("RegisterBusy")
	int index = RegisteredAB.find(akAsker)
	if  index < 0
		if numRequests == RegisteredAB.length
			Debug.Trace(self+ ": Number of requests exceeded buffer or main array on adding " +akAsker)
			return false
		else
			RegisteredAB[numRequests] = akAsker
			RegisteredDist[numRequests] = TotalDistance.Value + akDistance
			numRequests += 1
		endif
	else
		RegisteredAB[index] = akAsker
		RegisteredDist[index] = TotalDistance.Value + akDistance
	endif
	sortDescending()	;sort array from farthest to closest so that the send event can poll the minimum number of indicies
	GoToState(previous)
	UpdateState()
;DEBUGTEXT("{Reg E}", 0,  false, True)
	return true
endFunction
;___________________________________________________________________________________________________________________________
;												Placeholder functions
Function UpdateState()
	Debug.Trace(Self+ " UpdateState called in state " +GetState())
EndFunction

;===============================================================================================================================
;====================================		Helper Functions		================================================
;================================================================================================

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
			if RegisteredDist[index1] < RegisteredDist[index2]
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
	
	tempAb = RegisteredAB[a]
	RegisteredAB[a] = RegisteredAB[b]
	RegisteredAB[b] = tempAb
	
	tempDist = RegisteredDist[a]
	RegisteredDist[a] = RegisteredDist[b]
	RegisteredDist[b] = tempDist
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

; Shifts total and registered distances towards zero in order to maintian preceision / prevent overload
function floatPrecisionMaintenance()
	int i = numRequests
	while i > 0
		i -= 1
		RegisteredDist[i] = RegisteredDist[i] - TotalDistance.Value
	endWhile
	resetDistance()
endFunction
;___________________________________________________________________________________________________________________________

; Returns distance and milestone to base value
function resetDistance()
	TotalDistance.Value = 0.0
	milestone = interval
endfunction
;___________________________________________________________________________________________________________________________

; make into full properties?
function setOffState(bool EnableOff)
	bEnableOffState = EnableOff
	if EnableOff
		if !numRequests
			GoToState("Off")
		endif
	elseif GetState() == "Off"
		GoToState("Active")
	endif
endfunction
;___________________________________________________________________________________________________________________________

; Debugging Function for testing using trace and/or messageboxes
function DEBUGTEXT(String text, int type = -1,  bool dist = false, bool listener = false, bool MBox = False)
	if bDebugTrace
		String s = "" + GetState() + ":\t" ;+text
		if GetState() == "off"
			s += "\t\t"
		elseif GetState() == "active"
			s += "\t"
		endif
		s += text
		if type != -1
			if dist || listener
				s += ":\tR:" +numRequests+ "\t"
				if type == 0
					s += "Register"
				elseif type == 1
					s += " Buffer "
				elseif type == 2
					s += "Unregstr"
				endif
			endif
			if dist
				if type == 0
					;s += "[" +RegisteredDist[0]+ ", " +RegisteredDist[1]+ ", " +RegisteredDist[2]+ "]"
					s += RegisteredDist
				elseif type == 1
					;s += "[" +BufferDist[0]+ ", " +BufferDist[1]+ ", " +BufferDist[2]+ "]"
					s += BufferDist
				endif
			endif
			if listener
				if type == 0
					;s += "\t[" +RegisteredAB[0]+ ", " +RegisteredAB[1]+ ", " +RegisteredAB[2]+ "]"
					s += RegisteredAB
				elseif type == 1
					;s += "\t[" +BufferAB[0]+ ", " +BufferAB[1]+ ", " +BufferAB[2]+ "]"
					s += BufferAB
				elseif type == 2
					;s += "[" +UnregisterAB[0]+ ", " +UnregisterAB[1]+ ", " +UnregisterAB[2]+ "]"
					UnregisterAB
				endif
			endif
		endif
		Debug.Trace(s)
	endif
	if bDebugMessage
		if MBox
			Debug.Messagebox(text + "\n0) Dist:" +RegisteredDist[0]+   "\n1) Dist:" +RegisteredDist[1]+"\n2) Dist:" +RegisteredDist[2])
		endif
	endif
endFunction

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function ChargeMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9		; Cancel menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Enable Off State
			setOffState(True)
		elseif aiButton == 2		; Disable Off State
			setOffState(False)
		elseif aiButton == 3		; Turn on IncludeFastTravel
			bIncludeFastTravel = True
		elseif aiButton == 4		; Turn off IncludeFastTravel
			bIncludeFastTravel = False
		endif
	endwhile
EndFunction

Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bEnableOffState
		Button.set(2)
	else
		Button.set(1)
	endif
	if bIncludeFastTravel
		Button.set(4)
	else
		Button.set(3)
	endif
	Button.set(9)
EndFunction
