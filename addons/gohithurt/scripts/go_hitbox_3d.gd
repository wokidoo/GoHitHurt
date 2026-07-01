@tool
@icon("res://addons/gohithurt/icons/go_hitbox_3d.svg")
class_name GoHitbox3D extends ShapeCast3D
## A hitbox that scans for [GoHurtbox3D] areas and reports hits.
##
## Each physics frame (subject to [member frame_delay]) this node checks its
## [ShapeCast3D] collisions and, for every overlapping [GoHurtbox3D], emits
## [signal hit_detected] and calls [method GoHurtbox3D.receive_hit]. Colliders
## that are not hurtboxes are added as exceptions so they are skipped on
## subsequent scans.

## Additional data passed to [GoHurtbox3D] on collision.
## [br][b]Note:[/b][br]
## [member hit_data] and collision data are merged together into 
## a single dictionary when [member hit_detected] is emitted. Keep this
## in mind when choosing keys for your data.
@export var hit_data:Dictionary
## Number of physics frames between hit-detection scans. [code]1[/code] scans
## every frame, [code]2[/code] every other frame, and so on.
## [br][b]Warning:[/b] must be [code]>= 1[/code]; [code]0[/code] raises a
## "modulo by zero" error in the physics step.
@export var frame_delay:int = 1

## Emitted when a hit against a [GoHurtbox3D] is detected. [param collision] is
## the [ShapeCast3D] collision dictionary augmented with a [code]source[/code]
## key (this hitbox) and merged with [member hit_data].
signal hit_detected(collision:Dictionary)

func _init() -> void:
	collide_with_areas = true
	collide_with_bodies = false

func _ready() -> void:
	set_physics_process(enabled)
	self.clear_exceptions()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		clear_exceptions()

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % frame_delay == 0:
		_process_collisions()

func _validate_property(property: Dictionary) -> void:
	if property.name == "collide_with_areas" or property.name == "collide_with_bodies":
		property.usage |= PropertyUsageFlags.PROPERTY_USAGE_READ_ONLY
	elif property.name == "enabled":
		property.usage |= PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE

func _set(property: StringName, value: Variant) -> bool:
	if property == "enabled":
		enabled = value
		set_physics_process(enabled)
		return true
	return false

func _add_parent_hurtbox_exceptions():
	var parent_children:= get_parent().get_children(true)
	for child in parent_children:
		if child is GoHurtbox3D:
			add_exception(child)

## Forces an immediate shape-cast query this frame and reports any hits,
## bypassing [member enabled] and [member frame_delay]. Non-hurtbox colliders are
## added as exceptions exactly as in the automatic per-frame scan.
## [br][b]Note:[/b] uses [method ShapeCast2D.force_shapecast_update], so the node
## must be inside the tree; the query runs even while the hitbox is disabled.
func query_hit() -> void:
	force_shapecast_update()
	_process_collisions()

func _process_collisions() -> void:
	for collision:Dictionary in collision_result:
		if collision.collider is GoHurtbox3D:
			collision.set(&'source',self)
			collision.merge(hit_data)
			hit_detected.emit(collision)
			collision.collider.receive_hit(collision)
		else: ## Exclude non-Hurtbox collision
			add_exception(collision.collider) 

## Enables the hitbox, resuming per-frame hit detection.
func enable():
	set('enabled',true)
## Disables the hitbox, pausing hit detection.
func disable():
	set('enabled',false)
## Enables the hitbox for [param duration] seconds, then disables it.
## [br][b]Note:[/b] asynchronous; awaits a [SceneTreeTimer].
func enable_temporarily(duration:float = 1.0)->void:
	set('enabled',true)
	await get_tree().create_timer(duration).timeout
	set('enabled',false)
## Disables the hitbox for [param duration] seconds, then re-enables it.
## [br][b]Note:[/b] asynchronous; awaits a [SceneTreeTimer].
func disable_temporarily(duration:float = 1.0)->void:
	set('enabled',false)
	await get_tree().create_timer(duration).timeout
	set('enabled',true)
