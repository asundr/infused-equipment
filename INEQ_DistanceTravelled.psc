Scriptname INEQ_DistanceTravelled extends ReferenceAlias 

;===========================================  Properties  ===========================================================================>
GlobalVariable Property TotalDistance auto
; reset numberGV for when totaldistance gets too large/impresise

Static Property XMarker	Auto

String  Property  Step		=  "FootRight"  Autoreadonly		; any movement with right foot
String  Property  JumpEnd	=  "JumpDown"  	Autoreadonly		; jumping landing animation
String  Property  GetUp		=  "GetUpEnd"	Autoreadonly		; getting up after ragdoll

int	Property	MaxDistanceStep	=	1000	Autoreadonly		; acnumRequestss for teleporting doors. Could probably be lower, but players might want to increase speedmult

;===========================================  Variables  ============================================================================>
Actor 	SelfRef
ObjectReference LastPosition
float milestone = 0.0
float interval = 100.0

; array of objects to send events to like Forceful draw script... maybe formlist better since each script would be a different type... probably can't store scripts in a FL though
INEQ_AbilityBase[] registeredAb
float[] registeredDist

int numRequests = 0


;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnInit()
	registeredAb = new INEQ_AbilityBase[8]
	registeredDist = new float[8]
	selfRef = GetReference() as Actor
	TotalDistance.SetValue(0)
	GoToState("Active")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Active

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, Step)			; on step event, eupdate distance
		RegisterForAnimationEvent(SelfRef, JumpEnd)			; ignore fall distance
		RegisterForAnimationEvent(SelfRef, GetUp)			; ignore ragdoll distance	(might be worth removing these since the door check could cover all but minimal instances of these)
		LastPosition = SelfRef.Placeatme(XMarker, abForcePersist = True)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, String asEventName)
		if asEventName == Step
			float displacement = LastPosition.getDistance(SelfRef)
			if displacement < MaxDistanceStep
				TotalDistance.setValue(TotalDistance.getValue() + displacement * 3 / 64)
				;Debug.Notification("+" +displacement+ "-->" +TotalDistance.getValue()+ " travelled")
				if TotalDistance.getValue() > milestone	
					;Debug.Notification("Passed milestone: " +(milestone as int) + " feet")
					milestone += interval
					sendEvent()
				endif
			endif
		endif
		LastPosition.MoveTo(SelfRef)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, Step)
		UnregisterForAnimationEvent(SelfRef, JumpEnd)
		UnregisterForAnimationEvent(SelfRef, GetUp)
		LastPosition.Disable()
		LastPosition.Delete()
	EndEvent
	
	bool Function toggle()
		GoToState("Off")
		return false
	endFunction

EndState
;___________________________________________________________________________________________________________________________

State Off

	bool function toggle()
		GoToState("Active")
		return true
	endFunction
	
EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

bool Function toggle()
EndFunction
;___________________________________________________________________________________________________________________________

function sendEvent()
	while numRequests && registeredDist[numRequests - 1] && registeredDist[numRequests - 1] < TotalDistance.Value
		registeredAb[numRequests - 1].OnDistanceTravelledEvent()
		registeredAb[numRequests - 1] = none
		registeredDist[0] = 0.0
		numRequests -= 1
	endwhile
	if numRequests==0		; should handle htis in hte on state only
		;toggle()
	endif
endfunction
;___________________________________________________________________________________________________________________________

;on 
bool function RegisterForEvent(INEQ_AbilityBase akAsker, float akDistance)
	int index = registeredAb.find(akAsker)
	if  index < 0
		if numRequests == registeredAb.length
			return false
		else
			registeredAb[numRequests] = akAsker
			registeredDist[numRequests] = TotalDistance.Value + akDistance
			numRequests += 1
			if numRequests == 1
				;toggle()
			endif
		endif
	else
		registeredAb[index] = akAsker
		registeredDist[index] = TotalDistance.Value + akDistance
	endif
	
	printArray()
	sortDescending()	;sort array from farthest to closest so that the send event can poll the minimum number of indicies
	return true
endFunction
;___________________________________________________________________________________________________________________________

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

function swap(int a, int b)
	INEQ_AbilityBase tempAb
	float tempDist
	
	tempAb = registeredAb[a]
	registeredAb[a] = registeredAb[b]
	registeredAb[b] = tempAb
	
	tempDist = registeredDist[a]
	registeredDist[a] = registeredDist[b]
	registeredDist[b] = tempDist
endfunction
	
	
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
	