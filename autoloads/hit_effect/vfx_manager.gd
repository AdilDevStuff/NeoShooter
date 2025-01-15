extends Node2D
# =============================================================================================
# CONSTANT PRELOADS
# =============================================================================================
## @deprecated: Use [AnotherClass] instead
# DEPRECATED I THINK SO
# VFX DIE
const DISTORTION : PackedScene = preload("res://vfx/player_die/distortion.tscn")
const DIE_VFX : PackedScene = preload("res://vfx/player_die/die_vfx.tscn")

# VFX SHOOT
const BULLET_SHOOT : PackedScene = preload("res://vfx/bullet_shoot/bullet_shoot_vfx.tscn")
# =============================================================================================
# NORMAL VARIABLES
# =============================================================================================
@onready var chroma_rect: ColorRect = $CanvasLayer/ChromaticAbberation
@onready var ani_player: AnimationPlayer = $AnimationPlayer
@onready var hitstop_timer: Timer = $HitStopTimer

var camera : SpaceShooterCamera


# =============================================================================================
# Collection Functions
# =============================================================================================

## Handles all hitstop shockwave cam shake and particles for the
## death vfx
func die_effects(player : Player2D) -> void:
	hit_stop(3, 0.25)
	# player_dead_shockwave(player)
	camera_shake(200)
	die_vfx(player)
	await hitstop_timer.timeout
	UIManager.show_death_screen(player)
	
## Called by the player or the object via on_hit()
func hit_effects(hitbox : HitBox) -> void:
	hit_stop(hitbox.hit_stop)
	camera_shake(hitbox.cam_shake_str)
	hit_vfx(hitbox)

# =============================================================================================
# Independent Functions
# =============================================================================================

func die_vfx(player : Player2D) -> void:
	var particle_vfx  : CPUParticles2D = DIE_VFX.instantiate()
	self.add_child(particle_vfx)
	
	particle_vfx.global_position = player.global_position
	particle_vfx.emitting = true
	particle_vfx.color_ramp = player.trails_vfx.color_ramp
	await particle_vfx.finished
	
	self.remove_child(particle_vfx)
	particle_vfx.queue_free()

func player_dead_shockwave(player : Player2D) -> void:
	var sprite : DistortionSprite = DISTORTION.instantiate()
	self.add_child(sprite)
	sprite.scale = Vector2(100, 100)
	sprite.z_index = 3
	
	#  get_viewport().get_camera_2d().unproject
	# player.get_viewport_transform() * player.global_position
	#var screen_coords = player.get_viewport_transform() * player.global_position
	#var normalized_screen_coords = screen_coords / get_viewport().get_visible_rect().size
	
	var uv_coords = (player.get_global_transform_with_canvas().get_origin()/ get_viewport().get_visible_rect().size ) 
	print_debug(
		"UV 1 : ", uv_coords
	)
	#sprite.material.set("shader_parameter/center", uv_coords)
	sprite.material.set("shader_parameter/global_position", player.global_position)
	var tween = get_tree().create_tween()
	tween.tween_method(sprite.set_shader_value, 0.0, 1.2, 1)
	await  tween.finished
	tween.kill()
	player.remove_child(sprite)
	sprite.queue_free()

func hit_stop(duration : float, time_scale : float = 0.05) -> void:
	## reset the previous hit_stop :C
	#Engine.time_scale = 1
	#var engine_time_scale = Engine.time_scale
	#Engine.time_scale = time_scale
	#await  get_tree().create_timer(duration * time_scale).timeout
	#Engine.time_scale = engine_time_scale
	var engine_time_scale : float = 1 # = Engine.time_scale
	Engine.time_scale = time_scale
	hitstop_timer.wait_time  = duration * time_scale
	hitstop_timer.start()
	await hitstop_timer.timeout
	# might be stacking as multiple bullets will call multiple awaits
	# but idk
	Engine.time_scale = engine_time_scale
	
func camera_shake(shake_str : float)  -> void:
	GameManager.camera.rand_str = shake_str * GameManager.user_prefs.screen_shake_multiplier
	GameManager.camera.apply_shake()

func hit_vfx(hitbox: ProjectileHitBox) -> void:
	chromatic_abberation(hitbox)
	var particle_vfx  : CPUParticles2D = hitbox.vfx.instantiate()
	self.add_child(particle_vfx)
	
	particle_vfx.global_position = hitbox.global_position
	particle_vfx.emitting = true
	
	await particle_vfx.finished
	
	self.remove_child(particle_vfx)
	particle_vfx.queue_free()

func chromatic_abberation(hitbox : HitBox):
	#chroma_rect.material.shader_parameter.spread = hitbox.chroma_str
	# set chroma str
	# set_chroma_rect_value(hitbox.chroma_str)
	chroma_rect.visible
	
	var tween : Tween = get_tree().create_tween()
	
	# picks random -ve or positive
	var rand_no : int = [-1, 1].pick_random()
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# chroma multiplier can be zero
	var chroma_val : float = hitbox.chroma_str * rand_no * GameManager.user_prefs.chroma_multiplier
	tween.tween_method(set_chroma_rect_value, chroma_val, 0.0, hitbox.screw_state)
	
	await tween.finished
	tween.kill()
	# chroma_rect.hide()
	# ani_player.play("hit")

func set_chroma_rect_value(value : float):
	chroma_rect.material.set("shader_parameter/chroma_strength", value)

func shoot_vfx(pos : Vector2) -> void:
	var particle_vfx  : CPUParticles2D = BULLET_SHOOT.instantiate()
	self.add_child(particle_vfx)
	
	particle_vfx.global_position = pos
	particle_vfx.emitting = true
	
	await particle_vfx.finished
	
	self.remove_child(particle_vfx)
	particle_vfx.queue_free()
