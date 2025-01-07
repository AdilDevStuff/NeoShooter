extends Node 

var camera : SpaceShooterCamera
var p1 : Player2D
var p2 : Player2D


func match_end():
	if !p1:
		return
	if !p2:
		return
	# disable all input 
	p1.is_input_enabled = false
	p2.is_input_enabled = false
	# we need a transition so that player cant see if bullets are dead
	BulletManager.destroy_all_bullets()
