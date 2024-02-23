extends RigidBody3D


var health:float = 100
var movement_state = 0
var jump_cooldown = 0
var time_delta = 0
var last_damage = 0
var last_heal = 0

@export_category("Movement")
@export var ground_friction:float = 0.9
@export var air_friction:float = 1
@export var mouse_sensitivity:float = 0.1
@export var base_knockback:float = 1
@export var base_speed:float = 50
@export var ground_max_speed:float = 6
@export var air_max_speed:float = 8
#@export var acceleration_speed = 1000
#@export var deceleration_speed = 0.1
@export var air_control = 0.5
@export var gravity = 38
@export var jump_velocity = Vector3(0,12,0)

@export_category("Nodes")
@export var camera_pivot:Node = null
@export var camera:Camera3D = null
@export var feet_collision:RayCast3D = null
@export var aim:RayCast3D = null
@export var feet_area:Area3D = null
@export var force_area:Area3D = null
@export var crouch_timer:Timer = null

@export_category("Damage")
@export var i_frame:float = 1
@export var base_health:float = 100


var movement_speed:float = base_speed
var knockback_mult:float = base_knockback

var explosion = preload("res://scenes/objects/explosion.tscn")

func _ready():
#	self.set_can_sleep(false)
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	pass

func _physics_process(delta):
	time_delta = delta
	jump_cooldown = max(0, jump_cooldown - delta)
	
	last_damage += delta
	last_heal += delta
	if last_damage > 4 and last_heal > 0.2:
		heal(1)
	
#	velocity = lerp(velocity * delta, velocity, acceleration_speed * delta)
#	if feet_collision.is_colliding():
#		print("collide")
#		if Input.is_action_pressed("jump"):
#			apply_central_impulse(jump_velocity)
#	print(velocity)
#	print(direction)
#	print(feet_collision.is_colliding()
	#apply_central_force(Vector3.DOWN * gravity * delta)
	
	if Input.is_action_just_pressed("secondary"):
		if force_area.has_overlapping_bodies():
			for object in force_area.get_overlapping_bodies():
				if object is RigidBody3D or object is PhysicalBone3D:
					var offset = object.get_global_transform().origin - camera.get_global_transform().origin
					var magnitude = max(0, 10 - offset.length()**1.5 ) * 3.0
					object.apply_central_impulse(magnitude * offset.normalized())
					print(object)
				
	if Input.is_action_just_pressed("secondary"):
		if aim.is_colliding():
			var offset = aim.get_collision_point() - camera.get_global_transform().origin
			var magnitude = max(0, 10 - offset.length()**1.2 ) * 2.8
			print(aim.get_collision_point() - self.get_global_transform().origin)
			self.apply_central_impulse(-magnitude * offset.normalized())
			
			var a = explosion.instantiate()
			get_tree().root.add_child(a)
			a.position = aim.get_collision_point()
	
	if Input.is_action_pressed("crouch"):
		#$Standing.disabled = true
		#$Crouching.disabled = false
		$Standing.transform.origin.y = -0.25
		camera_pivot.transform.origin.y = -0.25
		movement_speed = base_speed / 2
		knockback_mult = base_knockback * 1.2
		self.mass = 1 / knockback_mult
		movement_state = 1
		#print("crouch")
	else:
		if movement_state == 1:
			movement_state = 0
			crouch_timer.start()
		var p = 1 - crouch_timer.time_left / crouch_timer.wait_time
		$Standing.transform.origin.y = lerp(-0.25, 0.25, p)
		camera_pivot.transform.origin.y = lerp(-0.25, 0.25, p)
		movement_speed = base_speed
		knockback_mult = base_knockback
		self.mass = knockback_mult
		
		#$Standing.transform.origin.y = 0.25
		
		#$Standing.disabled = false
		#$Crouching.disabled = true
	#print(velocity * delta)
	
	for object in get_colliding_bodies():
		if object.collision_layer & (1 << 12):
			damage(20)
			#print(object.collision_layer)
			#print(1 << 12)
	
