Scriptname INEQ_MagickaSiphon extends INEQ_RechargeBase 
{Diverts a portion of MP regen to registered abilities through events}

; Abilities should have a MP requirement and a priority. Abiliteis with the same priority are charged simultaneously.
; This means that passive wards with high priority will be charged first, ignoring all else while other abilities that may have other charging
; mechanics like the auriel's shield or the bloodskal blade can use it when somehting like the ward isn't depending on it.

;===========================================  Properties  ===========================================================================>
GlobalVariable	Property	TimeScale	Auto

float Property	DrainPercentage	=	1.0	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	SecondsInDay	=	86400.0	Autoreadonly

float	Property	CombatCheck		=	10.0	Autoreadonly		; checks at most CombatCheck seconds after last update
float	Property	MPResetDelay	=	1.0		Autoreadonly		; Limits rapid checking when mp is close to full

bool	Property	bDebugTrace		=	False	Autoreadonly
bool	Property	bDebugMessage	=	False	Autoreadonly

float	Property	DEFDrainPercentage	=	1.0	Autoreadonly

String	Property	CastStop	=	"CastStop"	Autoreadonly

;===========================================  Variables  ============================================================================>
float previousTime
float TotalMagicka

float MagickaRateMult
float MagickaRateMag

float DrainMult
float DrainMag

bool bEnableOffState = True
bool bSiphonBelowMax = False

INEQ_EventListenerBase[] registeredAb
float[] registeredMP
int [] registeredPR

INEQ_EventListenerBase[] bufferAb
float[]	bufferMP
int [] bufferPR

INEQ_EventListenerBase[] UnregisterAB

int numRegistered = 0
int numBuffered = 0
int numPriority = 0
int numUnregistered = 0

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	parent.Init()
	registeredAb = new INEQ_EventListenerBase[16]
	registeredMP = new float[16]
	registeredPR = new int[16]
	bufferAb = new INEQ_EventListenerBase[16]
	bufferMP = new float[16]
	bufferPR = new int[16]
	UnregisterAB = new INEQ_EventListenerBase[16]
EndEvent

Event OnPlayerLoadGame()
	parent.PlayerLoadGame()
	; Restores player's MagickaRateMult if the Active state was left in an unexpected way
	if DrainMult
		String currentState = GetState()
		if currentState == "ActiveFull" || currentState == "Off"
			RestoreMagickaDrain()
		endif
	endif
EndEvent

Function RestoreDefaultFields()
	DrainPercentage = DEFDrainPercentage
	bSiphonBelowMax = False
	RestoreMagickaDrain()
EndFunction

;===============================================================================================================================
;====================================		Listening Events		================================================
;================================================================================================

Event OnAnimationEvent(ObjectReference akSource, string EventName)
	ListenerCheckForUpdate()
EndEvent

Event OnSpellCast(Form akSpell)
	ListenerCheckForUpdate()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	ListenerCheckForUpdate()
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	ListenerCheckForUpdate()
EndEvent

; Reigster for immediate update if MagickaRateMult or TotalMagicka has changed (If TotalMagicka is at 0, check anyway)
Function ListenerCheckForUpdate()
	if MagickaRateMult != SelfRef.GetAV("MagickaRateMult") || ! ( SelfRef.getAVPercentage("Magicka") && ( TotalMagicka == SelfRef.getAV("Magicka") / SelfRef.getAVPercentage("Magicka") ) )
		RegisterForSingleUpdate(0)
	endif
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

