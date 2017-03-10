Scriptname INEQ_Waterwalking extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	Property	abWaterwalking	Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	LookDownThreshold	=	80.0	Autoreadonly

String  Property  AnimWalking1  =  "FootRight"  Autoreadonly			; any movement with left foot
String  Property  AnimWalking2  =  "FootLeft"	Autoreadonly			; any movement with right foot
String  Property  AnimJump  	=  "JumpUp"  	Autoreadonly			; jumping up animation

;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.removespell(abWaterwalking)
	parent.EffectFinish(akTarget, akCaster)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Unequipped
	
	Event OnBeginState()
		SelfRef.removespell(abWaterwalking)
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		SelfRef.removespell(abWaterwalking)
		RegisterForAnimationEvent(selfRef, AnimJump)		
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == selfRef) &&  (EventName == AnimJump) 
			GoToState("Waterwalking")
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, AnimJump)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Waterwalking

	Event OnBeginState()
		SelfRef.addspell(abWaterwalking, false)
		RegisterForAnimationEvent(selfRef, AnimWalking1)				
		RegisterForAnimationEvent(selfRef, AnimWalking2)				
	EndEvent

	; By sneaking and looking down you can enter the water
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  (SelfRef.getAngleX() > LookDownThreshold) && (akSource == selfRef) &&( (EventName == AnimWalking1) || ( EventName == AnimWalking2) )
			GoToState("Equipped")
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, AnimWalking2)	
		UnregisterForAnimationEvent(selfRef, AnimWalking1) 
	EndEvent

EndState