#	print("pos " + str(self.translation))
	

func _integrate_forces(state):
	
	var on_ground:bool = state.get_contact_count() and feet_area.has_overlapping_bodies()
	
	self.physics_material_override.friction = 0
	
	# gravity
	state.linear_velocity.y -= gravity * time_delta * 1
	
	# on ground
	if on_ground:
		#state.linear_velocity.x = lerp(state.linear_velocity.x,0.0,deceleration_speed)
		#state.linear_velocity.y = lerp(state.linear_velocity.y,0.0,deceleration_speed)
		#state.linear_velocity.z = lerp(state.linear_velocity.z,0.0,deceleration_speed)
		if Input.is_action_pressed("jump") and jump_cooldown <= 0:
			jump_cooldown = 0.1
			print("jump")
			
			if state.get_contact_local_normal(0).y < 0.9 and state.get_contact_local_normal(0).y > 0.1:
				#state.linear_velocity.y = 0
				#apply_central_impulse(jump_velocity * pow(state.get_contact_local_normal(0).y, 2))
				state.linear_velocity.y = jump_velocity.y
			else:
				#state.linear_velocity.y = 0
				#apply_central_impulse(jump_velocity)
				
				state.linear_velocity.y = jump_velocity.y
		else:
			state.linear_velocity.x *= ground_friction
			state.linear_velocity.z *= ground_friction
		
		
		if state.get_contact_local_normal(0).y < 0.9 and state.get_contact_local_normal(0).y > 0.1:
			#self.physics_material_override.friction = 1
			#apply_central_force(state.get_contact_local_normal(0).rotated(Vector3.UP, deg_to_rad(180)) * 9.7)
			#apply_central_force(Vector3.UP*9.8)
			
			#state.linear_velocity.z -= state.get_contact_local_normal(0).z * gravity
			#state.linear_velocity.x -= state.get_contact_local_normal(0).x * gravity
			#state.linear_velocity += state.get_contact_local_normal(0) * Vector3(-1, -1, -1)
			#state.linear_velocity.y = 0
			print("slope")
		
		
	else:
		state.linear_velocity.x *= air_friction
		state.linear_velocity.z *= air_friction
		
	
	#if Input.is_action_just_pressed("secondary"):
		#if aim.is_colliding():
			#var offset = aim.get_collision_point() - camera.get_global_transform().origin
			#var magnitude = max(0, 10 - offset.length()**1.2 ) * 3.0
			#print(aim.get_collision_point() - self.get_global_transform().origin)
			#state.linear_velocity -= magnitude * offset.normalized()
	
	
	var local_dir = Vector3.ZERO
	
	local_dir.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	local_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	local_dir = local_dir.normalized()
	
	#var velocity = camera_pivot.get_global_transform().basis * (local_dir.normalized()) * base_speed
	
	var global_dir = camera_pivot.get_global_transform().basis * local_dir
	
	var acceleration = movement_speed
	var max_speed = air_max_speed
	
	if on_ground:
		acceleration = movement_speed
		max_speed = ground_max_speed
	
	var projected_speed = global_dir.dot(state.linear_velocity)
	var accel = acceleration * time_delta
	accel = max(0, min(accel, max_speed - projected_speed))
	
	if on_ground:
		state.linear_velocity += global_dir * accel
	else:
		state.linear_velocity += global_dir * accel * air_control
	
	#state.linear_velocity += velocity * time_delta
	
#	if state.linear_velocity.length() > max_speed:
#		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	#
	
	#print(state.get_contact_local_normal(0))
#	print(state.linear_velocity)
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		#print(Input.mouse_mode)
	
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("ui_accept"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y += (deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	

func abs_decrease(value:float, rate:float):
	if sign(value):
		return max(0, value - rate)
	else:
		return min(0, value + rate)
	

func damage(hp:float):
	if last_damage >= i_frame:
		last_damage = 0
		health -= hp

func heal(hp:float):
	last_heal = 0
	health += hp