; Waits for a new register
Auto State Off

	Event OnBeginState()
		UnregisterForUpdate()
		UnregisterForAnimationEvent(SelfRef, CastStop)
		DEBUGTEXT("\t\t{{{Entering Off}}}")
	EndEvent 
	
	; Empty overrides for listeners
	Event OnSpellCast(Form akSpell)
	EndEvent
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	; Override to initialize Register
	bool function RegisterForEvent(INEQ_EventListenerBase akAsker, float akMagicka, int akPriority)
		SetRegisterElement(0, akAsker, akMagicka, akPriority)
		numRegistered = 1
		numPriority = 1
		RegisterForMPUpdate()
		return true
	endfunction
	
	; Attempts to change state
	Function UpdateState()
		if numRegistered > 0 || !bEnableOffState
			if SelfRef.GetActorValuePercentage("Magicka") == 1.0
				GoToState("ActiveFull")
			else
				GoToState("Active")
			endif
		endif
	EndFunction
	
	Event OnEndState()
		RegisterForAnimationEvent(SelfRef, CastStop)
		DEBUGTEXT("\t\t{{{Leaving Off}}}")
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State Active
	
	; Override accounting for concentration spells to recalculate time until MP is full
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		RegisterForSingleUpdate(0)
	EndEvent

	Event OnUpdate()
	DEBUGTEXT("OnUpdate Start")
		if bSiphonBelowMax
			sendEvent(calculateModifier())
		endif
		RegisterForMPUpdate()
	DEBUGTEXT("OnUpdate End")
	EndEvent

	; Calculates what the drian should be and and modifies the Actor's magickaratemult to that value
	function UpdateMagickaDrain()
		float preDrainMult = DrainMult
		DrainMult = (MagickaRateMult + DrainMult) * DrainPercentage
		SelfRef.ModActorValue("MagickaRateMult", preDrainMult - DrainMult)
		MagickaRateMult = SelfRef.GetActorValue("MagickaRateMult")
	endFunction

	
	; Returns the time in seconds until the soonest event or MP restored to full depending on which is most imminent
	float function GetUpdateTime()
		float MPResetTime = 0.0
		if MagickaRateMag
			MPResetTime = fMax((TotalMagicka - SelfRef.GetActorValue("Magicka")) / MagickaRateMag, MPResetDelay)
			if DrainMag
				MPResetTime = fMin(fMax(registeredMP[numRegistered - 1] * numPriority / DrainMag, 0.0), MPResetTime)
			else
				;return MPResetTime
			endif
		elseif DrainMag
			MPResetTime = fMax(registeredMP[numRegistered - 1] * numPriority / DrainMag, 0.0)
		endif
		
		if SelfRef.isInCombat()
			return fMin(MPResetTime, CombatCheck)
		else
			return MPResetTime
		endif
	EndFunction
	
	
	; Calculates the MP siphoned since last update using amount drained (convert to use parameter)
	float function calculateModifier()
	DEBUGTEXT("calculateModifier start", 0, False, False)
		float timedif = ((Utility.GetCurrentGameTime() - previousTime) / TimeScale.Value) * SecondsInDay
		return fMax(DrainMag * timedif / numPriority, 0.0)
	endFunction
	
	; Attempts to change state, returns False if send to Off State
	Function UpdateState()
		if numRegistered == 0 && bEnableOffState
			RestoreMagickaDrain()
			GoToState("Off")
		elseif SelfRef.GetActorValuePercentage("Magicka") == 1.0
			RestoreMagickaDrain()
			GoToState("ActiveFull")
		endif
	endFunction
	
EndState

;___________________________________________________________________________________________________________________________

; Player has full MP, 
State ActiveFull
	
	Event OnUpdate()
	DEBUGTEXT("OnUpdate Start")
		sendEvent(calculateModifier())
		RegisterForMPUpdate()
	DEBUGTEXT("OnUpdate End")
	EndEvent
	
	; Returns the time in seconds until the soonest update
	float function GetUpdateTime()
		return fMin(fMax(registeredMP[numRegistered - 1] * numPriority / MagickaRateMag, 0.0), CombatCheck)
	EndFunction
	
	; Calculates the MP siiphoned since last update using regular MagickaRateMult (convert to use parameter)
	float function calculateModifier()
		if numPriority
			float timedif = ((Utility.GetCurrentGameTime() - previousTime) / TimeScale.Value) * SecondsInDay
			return fMax(MagickaRateMag * timedif / numPriority, 0.0)
		else
			DEBUGTEXT("calculateModifer: numPriority = 0", 0, True, True)
			return 0.0
		endif
	endFunction
	
	; Attempts to change state
	Function UpdateState()
		if numRegistered == 0 && bEnableOffState
			GoToState("Off")
		elseif SelfRef.GetActorValuePercentage("Magicka") < 1.0
			GoToState("Active")
		endif
	endFunction
	
EndState

;___________________________________________________________________________________________________________________________

