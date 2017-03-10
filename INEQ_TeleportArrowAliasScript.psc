Scriptname INEQ_TeleportArrowAliasScript extends ReferenceAlias  
{Tracks an arrow and allows the player to teleport to the arrow}

;===========================================  Properties  ===========================================================================>
Sound	Property	TeleportFailSound		Auto
Sound	Property	INEQ__ShoutFail			Auto
Sound	Property	TeleportReadySound		Auto
Sound	property	WPNImpactArrowStick		Auto
Sound	property	WPNImpactArrowBounce	Auto

Spell	Property	ConcealmentSpell		Auto
Spell	Property	FallInvulnerabilitySP	Auto

ImageSpaceModifier	Property	TelportStartFX		Auto
VisualEffect		Property	MGTeleportInEffect	Auto

GlobalVariable	Property	ShoutTime	Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	minDistance			=	300.0	Autoreadonly
float	Property	maxDistance			=	4096.0	Autoreadonly
float	Property	arrowImpactDistance	=	2048.0  Autoreadonly
float	Property	teleportSpeed		=	8000.0	Autoreadonly

String	Property	EventJump			=	"JumpUp"					Autoreadonly
String	Property	EventCancelArrow	=	"SoundPlay.WPNBowNockSD"	Autoreadonly;  "InterruptCast" ;  "attackStop" 
;===========================================  Variables  ============================================================================>
Actor PlayerRef
ObjectReference ArrowRef

bool bTeleport = False

float preAngleZ
float postAngleZ
float prePosX
float postPosX
float prePosY
float postPosY
;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

; Register's the arrow and if it exists, starts to poll it
Event OnInit()
	ArrowRef = getReference()
	if (ArrowRef)
		ArrowRef.SetLockLevel(1)		;tags arrow as "locked", Alias will only use "unlocked" arrows, so only newly fired arrows are aquired by alias
		preAngleZ = ArrowRef.GetAngleZ()
		prePosX = ArrowRef.GetPositionX() 
		prePosY = ArrowRef.GetPositionY()
		PlayerRef = Game.GetPlayer()
		RegisterForAnimationEvent(PlayerRef, EventJump)						; jump to initiate teleport
		RegisterForAnimationEvent(PlayerRef, EventCancelArrow)				; nock then cancel to cancel teleport
		RegisterForSingleUpdate(0)
	endif
endEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Polls the arrow to check if it has landed
Event OnUpdate()
	if ArrowRef
		postAngleZ = ArrowRef.GetAngleZ() ;as int
		postPosX = ArrowRef.GetPositionX() ;as int
		postPosY = ArrowRef.GetPositionY() ;as int
		
		if postPosX != postPosY
			if (preAngleZ != postAngleZ)
				RegisterImpact(WPNImpactArrowBounce)
			elseif (postPosX == PrePosX) ;&& (postPosY == PrePosY)
				RegisterImpact(WPNImpactArrowStick)
			else
				prePosX = postPosX
				prePosY = postPosY
				RegisterForSingleUpdate(0.2)
			endif
		endif
		
	endif	
endEvent
;___________________________________________________________________________________________________________________________

; Determines whether to teleport the player
Event OnAnimationEvent(ObjectReference akSource, string EventName)
	if bTeleport 
		if (EventName == EventCancelArrow)				;teleport cancelled
;			String var = "iState_NPCBowDrawn"
;			Debug.Notification("Teleport Cancelled... AnimationVariable " + var + ": "+ PlayerRef.GetAnimationVariableInt(var))
			;TeleportFailSound.play(PlayerRef)
			bTeleport = False
		elseif ArrowRef 		;&& (EventName == EventJump)						;teleport initiated
			float dist2D = getDistanceXY(playerRef, ArrowRef)	
			float dist3d = PlayerRef.getDistance(ArrowRef)
			if (maxDistance > dist2D)
				if (minDistance < dist3D)
					if TeleportCost()
						Teleport(dist2D, dist3D)
						self.clear()
						ArrowRef = None
					else
						INEQ__ShoutFail.play(PlayerRef)
					endif
				else
					Debug.Notification("Too close to arrow")
					TeleportFailSound.play(PlayerRef)
				endif
			else
				Debug.Notification("Too far from arrow")
				TeleportFailSound.play(PlayerRef)
			endif
		endif
	endif

EndEvent
;___________________________________________________________________________________________________________________________

; Enables teleport and notifies the player of this
Function RegisterImpact(Sound ImpactSound)
	;Debug.Notification("Dist: " +  (PlayerRef.getDistance(ArrowRef) as int))
	bTeleport = True
	if PlayerRef.getDistance(ArrowRef) > arrowImpactDistance
		int instance = ImpactSound.play(PlayerRef)
		Sound.SetInstanceVolume(instance, 0.3)
	endif
	TeleportReadySound.play(PlayerRef)
EndFunction
;___________________________________________________________________________________________________________________________

; Teleports the player to the arrow
Function Teleport(float distance2D, float distance3D, bool instant = false)
	;Debug.Notification(ArrowRef.getFormID() + ": 2D=" +distance2D+ ", 3D=" +distance3D)
	TelportStartFX.apply()
	FallInvulnerabilitySP.cast(PlayerRef, PlayerRef)
	MGTeleportInEffect.play(PlayerRef, 3.6)
	if instant
		Utility.wait(0.2)
		PlayerRef.moveTo(ArrowRef, abMatchRotation = false)			
	else
		float modifiedSpeed = teleportSpeed
		if (distance3D > maxDistance)
			modifiedSpeed *= distance3D / maxDistance
		endif
		PlayerRef.addspell(ConcealmentSpell, false)
		PlayerRef.SplineTranslateToRef(ArrowRef, 1.0,  modifiedSpeed)
		Utility.wait(distance3D / modifiedSpeed)
		PlayerRef.removespell(ConcealmentSpell)
	endif
	TelportStartFX.Remove()
endFunction
;___________________________________________________________________________________________________________________________

; Determines whether to use teleport and apply the shout cost
bool Function TeleportCost()
	if ShoutTime.Value && PlayerRef.isInCombat()
		if !PlayerRef.GetVoiceRecoveryTime()
			PlayerRef.SetVoiceRecoveryTime(ShoutTime.Value * PlayerRef.GetActorValue("ShoutRecoveryMult"))
			return True
		endif
	else
		return True
	endif
	return false
EndFunction
;___________________________________________________________________________________________________________________________

; Returns the distance between two objects ignoring height
float Function getDistanceXY(ObjectReference ob1, ObjectReference ob2)
	float dx = ob2.GetPositionX() - ob1.GetPositionX()
	float dy = ob2.GetPositionY() - ob1.GetPositionY()
	return Math.sqrt(dx*dx + dy*dy)
endfunction
;___________________________________________________________________________________________________________________________

; When arrow hits actor or some other object that unloads it
Event OnUnload()
	GoToState("Unloaded")
	UnregisterForUpdate()
	ArrowRef = None
	bTeleport = False
;	TeleportFailSound.play(PlayerRef)
EndEvent
;___________________________________________________________________________________________________________________________

; Behavior for when non-embedded arrow is hit
;Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
;	Debug.Notification("Ow!")
;EndEvent
;___________________________________________________________________________________________________________________________

State Unloaded
	
	Event OnUpdate()
	Endevent

EndState
