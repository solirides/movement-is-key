extends Node3D


var core:PhysicalBone3D = null
var head:PhysicalBone3D = null
@export var player:Node = null

@export var reference:Skeleton3D = null
@export var skeleton:Skeleton3D = null

@export var stiffness:float = 1
@export var damping:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for bone in skeleton.get_children():
		if bone is PhysicalBone3D:
			bone.gravity_scale = 1
			#bone.joint_constraints/twist_span = 0
			#print(bone.get_property_list())
			#bone.set("joint_constraints/swing_span", 0)
			#bone.set("joint_constraints/twist_span", 0)
			#bone.set("linear_velocity", Vector3(10, 10, 10))
			#bone.apply_central_impulse(Vector3(10, 10, 10))
	
	core = skeleton.find_child("Physical Bone Bone_006")
	head = skeleton.find_child("Physical Bone Bone_007")
	
	skeleton.physical_bones_start_simulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for bone in skeleton.get_children():
		if bone is PhysicalBone3D:
			var target = reference.global_transform * reference.get_bone_global_pose(bone.get_bone_id())
			var current = skeleton.global_transform * skeleton.get_bone_global_pose(bone.get_bone_id())
			
			var position_diff = target.origin - current.origin
			var rotation_diff = (target.basis * current.basis.inverse()).get_euler()
			
			if bone == head:
				#head.look_at(player.global_transform.origin, Vector3(0, 0, 1))
				#current.basis.rotated(Vector3(1, 0, 0), PI/4).looking_at(Vector3(0, 0, 1))
				print("look")
			
			bone.linear_velocity += delta * (position_diff * stiffness - bone.linear_velocity * damping)
			
			bone.angular_velocity += delta * (rotation_diff * stiffness - bone.angular_velocity * damping)
			
			#print(position_diff)
			#print(bone.get_bone_id())
			#print(target)
			#print(current)
	
	#if player.is_inside_tree():
		core.apply_central_impulse((player.global_transform.origin - core.global_transform.origin).normalized() * 6.0)
		
