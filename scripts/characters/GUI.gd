extends CanvasLayer


@export var health_bar:ProgressBar = null
@export var speed:Label = null
@export var player:RigidBody3D = null

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = player.health
	speed.text = "speed: " + str(floor(player.linear_velocity.length()))
