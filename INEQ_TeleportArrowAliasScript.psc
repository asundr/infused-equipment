Scriptname INEQ_TeleportArrowAliasScript extends ReferenceAlias  

Sound  Property  TeleportFailSound  auto
Sound  Property TeleportReadySound  auto
Sound  property  WPNImpactArrowStick  auto
Sound  property  WPNImpactArrowBounce  auto
ImageSpaceModifier  property  TelportStartFX  auto
VisualEffect  Property  MGTeleportInEffect  Auto
Spell  Property ConcealmentSpell auto
Perk Property FallInvulnerability Auto
Spell  Property  FallInvulnerabilitySP  Auto

float preAngleZ
float postAngleZ
float prePosX
float postPosX
float prePosY
float postPosY

float minDistance = 300.0
float maxDistance = 4096.0
float property arrowImpactDistance = 2048.0  autoreadonly
float property speed = 8000.0 autoreadonly

bool bTeleport = FALSE

String property EventJump = "JumpUp" autoreadonly
String property EventCancelArrow = "SoundPlay.WPNBowNockSD"  autoreadonly;  "InterruptCast" ;  "attackStop" 

Actor PlayerRef
ObjectReference selfRef

Event OnInit()
	PlayerRef = Game.GetPlayer()
	selfRef = self.getReference()
	;	Debug.Notification("ref: " +( selfRef.GetBaseObject().getFormID()) )
	if (selfRef)
		selfRef.SetLockLevel(1)		;tags arrow as "locked", Alias will only use "unlocked" arrows, so only newly fired arrows are aquired by alias
		preAngleZ = selfRef.GetAngleZ() ;as int
		prePosX = selfRef.GetPositionX() ;as int
		prePosY = selfREf.GetPositionY() ;as int
		RegisterForAnimationEvent(PlayerRef, EventJump)						; jump to initiate teleport
		RegisterForAnimationEvent(PlayerRef, EventCancelArrow)				; knock then
		RegisterForSingleUpdate(0)
	endif

endEvent


Event OnActivate(ObjectReference akActionRef)
	Debug.Notification("Arrow Activated")
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack,   bool abBashAttack, bool abHitBlocked)
	Debug.Notification("Ow!")
EndEvent


Event OnUpdate()
	if selfRef
		postAngleZ = selfRef.GetAngleZ() ;as int
		postPosX = selfRef.GetPositionX() ;as int
		postPosY = selfRef.GetPositionY() ;as int

		if postPosX != postPosY 			; (SelfRef.isEnabled())
			if (preAngleZ != postAngleZ) 
	;			Debug.Notification("Arrow rebounded, Dist: " +(PlayerRef.getDistance(SelfRef) as int))
				bTeleport = TRUE
				if ( PlayerRef.getDistance(SelfRef) > arrowImpactDistance )
					int instance = WPNImpactArrowBounce.play(PlayerRef)
					Sound.SetInstanceVolume(instance, 0.3)
				endif
				TeleportReadySound.play(PlayerRef)
			elseif (postPosX == PrePosX) && (postPosY == PrePosY)
	;			Debug.Notification("Arrow embedded, Dist: " +  (PlayerRef.getDistance(SelfRef) as int))
				bTeleport = TRUE
				if ( PlayerRef.getDistance(SelfRef) > arrowImpactDistance )
					int instance = WPNImpactArrowStick.play(PlayerRef)
					Sound.SetInstanceVolume(instance, 0.3)
				endif
				TeleportReadySound.play(PlayerRef)
			else
	;			Debug.Notification("Arrow still flying...")
				prePosX = postPosX
				prePosY = postPosY
				RegisterForSingleUpdate(0.2)
			endif
		endif
		
	endif	
endEvent



Event OnAnimationEvent(ObjectReference akSource, string EventName)
	if bTeleport 
		if (EventName == EventCancelArrow)					;teleport cancelled
			String var = "iState_NPCBowDrawn"
;			Debug.Notification("Teleport Cancelled... AnimationVariable " + var + ": "+ PlayerRef.GetAnimationVariableInt(var))
			TeleportFailSound.play(PlayerRef)
			bTeleport = FALSE
		elseif selfref 		;&& (EventName == EventJump)						;teleport initiated
			float dist2D = getDistanceXY(playerRef, SelfRef)	
			float dist3d = PlayerRef.getDistance(SelfRef)
			if (maxDistance > dist2D)
				if (minDistance < dist3D)		;conditions met, teleport activated
					teleport(dist2D, dist3D)
					;Debug.Notification(selfref.getFormID() + ": 2D=" +dist2D+ ", 3D=" +dist3D)
					self.clear()
					selfRef = None
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


Function teleport(float distance2D, float distance3D, bool instant = false)
	if (true)		 ; magicka check, make Teleport cost bool function
;		TeleportCostSpell.cast(PlayerRef, PlayerRef)				; damages MP on the caster
		TelportStartFX.apply()
;		PlayerRef.addperk(fallInvulnerability)
		FallInvulnerabilitySP.cast(PlayerRef, PlayerRef)
		MGTeleportInEffect.play(PlayerRef, 3.6)
		if instant
			Utility.wait(0.2)
			PlayerRef.moveTo(selfRef, abMatchRotation = false)			
		else
			float modifiedSpeed = speed
			if (distance3D > maxDistance)
				modifiedSpeed *= distance3D / maxDistance
			endif
			PlayerRef.addspell(ConcealmentSpell, false)
			PlayerRef.SplineTranslateToRef(selfRef, 1.0,  modifiedSpeed)
			Utility.wait(distance3D / modifiedSpeed)
			PlayerRef.removespell(ConcealmentSpell)
		endif
		TelportStartFX.Remove()
;		PlayerRef.removeperk(fallInvulnerability)
	endif
endFunction


float Function getDistanceXY(ObjectReference ob1, ObjectReference ob2) global
	float dx = ob2.GetPositionX() - ob1.GetPositionX()
	float dy = ob2.GetPositionY() - ob1.GetPositionY()
	return Math.sqrt(dx*dx + dy*dy)
endfunction


; if actor is hit
Event OnUnload()
;	Debug.Notification("arrow unloaded")

	GoToState("Unloaded")

	self.TryToDisableNoWait()
	self.clear()
	selfRef=none
	TeleportFailSound.play(PlayerRef)
	bTeleport = FALSE
	UnregisterForUpdate()
EndEvent


State Unloaded
	
	Event OnInit()
	EndEvent
	
	Event OnUpdate()
	Endevent

EndState