State RegisterBusy

	Event OnBeginState()
		UnregisterForUpdate()
		RegisterForSingleUpdate(10.0)	; Exits RegisterBusy after 10 seconds since state is probably stuck
	EndEvent
	
	Event OnUpdate()
		DEBUGTEXT(">>> OnUpdate override")
		GoToState("Active")	; Ensures Magicka drain is properly removed 
		UpdateState()
	EndEvent

	; Calling too many registers will call RgisterForMPUpdate() in this state, this might be solution
	function RegisterForMPUpdate()
		DEBUGTEXT(">>> RegisterForMPUpdate override")
		RegisterForSingleUpdate(10.0)
	endfunction	
	
	;___________________________________________________________________________________________________________________________
	
	; Removes current MP magnitude from current priority and sends events if Listener's value falls below 0
	function sendEvent(float akModifier)
	DEBUGTEXT("SendEvent Override start", 0, True, True)	
	float timedif = ((Utility.GetCurrentGameTime() - previousTime) / TimeScale.Value) * SecondsInDay
	;Debug.Messagebox("Before SendLoop:\nMPRateMag * TimeDif / PR = Modifier\n" +MagickaRateMag+ " * " +timedif+ " / " +numPriority+ " = " +akModifier+ "\n\nDrainMag * TimeDif / PR = Modifier\n" +DrainMag+ " * " +timedif+ " / " +numPriority+ " = " +akModifier)
			
		int index = numRegistered - numPriority
		int max = numRegistered
		while 	index < max
			registeredMP[index] =  registeredMP[index] - akModifier
			if registeredMP[index] <= 0.0
				registeredAB[index].bRegisteredMS = False
				registeredAb[index].OnMagickaSiphonEvent()
				DeleteRegisterElement(index)
				numRegistered -= 1
				numPriority -= 1
			endif
			index += 1
		endwhile
	
	DEBUGTEXT("SendEvent Override end\t", 0, True, True)
	endFunction
	;___________________________________________________________________________________________________________________________

	; Stores registration requests in a temporary array and deletes matches from the Unregiser buffer
	bool function RegisterForEvent(INEQ_EventListenerBase akListener, float akMagicka, int akPriority)
	DEBUGTEXT("Register Override start", 0, True, True)
		int index = UnregisterAB.find(akListener)
		if index != -1
			UnregisterAB[index] = none
			numUnregistered -= 1
		endif
		if numBuffered == bufferAb.length
			Debug.Trace(self+ ": Number of registers exceeded buffer or main array on adding " +akListener)
			return false
		elseif numBuffered + numRegistered >= registeredAb.length
			Debug.Trace(self+ ": Number of registers exceeded main array length on adding " +akListener)
			return false
		else
			index = getFirstNone(BufferAB)
			if index < 0
				Debug.MessageBox("GetFirstNone returned < 0")
				Debug.Trace("GetFirstNone returned < 0")
			endif
			SetBufferElement(index , akListener, akMagicka, akPriority) ; numBuffered
			numBuffered += 1
	DEBUGTEXT("Register Override end\t", 0, True, True)
			return true
		endif
	
	endfunction
	;___________________________________________________________________________________________________________________________

	; Stores unregistration requests in a temporary array and deletes matches Registration buffer
	Function UnregisterForEvent(INEQ_EventListenerBase akListener)
	;DEBUGTEXT("Unregister Override start", 0, True, True)
		int index = BufferAB.find(akListener)
		if index != -1
			DeleteBufferElement(index)
			numBuffered -= 1
		endif
		index = RegisteredAb.find(akListener)
		if index != -1
			if numUnregistered < UnregisterAB.length
				UnregisterAB[getFirstNone(BufferAB)] = akListener
				numUnregistered += 1
			else
				Debug.Notification(self+ ": Number of unregisters exceeded buffer on adding " +akListener)
			endif
		endif
	;DEBUGTEXT("Unregister Override end", 0, True, True)
	EndFunction
	;___________________________________________________________________________________________________________________________
	
	Event OnEndState()
		DEBUGTEXT("Endstate start\t\t\t", 0, True, True)
		
		; Removes all elements uregistered while sending events, then shifts down
		if numUnregistered
		DEBUGTEXT("Unregister EndState start", 0, True, True)
			ShiftListenerDown(UnregisterAB)
			int i = numUnregistered
			while i > 0
				i -= 1
				int index = registeredAB.find(UnRegisterAB[i])
				if index != -1
					DeleteRegisterElement(index)
					numRegistered -= 1
				endif
				UnregisterAB[i] = None
			endwhile
		DEBUGTEXT("Unregister preshift\t\t", 0, True, True)
			ShiftElementsDown(RegisteredAB, RegisteredMP, RegisteredPR)
		DEBUGTEXT("Unregister Endstate end", 0, True, True)
		endif
		
		; Adds all elements registered while sending events
		if numBuffered
		DEBUGTEXT("Register Endstate start", 0, True, True)
			ShiftElementsDown(BufferAB, BufferMP, BufferPR)
			int i = numBuffered
			while i > 0
				i -= 1
				int index = registeredAb.find(bufferAb[i])
				if index == -1
					index = numRegistered	; add to the end
					numRegistered += 1
				endif
				SetRegisterElement(index, bufferAb[i], bufferMP[i], bufferPR[i])
				DeleteBufferElement(i)
			endWhile
		DEBUGTEXT("Register Endstate end\t", 0, True, True)
		endif
		
		; If any chages were made to the Register, sort it
		if numbuffered || numUnregistered
			numUnregistered = 0
			numBuffered = 0
			sortAscending()
		endif
		UpdatePriorityCount()
		
		DEBUGTEXT("Endstate end\t\t\t", 0, True, True)
	EndEvent

