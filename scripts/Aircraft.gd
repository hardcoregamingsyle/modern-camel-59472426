extends Node3D
## Base aircraft class. Every aircraft (fixed wing and helicopter) extends this
## script directly or through a subclass. It defines the common public contract:
## physics input from flight controls and animation output to control surfaces.

# ---- Identification --------------------------------------------------------
@export var display_name := "Generic Aircraft"
@export var aircraft_type := "fixed_wing"
@export var category := "unknown"

# ---- State - present in world units ------------------------------
@export var speed_airspeed_kmh := 0.0   ## True airspeed, km/h
@export var altitude_m := 0.0           ## Height above terrain, meters
@export var vertical_speed_mps := 0.0   ## Climb rate, m/s
@export var heading_deg := 0.0          ## True heading 0..360
@export var pitch_deg := 0.0
@export var roll_deg := 0.0

# ---- Control inputs, normalized -1..1 --------------------------------------
var input_pitch := 0.0      # -1 full nose down, +1 full nose up
var input_roll := 0.0
var input_yaw := 0.0
var input_throttle := 0.0   # 0..1
var input_flaps := 0.0      # 0..1
var input_brakes := false
var gear_down := true

# ---- Performance envelope --------------------------------------------------
@export var max_speed_kmh := 300.0
@export var cruise_speed_kmh := 200.0
@export var max_altitude_m := 5000.0
@export var max_roll_rate_deg := 80.0
@export var max_pitch_rate_deg := 30.0
@export var max_yaw_rate_deg := 20.0
@export var wing_area_m2 := 15.0
@export var mass_kg := 1000.0

signal aircraft_changed
signal control_surface_moved(surface_name: String, deflection: float)

# Called by input controller every physics tick.
func set_control_inputs(pitch: float, roll: float, yaw: float, throttle: float, flaps: float, brakes: bool) -> void:
	input_pitch = clampf(pitch, -1.0, 1.0)
	input_roll = clampf(roll, -1.0, 1.0)
	input_yaw = clampf(yaw, -1.0, 1.0)
	input_throttle = clampf(throttle, 0.0, 1.0)
	input_flaps = clampf(flaps, 0.0, 1.0)
	input_brakes = brakes

func _ready() -> void:
	print("Aircraft ready: ", display_name)
	aircraft_changed.emit()

func _physics_process(delta: float) -> void:
	update_physics(delta)
	update_animation(delta)

## Subclasses override this with a real aerodynamic model. The base
## implementation applies a very small drift so a spawned plane visibly moves.
func update_physics(delta: float) -> void:
	var throttle_accel := input_throttle * 8.0
	var drag := speed_airspeed_kmh * 0.002
	speed_airspeed_kmh = maxf(0.0, speed_airspeed_kmh + (throttle_accel - drag) * delta)
	var forward := -transform.basis.z
	transform.origin += forward * (speed_airspeed_kmh / 3.6) * delta
	aircraft_changed.emit()

## Subclasses override to drive aileron/elevator/rudder/flap/gear animations.
func update_animation(_delta: float) -> void:
	pass

# ---- Control surface queries/updates ----------------------------------------
func get_control_surface_position(surface_name: String) -> Vector3:
	# Base fallback: any unknown surface reports neutral (identity rotation).
	var surface := find_control_surface(surface_name)
	if surface == null:
		return Vector3.ZERO
	return surface.rotation

func set_control_surface_position(surface_name: String, rotation_euler: Vector3) -> void:
	var surface := find_control_surface(surface_name)
	if surface == null:
		return
	surface.rotation = rotation_euler
	control_surface_moved.emit(surface_name, rotation_euler.y)

func find_control_surface(surface_name: String) -> Node3D:
	if not has_node(surface_name):
		return null
	var node := get_node(surface_name)
	return node as Node3D

## Returns a dictionary of surface name -> deflection for HUD/debug.
func get_control_surface_deflections() -> Dictionary:
	return {
		"aileron_left": -input_roll,
		"aileron_right": input_roll,
		"elevator": input_pitch,
		"rudder": input_yaw,
		"flaps": input_flaps,
	}

func set_camera_mode(_mode: int) -> void:
	pass

func get_status_text() -> String:
	return "%s | %5.0f km/h | %5.0f m | %03.0f°" % [display_name, speed_airspeed_kmh, altitude_m, heading_deg]
