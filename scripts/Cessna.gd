extends "res://scripts/Aircraft.gd"
## Cessna 172 — high-wing single-engine trainer.

func _ready() -> void:
	display_name = "Cessna 172"
	aircraft_type = "fixed_wing"
	category = "general_aviation"
	max_speed_kmh = 302.0
	cruise_speed_kmh = 226.0
	max_altitude_m = 4115.0
	mass_kg = 1111.0
	wing_area_m2 = 16.2
	max_roll_rate_deg = 70.0
	max_pitch_rate_deg = 25.0
	max_yaw_rate_deg = 18.0
	speed_airspeed_kmh = 0.0
	altitude_m = 0.0
	super()

func update_physics(delta: float) -> void:
	# Simple trainer model: strong low-speed authority, moderate ceiling.
	var throttle_accel := input_throttle * 55.0
	var drag := speed_airspeed_kmh * 0.01
	speed_airspeed_kmh = maxf(0.0, speed_airspeed_kmh + (throttle_accel - drag) * delta)
	var forward := -transform.basis.z
	transform.origin += forward * (speed_airspeed_kmh / 3.6) * delta
	# Climb/descent from pitch input while moving.
	var pitch_factor := input_pitch * clampf(speed_airspeed_kmh / 80.0, 0.0, 1.0)
	vertical_speed_mps = pitch_factor * 6.0
	altitude_m = maxf(0.0, altitude_m + vertical_speed_mps * delta)
	heading_deg = fposmod(heading_deg + input_yaw * 12.0 * delta, 360.0)
	emit_signal("aircraft_changed")

func update_animation(_delta: float) -> void:
	# Update any child control-surface nodes when meshes are added in later tasks.
	var deflections := get_control_surface_deflections()
	for key: String in deflections:
		var node := find_control_surface(key)
		if node != null:
			node.rotation.x = deflections[key] * 0.5
