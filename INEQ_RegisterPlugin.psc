Scriptname INEQ_RegisterPlugin extends Quest 
{Registers the plugin to the main Infused Equipment Ability Register}

	; Handles all abilities
ReferenceAlias	Property	AbilityRegister		Auto

	; Formlist containing every ability quest from the main mod and other INEQ plugins
FormList	Property	INEQ__AbilitiesToPlayerList		Auto

	; Formlist containing every recharge source quest from the main mod and other INEQ plugins
Formlist	Property	INEQ__RechargeSourceList		Auto

	; Formlists containing equipment slot quests from the main mod and other INEQ plugins
	; Uncomment the ones that are used in the plugin
;Formlist	Property	INEQ__Equipment_BodyQuests		Auto
Formlist	Property	INEQ__Equipment_FeetQuests		Auto
;Formlist	Property	INEQ__Equipment_HandsQuests		Auto
;Formlist	Property	INEQ__Equipment_HeadQuests		Auto
;Formlist	Property	INEQ__Equipment_ShieldQuests		Auto
;Formlist	Property	INEQ__Equipment_WBowQuests		Auto
;Formlist	Property	INEQ__Equipment_WDaggerQuests	Auto
;Formlist	Property	INEQ__Equipment_WSwordQuests		Auto

	; The ability quest for all abilities local to this plugin
Quest	Property		AbilitiesToPlayer		Auto

	; The recharge source quest for all abilities local to this plugin
Quest	Property		RechargeSource			Auto

	; The slot quests that are local to this plugin
	; Uncomment the ones that are used in the plugin
;Quest	Property	AbilityAlias_Body		Auto
Quest	Property	AbilityAlias_Feet		Auto
;Quest	Property	AbilityAlias_Hands		Auto
;Quest	Property	AbilityAlias_Head		Auto
;Quest	Property	AbilityAlias_Shield		Auto
;Quest	Property	AbilityAlias_WBow		Auto
;Quest	Property	AbilityAlias_WDagger	Auto
;Quest	Property	AbilityAlias_WSword		Auto

;_____________________________________________________________________________________

Event OnInit()
	(AbilityRegister as INEQ_AbilityRegister).iPluginRegisterPending += 1
		; Adds recharges sources in this mod to the main plugins's formlist
	INEQ__RechargeSourceList.AddForm(RechargeSource)

		; Add abilities in this mod to the main plugins's formlist
	INEQ__AbilitiesToPlayerList.AddForm(AbilitiesToPlayer)
		
		; Add the quests of each equipment slot to their corresponding formlist from the main plugin
;	INEQ__Equipment_BodyQuests.AddForm(AbilityAlias_Body)
	INEQ__Equipment_FeetQuests.AddForm(AbilityAlias_Feet)
;	INEQ__Equipment_HandsQuests.AddForm(AbilityAlias_Hands)
;	INEQ__Equipment_HeadQuests.AddForm(AbilityAlias_Head)
;	INEQ__Equipment_ShieldQuests.AddForm(AbilityAlias_Shield)
;	INEQ__Equipment_WBowQuests.AddForm(AbilityAlias_WBow)
;	INEQ__Equipment_WDaggerQuests.AddForm(AbilityAlias_WDagger)
;	INEQ__Equipment_WSwordQuests.AddForm(AbilityAlias_WSword)
	
		; Forces the main plugin to update its list of available abilities
	(AbilityRegister as INEQ_AbilityRegister).attemptMaintenance()
EndEvent

Event OnPlayerLoadGame()
	Debug.Notification("Register Plugin, playerloadgame")
EndEvent
