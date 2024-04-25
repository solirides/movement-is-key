extends CanvasLayer


@export var health_bar:ProgressBar = null
@export var boss_bar:ProgressBar = null
@export var speed:Label = null
@export var game_over:Node = null
@export var player:RigidBody3D = null

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = player.health
	if player.sandworm != null:
		boss_bar.value = player.sandworm.health
	#print(player.sandworm.health)
	speed.text = "speed: " + str(floor(player.linear_velocity.length()))


