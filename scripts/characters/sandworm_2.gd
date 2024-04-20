extends Node3D

var gravity = 1
var impulse = Vector3(0, 0, 0)
var core:PhysicalBone3D = null
var ref_core:PhysicalBone3D = null
var head:PhysicalBone3D = null
@export var player:Node = null

@export var reference:Skeleton3D = null
@export var skeleton:Skeleton3D = null
@export var ref_pivot:Node3D = null
@export var damage_area:Area3D = null
@export var attack_area:Area3D = null
@export var raycast:RayCast3D = null

@export var stiffness:float = 1
@export var damping:float = 1
@export var max_speed:float = 30

var last_damage = 0
var last_attack = 0
var last_heal = 0
var health:float = 1000

@export_category("Damage")
@export var i_frame:float = 0.1
@export var attack_cooldown:float = 1.4
@export var base_health:float = 1000

enum State {ATTACK, RETREAT, TRACK, EMERGE}

var current_state = State.ATTACK
var state_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#skeleton.scale *= 5
	#reference.scale *= 5
	recursive(skeleton)
	recursive(reference)
	#for a in skeleton.bones():
		#a.scale *= 5
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
	
	core = skeleton.find_child("Physical Bone Bone_007")
	ref_core = reference.find_child("Physical Bone Bone_007")
	head = skeleton.find_child("Physical Bone Bone_007")
	
	skeleton.physical_bones_start_simulation()
	
	#print(player)

func recursive(node):
	if node is CollisionShape3D:
		pass
		#node.shape.radius *= 3.0
		#node.shape.height *= 1
		#node.rotation.x = 0
		#node.body_offset *= 5
		#node.scale *= 5
	for a in node.get_children():
		recursive(a)


func _physics_process(delta):
	last_damage += delta
	last_attack += delta
	last_heal += delta
	
	state_time += delta
	
	if is_underground() and false:
		print("boost")
		impulse = Vector3(0, 600, 0)
		#gravity = 0
	
	#for bone in reference.get_children():
		#if bone == ref_core:
	#head.look_at(player.global_transform.origin, Vector3(0, 0, 1))
	#current.global_basis.rotated(Vector3(1, 0, 0), PI/4).looking_at(Vector3(0, 0, 1))
	#.rotated(Vector3(1, 0, 0), PI/2)
	#ref_pivot.basis.slerp(t0, 1)
	#bone.angular_velocity += delta * (rotation_diff * 60.0 - bone.angular_velocity * 10.0)
	#print(bone.angular_velocity)
	#print("look")
	
	
	for bone in skeleton.get_children():
		if bone is PhysicalBone3D:
			bone.gravity_scale = gravity
			
			var target = reference.global_transform * reference.get_bone_global_pose(bone.get_bone_id())
			var current = skeleton.global_transform * skeleton.get_bone_global_pose(bone.get_bone_id())
			
			var position_diff = target.origin - current.origin
			var rotation_diff = (target.basis * current.basis.inverse()).get_euler()
			
			#if bone == core:
				#bone.angular_velocity += delta * (rotation_diff * 2 - bone.linear_velocity * 1)
			
			
			bone.linear_velocity += delta * (position_diff * stiffness - bone.linear_velocity * damping)
			#
			bone.angular_velocity += delta * (rotation_diff * stiffness - bone.angular_velocity * damping)
			
			bone.linear_velocity += impulse
			
			#print(rotation_diff)
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
	gravity = 2
	var t0 = Basis()
	
	#current_state
	match current_state:
		State.ATTACK:
			gravity = 1
			core.apply_central_impulse((player.global_position - core.global_position).normalized() * 8.0)
			#t0 = Basis.looking_at(player.global_transform.origin - ref_pivot.global_transform.origin)
			var a = (player.global_transform.origin - ref_pivot.global_transform.origin).rotated(Vector3(0,1,0), PI/2)
			t0 = Basis.looking_at(Vector3(a.x, a.y, a.z), Vector3(1,0,0), false)
			
			if state_time > 14:
				state_time = 0
				current_state = State.RETREAT
		State.RETREAT:
			gravity = 4
			# signf(-50 - core.global_position.y)
			core.apply_central_impulse(Vector3(0, -1, 0) * 80.0)
			t0 = Basis.looking_at(Vector3(0,-1,0), Vector3(1, 0, 0))
			
			if (state_time > 4 and is_underground()):
				state_time = 0
				current_state = State.TRACK
		State.TRACK:
			gravity = 1
			core.apply_central_impulse((player.global_position - core.global_position) * Vector3(4, 0, 4))
			core.apply_central_impulse(signf(-14 - core.global_position.y) * Vector3(0, 1, 0) * 3)
			t0 = Basis.looking_at(player.global_transform.origin - ref_pivot.global_transform.origin)
			
			var d = Vector2.ZERO.distance_to(Vector2(player.global_transform.origin.x - ref_pivot.global_transform.origin.x, player.global_transform.origin.z - ref_pivot.global_transform.origin.z))
			
			#print(d)
			if state_time > 5 and d < 30:
				state_time = 0
				current_state = State.EMERGE
		State.EMERGE:
			gravity = 0
			core.apply_central_impulse(Vector3(0, 1, 0) * 60.0)
			t0 = Basis.looking_at(Vector3(0,1,0), Vector3(1, 0, 0))
			
			var d = player.global_transform.origin.y - ref_pivot.global_transform.origin.y
			
			if d < -10:
				state_time = 0
				current_state = State.ATTACK
	
	#gravity = 0
	ref_pivot.basis = ref_pivot.basis.slerp(t0, delta * 5.0)
	#ref_pivot.basis = core.basis
	
	print(current_state)
	
	if current_state == State.ATTACK and last_attack >= attack_cooldown:
		var attacked = false
		for node in attack_area.get_overlapping_bodies():
			if node.is_in_group("characters"):
				var a = (core.global_transform.basis.z.normalized() + Vector3(0,-0.2,0)).normalized()
				node.apply_central_impulse(a * -70.0)
				node.damage(50)
				last_attack = 0
				attacked = true
				break
		if not attacked:
			for node in damage_area.get_overlapping_bodies():
				if node.is_in_group("characters"):
					node.damage(30)
					last_attack = 0
					if randf() > 0.9:
						current_state = State.RETREAT
					break
	

func is_underground():
	if core.global_position.y < -10:
		return true
	return false

func damage(hp:float):
	if last_damage >= i_frame:
		last_damage = 0
		health = max(0, health - hp)

func heal(hp:float):
	last_heal = 0
	health = min(base_health, health + hp)
