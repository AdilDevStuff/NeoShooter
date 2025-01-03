extends Node2D

# VFX HIT
const NORMAL_HIT : PackedScene = preload("res://vfx/bullet_hit/hit_normal_vfx.tscn")
const SMALL_HIT : PackedScene = preload("res://vfx/bullet_hit/hit_small_vfx.tscn")
const BIG_HIT : PackedScene = preload("res://vfx/bullet_hit/hit_big_vfx.tscn")

# VFX DIE
const DISTORTION : PackedScene = preload("res://vfx/player_die/distortion.tscn")

# VFX SHOOT
const BULLET_SHOOT : PackedScene = preload("res://vfx/bullet_shoot/bullet_shoot_vfx.tscn")

@onready var chroma_rect: ColorRect = $CanvasLayer/ChromaticAbberation
@onready var ani_player: AnimationPlayer = $AnimationPlayer

var camera : SpaceShooterCamera


# WORKS BUT NEEDS JUICEEEEEEEEEEEEEEEEEEEEEEEEEE
func player_dead_vfx(player : Player2D) -> void:
	var sprite : DistortionSprite = DISTORTION.instantiate()
	player.add_child(sprite)
	
	sprite.scale = Vector2(100, 100)
	sprite.z_index = 3
	
	var screenCoords = player.get_viewport_transform() * player.global_position
	var normalizedScreenCoords = screenCoords / get_viewport().get_visible_rect().size
	
	sprite.material.set("shader_parameter/center", normalizedScreenCoords)
	
	var tween = get_tree().create_tween()
	tween.tween_method(sprite.set_shader_value, 0.0, 1.2, 1)
	await  tween.finished
	tween.kill()
	player.remove_child(sprite)
	sprite.queue_free()


func hit_stop(duration : float, time_scale : float = 0.05) -> void:
	
	if Engine.time_scale == 0.05: # if already  started
		return
		
	var engine_time_scale = Engine.time_scale
	Engine.time_scale = time_scale
	
	await  get_tree().create_timer(duration * time_scale).timeout
	
	Engine.time_scale = engine_time_scale

func camera_shake(shake_str : float)  -> void:
	camera.rand_str = shake_str
	camera.apply_shake()

func hit_vfx(hitbox: ProjectileHitBox) -> void:
	chormatic_abberation(hitbox)
	var particle_vfx  : CPUParticles2D = get_hit_vfx_type(hitbox.bullet)
	self.add_child(particle_vfx)
	
	particle_vfx.global_position = hitbox.global_position
	particle_vfx.emitting = true
	
	await particle_vfx.finished
	
	self.remove_child(particle_vfx)
	particle_vfx.queue_free()

func chormatic_abberation(hitbox : HitBox):
	#chroma_rect.material.shader_parameter.spread = hitbox.chroma_str
	# set chroma str
	chroma_rect.material.set("shader_parameter/spread", hitbox.chroma_str)
	ani_player.play("hit")

func get_hit_vfx_type(bullet : Bullet2D) -> CPUParticles2D:
	const BULLET_TYPE = BulletManager.BULLET_TYPE
	var particle_vfx : CPUParticles2D
	# get the bullet type
	match bullet.type:
		BULLET_TYPE.NORMAL:
			particle_vfx = NORMAL_HIT.instantiate()
		BULLET_TYPE.BIG:
			particle_vfx = BIG_HIT.instantiate()
		BULLET_TYPE.SMALL:
			particle_vfx = SMALL_HIT.instantiate()
		_:
			particle_vfx = NORMAL_HIT.instantiate()
			
	return particle_vfx

func shoot_vfx(pos : Vector2) -> void:
	var particle_vfx  : CPUParticles2D = BULLET_SHOOT.instantiate()
	self.add_child(particle_vfx)
	
	particle_vfx.global_position = pos
	particle_vfx.emitting = true
	
	await particle_vfx.finished
	
	self.remove_child(particle_vfx)
	particle_vfx.queue_free()