EndState

;===============================================================================================================================
;====================================		Main Functions			================================================
;================================================================================================

; Assumes array sorted from low to high priority. Decrease current phase mp's and sends recharge if mp < 0
function sendEvent(float akModifier)
	DEBUGTEXT("{SendEvent Start} Modifier: " +akModifier, MBox=True)
	
	UnregisterForupdate()
	String preState = GetState()
	GoToState("RegisterBusy")
		SendEvent(akModifier)
	GoToState(preState)

	DEBUGTEXT("{SendEvent End}", MBox=True)
endfunction
;___________________________________________________________________________________________________________________________

; Assumes array sorted. If passed reference is registered, shift the elements down and remove the last one [NEEDS TESTING]
function UnregisterForEvent(INEQ_EventListenerBase akListener)
	DEBUGTEXT("{Unregister Start}", MBox=True)
	
	String preState = GetState()
	GoToState("RegisterBusy")
		UnregisterForEvent(akListener)
	GoToState(preState)
	if numRegistered > 0
		sendEvent(calculateModifier())
	endif
	RegisterForMPUpdate()
	
	DEBUGTEXT("{Unregister End}", MBox=True)
EndFunction
;___________________________________________________________________________________________________________________________

; Registers an item and a distance by adding it to an array, then sorts the items by descending distance
bool function RegisterForEvent(INEQ_EventListenerBase akListener, float akMagicka, int akPriority)
	DEBUGTEXT("{Register Start}", MBox=True)
	
	float modifier = calculateModifier()
	String preState = GetState()
	GoToState("RegisterBusy")
		sendEvent(modifier)
		bool registered = RegisterForEvent(akListener, akMagicka, akPriority)
	GoToState(preState)
	RegisterForMPUpdate()
	
	DEBUGTEXT("{Register End}", MBox=True)
	return registered
endFunction
;___________________________________________________________________________________________________________________________

; Updates fields/states and registers for an update at the calculated time
; ERROR when calling this or calculateModifier if state is changed to RegisterBusy state
function RegisterForMPUpdate()
DEBUGTEXT("RegisterForMPUpdate() Start")
	UpdateState()
	UpdateFields()
	if numRegistered > 0 && (MagickaRateMult > 0.0 || DrainMag > 0.0)
		;float updateTime = getUpdateTime()
		if GetState() != "RegisterBusy"
			float updateTime = getUpdateTime()
			RegisterForSingleUpdate(updateTime)
		endif
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Updates the fields used to calculate MP recharged
Function UpdateFields()
	if SelfRef
		UpdateTotalMagicka()
		previousTime	= Utility.GetCurrentGameTime()
		MagickaRateMult	= SelfRef.GetActorValue("MagickaRateMult")
	
		if bSiphonBelowMax
			UpdateMagickaDrain()
		endif
		
		float multiplier = (SelfRef.GetActorValue("MagickaRate")/100.0) * TotalMagicka / 100.0
		DrainMag = DrainMult * multiplier
		MagickaRateMag	= MagickaRateMult * multiplier
		if SelfRef.isInCombat()
			MagickaRateMag /= 3.0
			DrainMag /= 3.0
		endif
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Updates the calculated Total MP including buffs from ModAV
Function UpdateTotalMagicka()
	if SelfRef.getActorValuePercentage("Magicka")
		TotalMagicka = SelfRef.getActorValue("Magicka") / SelfRef.getActorValuePercentage("Magicka")
	else
		SelfRef.RestoreActorValue("Magicka", 1.0)
		TotalMagicka = SelfRef.getActorValue("Magicka") / SelfRef.getActorValuePercentage("Magicka")
		SelfRef.DamageActorValue("Magicka", 1.0)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Returns the number of elements at the highest priority
