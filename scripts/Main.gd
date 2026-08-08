extends Node
## Main autoload. Owns the top-level scene tree and coordinates environment,
## aircraft and airport subsystems. This is the first script any scene touches.

const DEFAULT_AIRCRAFT := "Cessna"
const SCENE_BASE_PATH := "res://scenes/aircraft/"
const AIRCRAFT_NAME_TO_SCENE := {
	"AH64": "helicopters/ah64/ah64.tscn",
	"R22": "helicopters/r22/r22.tscn",
	"Cessna": "cessna/cessna.tscn",
	"B737": "b737/b737.tscn",
	"F22": "f22/f22.tscn",
	"A380": "a380/a380.tscn",
	"B747": "b747/b747.tscn",
	"B777": "b777/b777.tscn",
	"B757": "b757/b757.tscn",
}

## Runtime registration maps. Aircraft scripts register themselves here so the
## UI can list them and the manager can spawn them without hard-coding a new
## `add_child` call for every model.
static var available_aircraft: Dictionary = {}
static var current_aircraft_path := ""

var active_aircraft: Node3D = null
var paused := false
var camera_mode := 0

@onready var environment_root: Node3D = $Environment
@onready var aircraft_manager: Node3D = $AircraftManager
@onready var airport_manager: Node3D = $AirportManager
@onready var ui_layer: CanvasLayer = $UI
@onready var pause_layer: CanvasLayer = $PauseLayer

func _ready() -> void:
	_process_mode = Node.PROCESS_MODE_ALWAYS
	initialize_environment()
	initialize_airport_manager()
	register_default_aircraft()
	load_aircraft(DEFAULT_AIRCRAFT)
	print("Flight Simulator initialized — active: ", DEFAULT_AIRCRAFT)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui/pause"):
		toggle_pause()
	elif event.is_action_pressed("ui/camera_follow"):
		cycle_camera()

func _process(_delta: float) -> void:
	if paused:
		get_tree().paused = true

func initialize_environment() -> void:
	# WorldEnvironment settings are stored in the scene; here we only validate
	# that critical nodes exist so a broken scene fails fast in the editor.
	if environment_root == null:
		push_error("Environment node missing from main scene.")

func initialize_airport_manager() -> void:
	# Airport data is loaded lazily from resource packs in later tasks. The node
	# exists now so scene wiring is stable.
	if airport_manager == null:
		push_error("AirportManager node missing from main scene.")

func register_default_aircraft() -> void:
	# Merge built-in map with any aircraft registered at runtime (e.g. from
	# mods). Runtime registrations win so mods can replace stock aircraft.
	var merged := AIRCRAFT_NAME_TO_SCENE.duplicate()
	for key: String in available_aircraft:
		merged[key] = available_aircraft[key]
	available_aircraft = merged

func load_aircraft(aircraft_type: String) -> Node3D:
	var aircraft_name := aircraft_type.strip_edges()
	if aircraft_name.is_empty():
		push_error("load_aircraft: empty aircraft type")
		return null

	var scene_path := available_aircraft.get(aircraft_name, "") as String
	if scene_path.is_empty():
		# Allow raw paths to ease testing: "res://scenes/aircraft/..."
		if aircraft_name.begins_with("res://"):
			scene_path = aircraft_name
		else:
			push_error("Unknown aircraft: %s" % aircraft_name)
			return null

	var full_path := scene_path if scene_path.begins_with("res://") else SCENE_BASE_PATH + scene_path
	var packed: PackedScene = load(full_path)
	if packed == null:
		push_error("Failed to load aircraft scene: %s" % full_path)
		return null

	var instance: Node3D = packed.instantiate()
	active_aircraft = instance
	current_aircraft_path = full_path
	aircraft_manager.add_child(instance)
	print("Aircraft spawned: ", aircraft_name, " (", full_path, ")")
	return instance

func cycle_camera() -> void:
	camera_mode = (camera_mode + 1) % 4
	if active_aircraft != null and active_aircraft.has_method("set_camera_mode"):
		active_aircraft.set_camera_mode(camera_mode)

func toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	print("Game ", ("paused" if paused else "resumed"))

func quit() -> void:
	get_tree().quit()
