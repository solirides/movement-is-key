extends RigidBody3D


@export var head:PhysicalBone3D = null
@export var player:Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for bone in $Skeleton3D.get_children():
		if bone is PhysicalBone3D:
			pass
			#bone.joint_constraints/twist_span = 0
			#print(bone.get_property_list())
			#bone.set("joint_constraints/swing_span", 0)
			#bone.set("joint_constraints/twist_span", 0)
			#bone.set("linear_velocity", Vector3(10, 10, 10))
			#bone.apply_central_impulse(Vector3(10, 10, 10))
	$Skeleton3D.physical_bones_start_simulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if player.is_inside_tree():
		for bone in $Skeleton3D.get_children():
			if bone is PhysicalBone3D:
				bone.apply_central_impulse((player.transform.origin - bone.transform.origin ) * 0.2)
		head.apply_central_impulse((player.transform.origin - head.transform.origin ) * 0.5)