Function UpdatePriorityCount()
	if numRegistered > 0
		int index = numRegistered - 1
		int currentPriority = registeredPR[numRegistered - 1]
		while index && registeredPR[index - 1] == currentPriority
			index -= 1
		endwhile
		numPriority = numRegistered - index
	else
		numPriority = 0
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Restores net MagickaRateMult to the player from DrainMult and and clears the drain values
function RestoreMagickaDrain()
	if DrainMult
		SelfRef.ModActorValue("MagickaRateMult", DrainMult)
		MagickaRateMult = SelfRef.GetActorValue("MagickaRateMult")
		DrainMult = 0.0
		DrainMag = 0.0
	;Debug.MessageBox("Restore Magicka Drain\n[MagickaMult, DrainMult]\n[" +SelfRef.GetActorValue("MagickaRateMult")+ ", " +drainmult+ "]")
	endif
endFunction

;===============================================================================================================================
;====================================		Helper Functions		================================================
;================================================================================================

; Takes arrays of Listeners, magicka and priorities then shifts all elements towards 0 but could unsort the elements
function ShiftElementsDown(INEQ_EventListenerBase[] listener, float[] magicka, int[] priority)
	int firstNone = getFirstNone(listener)
	int lastElement = getLastElement(listener)
	if firstNone == -1 || lastElement == -1
		return
	endif
	while  firstNone < lastElement
		listener[firstNone] = listener[lastElement]
		listener[LastElement] = none

		magicka[firstNone] = magicka[lastElement]
		magicka[lastElement] = 0.0

		priority[firstNone] = priority[lastElement]
		priority[lastElement] = 0

		firstNone = getFirstNone(listener, firstNone)
		lastElement = getLastElement(listener, lastElement)
	endwhile
endFunction
;___________________________________________________________________________________________________________________________

; Takes an array of Listeners and shifts all elements towards 0 but could unsort the elements
function ShiftListenerDown(INEQ_EventListenerBase[] listener)
	int firstNone = getFirstNone(listener)
	int lastElement = getLastElement(listener)
	if firstNone != -1 || lastElement != -1
		return
	endif
	while firstNone < lastElement
		listener[firstNone] = listener[lastElement]
		listener[lastElement] = none
		firstNone = getFirstNone(listener, firstNone)
		lastElement = getLastElement(listener, lastElement)
	endwhile
endFunction
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

; Replace with better sorting algorithm later if many items are registered at any one time
function sortAscending()
	int index1 = 0
	while index1 < numRegistered - 1
		int index2 = index1 + 1
		while index2 < numRegistered
			if registeredPR[index1] == registeredPR[index2] && registeredMP[index1] < registeredMP[index2]
				swap(index1, index2)
			elseif registeredPR[index1] > registeredPR[index2]
				swap(index1, index2)
			endif
			index2 += 1
		endwhile
		index1 +=1
	endwhile		
endfunction
;___________________________________________________________________________________________________________________________

; Takes two indexes and swaps their contents in the ability and distance arrays
function swap(int a, int b)
	INEQ_EventListenerBase tempAB = registeredAb[a]
	float tempMP = registeredMP[a]
	int tempPR = registeredPR[a]
	SetRegisterElement(a, registeredAb[b], registeredMP[b], registeredPR[b])
	SetRegisterElement(b, tempAB, tempMP, tempPR)
endfunction
;___________________________________________________________________________________________________________________________
;							Various functions to handle manipulating the arrays
function SetRegisterElement(int index, INEQ_EventListenerBase akListener, float akMagicka, int akPriority)
	if index != -1
		registeredAb[index] = akListener
		registeredMP[index] = akMagicka
		registeredPR[index] = akPriority
	endif
