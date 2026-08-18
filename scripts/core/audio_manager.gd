extends Node

var sfx_rotate: AudioStreamPlayer
var sfx_target_hit: AudioStreamPlayer
var sfx_button: AudioStreamPlayer

func _ready():
	sfx_rotate = AudioStreamPlayer.new()
	add_child(sfx_rotate)
	
	sfx_target_hit = AudioStreamPlayer.new()
	add_child(sfx_target_hit)
	
	sfx_button = AudioStreamPlayer.new()
	add_child(sfx_button)
	
	# Streams will be loaded here in Phase 16 (Asset replacement/polish)

func play_rotate():
	if sfx_rotate.stream != null:
		sfx_rotate.play()

func play_target_hit():
	if sfx_target_hit.stream != null and not sfx_target_hit.playing:
		sfx_target_hit.play()

func play_button():
	if sfx_button.stream != null:
		sfx_button.play()
