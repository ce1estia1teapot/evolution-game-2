extends Node
class_name BaseSignalBus

signal report_state_transition(trans_subject: StateMachine, initial_state: BaseState, end_state: BaseState)
signal report_menu_transition(transition_handler: MenuManager, initial_menu: BaseMenu, new_menu: BaseMenu)
