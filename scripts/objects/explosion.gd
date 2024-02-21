extends Node3D


func _ready():
	await get_tree().create_timer(1.0).timeout
	#for c in get_children():
		#c.queue_free()
	queue_free()

