extends Control

@onready var label: Label = $UILayer/Label
@onready var pause_menu : CanvasLayer = $Pause
@onready var vic_screen: CanvasLayer = $VictoryScreen
@onready var vic_screen_label: Label = $VictoryScreen/Transition/Label

const  LEVEL_SELECT :  PackedScene = preload("res://levels/scenes/level_select.tscn")
const MAIN_MENU :  PackedScene = preload("res://levels/scenes/main_menu.tscn")

const MAIN_MENU_MUSIC : AudioStream = preload("res://assets/audio/music/hashir/main_menu.mp3")

var can_pause : bool = true
var can_update_health : bool = false

func _ready() -> void:
	$"BG(test_only)".hide()
	pause_menu.hide()
	vic_screen.hide()

func _process(delta: float) -> void:
	update_health()
	
func update_health():
	if get_tree().paused:
		return
	if !can_update_health:
		return
	
	var p1_health : float =  GameManager.p1.health
	var p2_health : float = GameManager.p2.health
	label.text = "P1: " + str(p1_health) + " P2: " + str(p2_health)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("back"): 
		if GameManager.p1 || GameManager.p2:
			if can_pause:
				pause()


func pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide()
	else:
		get_tree().paused = true
		pause_menu.show()
		$Pause/Blur/VBoxContainer/Resume.grab_focus()


func _on_level_select_btn_pressed() -> void:
	pause()
	GameManager.match_end()
	can_update_health = false
	
	TransitionManager.transition_scene_packed(LEVEL_SELECT)
	SFXManager.play_music(MAIN_MENU_MUSIC, -20)
	
	#await  TransitionManager.transition_fully_finished
	#var control : MainMenu = get_tree().get_first_node_in_group("MainMenu")
	#control._on_play_button_pressed()


func _on_resume_pressed() -> void:
	pause()


func _on_restart_pressed() -> void:
	pause() # unpause
	
	can_pause = false
	GameManager.match_end()
	
	var current_level : String = get_tree().current_scene.scene_file_path
	TransitionManager.transition_scene_file(current_level)
	
	SFXManager.play_random_bg_music()
	# faded in
	await  TransitionManager.transiton_finsihed
	self.hide()
	
	# faded out
	await TransitionManager.transition_fully_finished
	can_pause = true

func _on_main_menu_btn_pressed() -> void:
	pause()
	can_update_health = false
	can_pause = false
	GameManager.match_end()
	TransitionManager.transition_scene_packed(MAIN_MENU)
	SFXManager.play_music(MAIN_MENU_MUSIC, -20)

## player is the dead player
func show_death_screen(player: Player2D) -> void:
	can_pause = false
	vic_screen.show()
	$VictoryScreen/VicAniPlayer.play("transition")
	$VictoryScreen/Transition/VBoxContainer/Restart.grab_focus()
	if player == GameManager.p1:
		vic_screen_label.text = "--------- Player 2 Wins ---------"
		# set the color to the won player's body
		vic_screen_label.set("theme_override_colors/font_color", GameManager.p2.body.color)
	elif player == GameManager.p2:
		vic_screen_label.text = "--------- Player 1 Wins ---------"
		vic_screen_label.set("theme_override_colors/font_color", GameManager.p1.body.color)
