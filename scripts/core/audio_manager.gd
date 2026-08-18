extends Node

var sfx_rotate: AudioStreamPlayer
var sfx_target_hit: AudioStreamPlayer
var sfx_button: AudioStreamPlayer

func _ready():
	sfx_rotate = AudioStreamPlayer.new()
	add_child(sfx_rotate)
	sfx_rotate.stream = _create_tone(650.0, 0.05)
	
	sfx_target_hit = AudioStreamPlayer.new()
	add_child(sfx_target_hit)
	sfx_target_hit.stream = _create_tone(880.0, 0.25)
	
	sfx_button = AudioStreamPlayer.new()
	add_child(sfx_button)
	sfx_button.stream = _create_tone(440.0, 0.04)

func play_rotate():
	if sfx_rotate.stream != null:
		sfx_rotate.play()

func play_target_hit():
	if sfx_target_hit.stream != null and not sfx_target_hit.playing:
		sfx_target_hit.play()

func play_button():
	if sfx_button.stream != null:
		sfx_button.play()

func _create_tone(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var byte_array = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / total_samples) # Linear fade-out
		var sample_val = sin(2.0 * PI * freq * t) * envelope * 0.4
		var int_val = int(sample_val * 32767.0)
		int_val = clampi(int_val, -32768, 32767)
		
		# 16-bit PCM little endian
		byte_array[i * 2] = int_val & 0xFF
		byte_array[i * 2 + 1] = (int_val >> 8) & 0xFF
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = byte_array
	return stream
