;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 11
Scriptname INEQ_Hands_NamiraRing_PFragment Extends Perk Hidden

;BEGIN FRAGMENT Fragment_10
Function Fragment_10(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
PlayerRef.StartCannibal(akTargetRef as Actor)
DA11CannibalismAbility.Cast(PlayerRef, PlayerRef)
DA11CannibalismAbility02.Cast(PlayerRef, PlayerRef)

;Game.GetPlayer().AddSpell(DA11CannibalismAbility)
;Game.GetPlayer().AddSpell(DA11CannibalismAbility02, abVerbose= false)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  

Spell Property DA11CannibalismAbility  Auto  

Spell Property DA11CannibalismAbility02  Auto  

Actor Property PlayerRef  Auto  