Endfunction

function DeleteRegisterElement(int index)
	SetRegisterElement(index, none, 0.0, 0)
endfunction 


function SetBufferElement(int index, INEQ_EventListenerBase akListener, float akMagicka, int akPriority)
	if index != -1
		bufferAb[index] = akListener
		bufferMP[index] = akMagicka
		bufferPR[index] = akPriority
	endif
endFunction

function DeleteBufferElement(int index)
	SetBufferElement(index, none, 0.0, 0)
endfunction
;___________________________________________________________________________________________________________________________

; Returns the smaller of two floats
float Function fMin(float a, float b)
	if a < b
		return a 
	else
		return b
	endif
endFunction

; Returns the smaller of two ints
int Function iMin(int a, int b)
	if  a < b
		return a
	else
		return b
	endif
endFunction

; Returns the larger of two floats
float function fMax(float a, float b)
	if a > b
		return a
	else
		return b
	endif
endfunction
;___________________________________________________________________________________________________________________________

; Debugging Function for testing using trace and/or messageboxes
function DEBUGTEXT(String text, int type = -1,  bool mp = false, bool listener = false, bool MBox = False)
	if bDebugTrace
		String s = "" + GetState() + ":\t" +text
		if type != -1
			if mp || listener
				s += ":\tR:" +numRegistered+ "P:" +numPriority+ "\t"
				if type == 0
					s += "Register"
				elseif type == 1
					s += " Buffer "
				elseif type == 2
					s += "Unregstr"
				endif
			endif
			if mp
				if type == 0
					s += "[" +RegisteredMP[0]+ ", " +RegisteredMP[1]+ ", " +RegisteredMP[2]+ "]"
				elseif type == 1
					s += "[" +BufferMP[0]+ ", " +BufferMP[1]+ ", " +BufferMP[2]+ "]"
				elseif type == 2
					s += "[" +UnregisterAB[0]+ ", " +UnregisterAB[1]+ ", " +UnregisterAB[2]+ "]"
				endif
			endif
			if listener
				if type == 0
					s += "\t[" +RegisteredAB[0]+ ", " +RegisteredAB[1]+ ", " +RegisteredAB[2]+ "]"
				elseif type == 1
					s += "\t[" +BufferAB[0]+ ", " +BufferAB[1]+ ", " +BufferAB[2]+ "]"
				endif
			endif
		endif
		Debug.Trace(s)
	endif
	if bDebugMessage
		if MBox
			Debug.Messagebox(text+ ":\tnumPriority=" +numPriority+ "\n0) Priority:" +registeredPR[0]+ " MP:" +registeredMP[0]+   "\n1) Priority:" +registeredPR[1]+ " MP:" +registeredMP[1]+"\n2) Priority:" +registeredPR[2]+ " MP:" +registeredMP[2])
		endif
	endif
endFunction
;___________________________________________________________________________________________________________________________
;								Placeholder fucntions for overrides in the States
function UpdateState()
	Debug.Trace(self+ ": UpdateState() called in state \"" +GetState()+"\"")
EndFunction

float function calculateModifier()
	Debug.Trace(self+ ": calculateModifier() called in state \"" +GetState()+"\"")
	return 0.0
EndFunction

float Function getUpdateTime()
	Debug.Trace(self+ ": getUpdateTime() called in state \"" +GetState()+"\"")
	return 0.1
EndFunction

; Intentionally not overridden in non-Active states
function UpdateMagickaDrain()
	;Debug.Trace(self+ ": UpdateMagickaDrain() called in state \"" +GetState()+"\"")
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
		elseif aiButton == 1		; Siphon Below Max MP -> On
			bSiphonBelowMax = True
		elseif aiButton == 2		; Siphon Below Max MP -> Off
			RestoreDefaultFields()
		elseif aiButton == 3		; Set Siphon Percentage
			DrainPercentage = ListenerMenu.SetPercentage(DrainPercentage, DEFDrainPercentage)
		endif
	endwhile
	if GetState() != "RegisterBusy"
		RegisterForSingleUpdate(0)
	else
		Debug.Notification("Menu changed in RegisterBusy")
	endif
EndFunction

Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bSiphonBelowMax
		Button.set(2)
		Button.set(3)
	else
		Button.set(1)
	endif
	Button.set(9)
EndFunction
