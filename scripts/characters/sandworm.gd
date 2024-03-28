extends Node3D

var gravity = 1
var impulse = Vector3(0, 0, 0)
var core:PhysicalBone3D = null
var ref_core:PhysicalBone3D = null
var head:PhysicalBone3D = null
@export var player:Node = null

@export var reference:Skeleton3D = null
@export var skeleton:Skeleton3D = null

@export var stiffness:float = 1
@export var damping:float = 1
@export var max_speed:float = 30

var last_damage = 0
var last_heal = 0
var health:float = 1000

@export_category("Damage")
@export var i_frame:float = 1
@export var base_health:float = 1000

enum State {ATTACK, RETREAT, TRACK}

var current_state = State.ATTACK
var state_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#recursive(skeleton)
	#recursive(reference)
	#for i in range(0,19):
		#skeleton.set_bone_pose_scale(i, Vector3(1,1,1) * 1.15)
		#skeleton.set_bone_pose_scale(i, Vector3(1,1,1) * 1.15)
	
	for bone in skeleton.get_children():
		if bone is PhysicalBone3D:
			bone.gravity_scale = 4
			bone.mass = 1
			#bone.joint_constraints/twist_span = 0
			#print(bone.get_property_list())
			#bone.set("joint_constraints/swing_span", 0)
			#bone.set("joint_constraints/twist_span", 0)
			#bone.set("linear_velocity", Vector3(10, 10, 10))
			#bone.apply_central_impulse(Vector3(10, 10, 10))
	
	for bone in reference.get_children():
		if bone is PhysicalBone3D:
			bone.collision_layer = 0
			bone.collision_mask = 0
	
	core = skeleton.find_child("Physical Bone Bone_006")
	ref_core = reference.find_child("Physical Bone Bone_007")
	head = skeleton.find_child("Physical Bone Bone_007")
	
	skeleton.physical_bones_start_simulation()

func recursive(node):
	if node is CollisionShape3D:
		node.shape.radius *= 0.1
		node.shape.height *= 1
		#node.body_offset *= 5
		#node.scale *= 5
	#if node is PhysicalBone3D:
		#node.body_offset = node.body_offset.scale(Vector3(1,1,1) * 30)
	for a in node.get_children():
		recursive(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	last_damage += delta
	last_heal += delta
	
	state_time += delta
	gravity = 2
	
	match current_state:
		State.ATTACK:
			gravity = 0
			core.apply_central_impulse((player.global_position - core.global_position).normalized() * 10.0)
			if state_time > 7:
				state_time = 0
				current_state = State.RETREAT
		State.RETREAT:
			gravity = 2
			core.apply_central_impulse(signf(-9 - core.global_position.y) * Vector3(0, 1, 0) * 6)
			if state_time > 4 and is_underground():
				state_time = 0
				current_state = State.TRACK
		State.TRACK:
			gravity = 1
			core.apply_central_impulse((player.global_position - core.global_position).normalized() * Vector3(10, 0, 10))
			core.apply_central_impulse(signf(-7 - core.global_position.y) * Vector3(0, 1, 0) * 3)
			if state_time > 8:
				state_time = 0
				current_state = State.ATTACK
	
	#print(current_state)
	
	if is_underground() and false:
		print("boost")
		impulse = Vector3(0, 600, 0)
		#gravity = 0
	
	for bone in skeleton.get_children():
		if bone is PhysicalBone3D:
			bone.gravity_scale = gravity
			
			var target = reference.global_transform * reference.get_bone_global_pose(bone.get_bone_id())
			var current = skeleton.global_transform * skeleton.get_bone_global_pose(bone.get_bone_id())
			
			var position_diff = target.origin - current.origin
			var rotation_diff = (target.basis * current.basis.inverse()).get_euler()
			
			
			if bone == core:
				continue
			
			if bone == head:
				#head.look_at(player.global_transform.origin, Vector3(0, 0, 1))
				#current.global_basis.rotated(Vector3(1, 0, 0), PI/4).looking_at(Vector3(0, 0, 1))
				#var t = Basis.looking_at(player.global_transform.origin - core.global_transform.origin).rotated(Vector3(1, 0, 0), PI/2)
				#rotation_diff = (t * current.basis.inverse()).get_euler()
				#core.global_basis = t
				bone.angular_velocity += delta * (rotation_diff * 60 - bone.angular_velocity * 10)
				#print("look")
			
			bone.linear_velocity += delta * (position_diff * stiffness - bone.linear_velocity * damping)
			#
			bone.angular_velocity += delta * (rotation_diff * stiffness - bone.angular_velocity * damping)
			
			bone.linear_velocity += impulse
			
			#print(position_diff)
			#print(bone.get_bone_id())
			#print(target)
			#print(current)
	
			#print(bone.angular_velocity)
			var s = bone.angular_velocity.length()
			if s > max_speed:
				#bone.angular_velocity = bone.angular_velocity.normalized() * max_speed / 2
				core.angular_velocity = Vector3.ZERO
				skeleton.reset_bone_poses()
				print("too fast")
			var v = bone.linear_velocity.length()
			if v > max_speed:
				#bone.linear_velocity = bone.linear_velocity.normalized() * max_speed / 2
				core.linear_velocity = Vector3.ZERO
				skeleton.reset_bone_poses()
				print("too fast")
	
	impulse = Vector3(0, 0, 0)
	
	#rotation_diff = (t * current.basis.inverse()).get_euler()
	#head.angular_velocity += delta * (rotation_diff * 10 - bone.angular_velocity * damping)
	

func is_underground():
	if core.global_position.y < -5:
		return true
	return false

func damage(hp:float):
	if last_damage >= i_frame:
		last_damage = 0
		health = max(0, health - hp)

func heal(hp:float):
	last_heal = 0
	health = min(base_health, health + hp)
