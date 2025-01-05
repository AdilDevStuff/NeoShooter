extends Control

@onready var label: Label = $CanvasLayer/Label
@onready var pause_menu : CanvasLayer = $Pause

const LEVEL_SELECT :  PackedScene = preload("res://levels/level_select.tscn")
const MAIN_MENU = preload("res://levels/main_menu.tscn")

const MAIN_MENU_MUSIC : AudioStream = preload("res://assets/audio/music/hashir/neon-gaming-128925.mp3")

func _ready() -> void:
	pause_menu.hide()


func _process(delta: float) -> void:
	update_health()
	
func update_health():
	if get_tree().paused:
		return
	
	if not (GameManager.p1 or GameManager.p2):
		return
	var p1_health : float =  GameManager.p1.health
	var p2_health : float = GameManager.p2.health
	label.text = "P1: " + str(p1_health) + " P2: " + str(p2_health)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("back"): 
		if GameManager.p1 || GameManager.p2:
			pause()


func pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide()
	else:
		get_tree().paused = true
		pause_menu.show()



func _on_level_select_btn_pressed() -> void:
	pause()
	# delete references to p1 & p2
	GameManager.p1 = null
	GameManager.p2 = null
	TransitionManager.transition_scene_packed(LEVEL_SELECT)
	SFXManager.play_music(MAIN_MENU_MUSIC, -20)
	
	#await  TransitionManager.transition_fully_finished
	#var control : MainMenu = get_tree().get_first_node_in_group("MainMenu")
	#control._on_play_button_pressed()


func _on_resume_pressed() -> void:
	pause()


func _on_main_menu_btn_pressed() -> void:
	pause()
	
	# delete references to p1 & p2
	GameManager.p1 = null
	GameManager.p2 = null
	TransitionManager.transition_scene_packed(MAIN_MENU)
	SFXManager.play_music(MAIN_MENU_MUSIC, -20)
