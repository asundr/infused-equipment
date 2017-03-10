Scriptname INEQ_TeleportArrowAliasScript extends ReferenceAlias  

;===========================================  Properties  ===========================================================================>
Sound	Property	TeleportFailSound		Auto
Sound	Property	TeleportReadySound		Auto
Sound	property	WPNImpactArrowStick		Auto
Sound	property	WPNImpactArrowBounce	Auto

ImageSpaceModifier	property	TelportStartFX	Auto
VisualEffect	Property	MGTeleportInEffect	Auto

Spell	Property	ConcealmentSpell		Auto
Spell	Property	FallInvulnerabilitySP	Auto
Perk	Property	FallInvulnerability		Auto

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
	;	Debug.Notification("ref: " +( ArrowRef.GetBaseObject().getFormID()) )
	if (ArrowRef)
		PlayerRef = Game.GetPlayer()
		ArrowRef.SetLockLevel(1)		;tags arrow as "locked", Alias will only use "unlocked" arrows, so only newly fired arrows are aquired by alias
		preAngleZ = ArrowRef.GetAngleZ()
		prePosX = ArrowRef.GetPositionX() 
		prePosY = ArrowRef.GetPositionY()
		RegisterForAnimationEvent(PlayerRef, EventJump)						; jump to initiate teleport
		RegisterForAnimationEvent(PlayerRef, EventCancelArrow)				; knock then
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
	;			Debug.Notification("Arrow rebounded, Dist: " +(PlayerRef.getDistance(ArrowRef) as int))
				bTeleport = True
				if ( PlayerRef.getDistance(ArrowRef) > arrowImpactDistance )
					int instance = WPNImpactArrowBounce.play(PlayerRef)
					Sound.SetInstanceVolume(instance, 0.3)
				endif
				TeleportReadySound.play(PlayerRef)
			elseif (postPosX == PrePosX) && (postPosY == PrePosY)
	;			Debug.Notification("Arrow embedded, Dist: " +  (PlayerRef.getDistance(ArrowRef) as int))
				bTeleport = True
				if ( PlayerRef.getDistance(ArrowRef) > arrowImpactDistance )
					int instance = WPNImpactArrowStick.play(PlayerRef)
					Sound.SetInstanceVolume(instance, 0.3)
				endif
				TeleportReadySound.play(PlayerRef)
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
		if (EventName == EventCancelArrow)					;teleport cancelled
			String var = "iState_NPCBowDrawn"
;			Debug.Notification("Teleport Cancelled... AnimationVariable " + var + ": "+ PlayerRef.GetAnimationVariableInt(var))
			TeleportFailSound.play(PlayerRef)
			bTeleport = FALSE
		elseif ArrowRef 		;&& (EventName == EventJump)						;teleport initiated
			float dist2D = getDistanceXY(playerRef, ArrowRef)	
			float dist3d = PlayerRef.getDistance(ArrowRef)
			if (maxDistance > dist2D)
				if (minDistance < dist3D)		;conditions met, teleport activated
					teleport(dist2D, dist3D)
					;Debug.Notification(ArrowRef.getFormID() + ": 2D=" +dist2D+ ", 3D=" +dist3D)
					self.clear()
					ArrowRef = None
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

; Teleports the player to the arrow
Function teleport(float distance2D, float distance3D, bool instant = false)
	if (true)		 ; magicka check, make Teleport cost bool function
;		TeleportCostSpell.cast(PlayerRef, PlayerRef)				; damages MP on the caster
		TelportStartFX.apply()
;		PlayerRef.addperk(fallInvulnerability)
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
;		PlayerRef.removeperk(fallInvulnerability)
	endif
endFunction
;___________________________________________________________________________________________________________________________

; Returns the distance between two objects ignoring height
float Function getDistanceXY(ObjectReference ob1, ObjectReference ob2)
	float dx = ob2.GetPositionX() - ob1.GetPositionX()
	float dy = ob2.GetPositionY() - ob1.GetPositionY()
	return Math.sqrt(dx*dx + dy*dy)
endfunction
;___________________________________________________________________________________________________________________________

; if actor is hit
Event OnUnload()
	GoToState("Unloaded")
	self.TryToDisableNoWait()
	self.clear()
	ArrowRef = None
	TeleportFailSound.play(PlayerRef)
	bTeleport = False
	UnregisterForUpdate()
EndEvent
;___________________________________________________________________________________________________________________________

Event OnActivate(ObjectReference akActionRef)
	Debug.Notification("Arrow Activated")
EndEvent
;___________________________________________________________________________________________________________________________

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack,   bool abBashAttack, bool abHitBlocked)
	Debug.Notification("Ow!")
EndEvent
;___________________________________________________________________________________________________________________________


State Unloaded
	
	Event OnInit()
	EndEvent
	
	Event OnUpdate()
	Endevent

EndState
